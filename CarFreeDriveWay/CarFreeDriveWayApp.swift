//
//  CarFreeDriveWayApp.swift
//  CarFreeDriveWay
//
//  Created by shh on 13/06/2025.
//

import SwiftUI

// MARK: - App Entry Point
// CarFreeDrivewayApp.swift
import SwiftUI

@main
struct CarFreeDrivewayApp: App {
    @StateObject private var gameViewModel = GameViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameViewModel)
                .preferredColorScheme(.light) // Force light mode for consistent visuals
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    
    var body: some View {
        Group {
            switch gameViewModel.currentState {
            case .menu:
                MenuView()
            case .playing:
                GameView()
            case .gameOver:
                GameOverView()
            case .success:
                SuccessView()
            }
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.3), value: gameViewModel.currentState)
    }
}

// MARK: - Models
// Models/GameState.swift
enum GameState {
    case menu
    case playing
    case gameOver
    case success
}

// MARK: - ViewModels
// ViewModels/GameViewModel.swift
import SceneKit
import AVFoundation

class GameViewModel: ObservableObject {
    @Published var currentState: GameState = .menu
    @Published var carPosition: SIMD3<Float> = .zero
    @Published var score: Int = 0
    @Published var attempts: Int = 0
    
    private var audioPlayer: AVAudioPlayer?
    private var collisionPlayer: AVAudioPlayer?
    private var winPlayer: AVAudioPlayer?
    
    init() {
        loadScores()
        setupAudio()
    }
    
    private func loadScores() {
        score = UserDefaults.standard.integer(forKey: "gameScore")
        attempts = UserDefaults.standard.integer(forKey: "gameAttempts")
    }
    
    private func saveScores() {
        UserDefaults.standard.set(score, forKey: "gameScore")
        UserDefaults.standard.set(attempts, forKey: "gameAttempts")
    }
    
    private func setupAudio() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            if let bgMusicURL = Bundle.main.url(forResource: "background", withExtension: "mp3") {
                audioPlayer = try AVAudioPlayer(contentsOf: bgMusicURL)
                audioPlayer?.numberOfLoops = -1
                audioPlayer?.volume = 0.3
            }
            
            if let collisionURL = Bundle.main.url(forResource: "collision", withExtension: "wav") {
                collisionPlayer = try AVAudioPlayer(contentsOf: collisionURL)
                collisionPlayer?.volume = 0.7
            }
            
            if let winURL = Bundle.main.url(forResource: "win", withExtension: "wav") {
                winPlayer = try AVAudioPlayer(contentsOf: winURL)
                winPlayer?.volume = 0.7
            }
        } catch {
            print("Audio setup error: \(error.localizedDescription)")
        }
    }
    
    func startGame() {
        attempts += 1
        currentState = .playing
        audioPlayer?.play()
    }
    
    func gameOver() {
        currentState = .gameOver
        audioPlayer?.pause()
        collisionPlayer?.play()
    }
    
    func gameSuccess() {
        score += 1
        saveScores()
        currentState = .success
        audioPlayer?.pause()
        winPlayer?.play()
    }
    
    func returnToMenu() {
        currentState = .menu
    }
    
    func updateCarPosition(_ position: SIMD3<Float>) {
        carPosition = position
    }
}

// MARK: - Views
// Views/MenuView.swift
struct MenuView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)), Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))]),
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("Car-Free Driveway")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 2, x: 0, y: 2)
                
                Image(systemName: "car.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color(#colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)))
                    .shadow(color: .black, radius: 3, x: 0, y: 3)
                
                VStack(spacing: 15) {
                    Text("Score: \(gameViewModel.score)")
                    Text("Attempts: \(gameViewModel.attempts)")
                }
                .font(.title2)
                .foregroundColor(.white)
                
                Button(action: {
                    withAnimation {
                        gameViewModel.startGame()
                    }
                }) {
                    Text("Start Game")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(#colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)))
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
                }
                .padding(.horizontal, 50)
            }
        }
    }
}

// Views/GameOverView.swift
struct GameOverView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Game Over")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 2, x: 0, y: 2)
                
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                
                Button(action: {
                    withAnimation {
                        gameViewModel.returnToMenu()
                    }
                }) {
                    Text("Back to Menu")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 50)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)))
                    .shadow(radius: 10)
            )
            .padding(40)
        }
    }
}

// Views/SuccessView.swift
struct SuccessView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Success!")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 2, x: 0, y: 2)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("Score: \(gameViewModel.score)")
                    .font(.title)
                    .foregroundColor(.white)
                
                Button(action: {
                    withAnimation {
                        gameViewModel.returnToMenu()
                    }
                }) {
                    Text("Back to Menu")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 50)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)))
                    .shadow(radius: 10)
            )
            .padding(40)
        }
    }
}

// Views/ControlPadView.swift
struct ControlPadView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @State private var activeDirection: Direction? = nil
    
    enum Direction: String {
        case up, down, left, right
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                // Control Pad
                VStack(spacing: 10) {
                    ControlButton(direction: .up, activeDirection: $activeDirection)
                    HStack(spacing: 10) {
                        ControlButton(direction: .left, activeDirection: $activeDirection)
                        ControlButton(direction: .right, activeDirection: $activeDirection)
                    }
                    ControlButton(direction: .down, activeDirection: $activeDirection)
                }
                .padding(20)
                .background(Color.black.opacity(0.3))
                .cornerRadius(50)
                .padding(.trailing, 30)
                .padding(.bottom, 50)
            }
        }
    }
}

struct ControlButton: View {
    let direction: ControlPadView.Direction
    @Binding var activeDirection: ControlPadView.Direction?
    
    var body: some View {
        Button(action: {
            activeDirection = direction
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }) {
            Image(systemName: arrowIcon)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(Color.black.opacity(0.5))
                .clipShape(Circle())
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: .infinity)
                .onEnded { _ in
                    activeDirection = nil
                }
        )
    }
    
    private var arrowIcon: String {
        switch direction {
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .left: return "arrow.left"
        case .right: return "arrow.right"
        }
    }
}

// Views/GameView.swift
import SceneKit

struct GameView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @State private var scene = GameScene()
    
    var body: some View {
        ZStack {
            // SceneKit View
            SceneView(
                scene: scene.scene,
                pointOfView: scene.cameraNode,
                options: [.allowsCameraControl, .autoenablesDefaultLighting]
            )
            .ignoresSafeArea()
            .onAppear {
                scene.setupGame()
                scene.gameViewModel = gameViewModel
            }
            
            // Overlay UI
            VStack {
                HStack {
                    Button(action: {
                        withAnimation {
                            gameViewModel.returnToMenu()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding()
                    
                    Spacer()
                }
                
                Spacer()
            }
            
            // Control Pad
            ControlPadView()
        }
        .statusBar(hidden: true)
    }
}

// MARK: - Scene
// Scene/GameScene.swift
import SceneKit

class GameScene: NSObject, SCNSceneRendererDelegate, SCNPhysicsContactDelegate {
    var scene: SCNScene!
    var cameraNode: SCNNode!
    var carNode: SCNNode!
    var goalAreaNode: SCNNode!
    var obstacles: [SCNNode] = []
    weak var gameViewModel: GameViewModel?
    
    private let moveSpeed: Float = 0.2
    private let rotationSpeed: Float = 0.05
    private var activeDirection: ControlPadView.Direction? = nil
    private var lastUpdateTime: TimeInterval = 0
    
    override init() {
        super.init()
        setupScene()
    }
    
    func setupScene() {
        // Create scene
        scene = SCNScene()
        scene.physicsWorld.contactDelegate = self
        
        // Setup camera
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 10, z: 15)
        cameraNode.eulerAngles = SCNVector3(x: -Float.pi/6, y: 0, z: 0)
        scene.rootNode.addChildNode(cameraNode)
        
        // Enhanced lighting setup
        setupEnhancedLighting()
    }
    
    private func setupEnhancedLighting() {
        // Ambient light for base illumination
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.intensity = 300
        ambientLightNode.light?.temperature = 4000 // Warm ambient light
        scene.rootNode.addChildNode(ambientLightNode)
        
        // Dynamic sun (directional light)
        let sunLight = SCNLight()
        sunLight.type = .directional
        sunLight.intensity = 1000
        sunLight.castsShadow = true
        sunLight.shadowRadius = 5
        sunLight.shadowColor = UIColor.black.withAlphaComponent(0.3)
        sunLight.shadowMode = .deferred
        sunLight.shadowSampleCount = 64 // Higher quality shadows
        sunLight.temperature = 5500 // Natural sunlight temperature
        
        let sunNode = SCNNode()
        sunNode.light = sunLight
        sunNode.position = SCNVector3(x: 10, y: 20, z: 10)
        sunNode.eulerAngles = SCNVector3(x: -Float.pi/3, y: Float.pi/4, z: 0)
        scene.rootNode.addChildNode(sunNode)
        
        // Add subtle rim lighting
        let rimLight = SCNLight()
        rimLight.type = .directional
        rimLight.intensity = 400
        rimLight.temperature = 6500 // Cool rim light
        
        let rimLightNode = SCNNode()
        rimLightNode.light = rimLight
        rimLightNode.position = SCNVector3(x: -15, y: 10, z: -15)
        rimLightNode.eulerAngles = SCNVector3(x: -Float.pi/4, y: -Float.pi/4, z: 0)
        scene.rootNode.addChildNode(rimLightNode)
    }
    
    func setupGame() {
        // Clear previous game elements
        carNode?.removeFromParentNode()
        goalAreaNode?.removeFromParentNode()
        obstacles.forEach { $0.removeFromParentNode() }
        obstacles.removeAll()
        
        // Create ground with physics
        let ground = SCNFloor()
        ground.firstMaterial?.diffuse.contents = UIColor.green
        ground.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(50, 50, 1)
        ground.reflectivity = 0.1
        let groundNode = SCNNode(geometry: ground)
        groundNode.position = SCNVector3(x: 0, y: -0.5, z: 0)
        
        // Add physics to ground
        let groundShape = SCNPhysicsShape(geometry: ground, options: nil)
        let groundBody = SCNPhysicsBody(type: .static, shape: groundShape)
        groundBody.categoryBitMask = CollisionCategory.boundary.rawValue
        groundBody.collisionBitMask = CollisionCategory.car.rawValue
        groundNode.physicsBody = groundBody
        
        scene.rootNode.addChildNode(groundNode)
        
        // Create road with physics
        let road = SCNBox(width: 5, height: 0.1, length: 20, chamferRadius: 0)
        road.firstMaterial?.diffuse.contents = UIColor(#colorLiteral(red: 0.2941176471, green: 0.2941176471, blue: 0.2941176471, alpha: 1))
        let roadNode = SCNNode(geometry: road)
        roadNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        // Add physics to road
        let roadShape = SCNPhysicsShape(geometry: road, options: nil)
        let roadBody = SCNPhysicsBody(type: .static, shape: roadShape)
        roadBody.categoryBitMask = CollisionCategory.boundary.rawValue
        roadBody.collisionBitMask = CollisionCategory.car.rawValue
        roadNode.physicsBody = roadBody
        
        scene.rootNode.addChildNode(roadNode)
        
        // Create driveway (goal area) with physics
        let driveway = SCNBox(width: 3, height: 0.11, length: 4, chamferRadius: 0)
        driveway.firstMaterial?.diffuse.contents = UIColor(#colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1))
        goalAreaNode = SCNNode(geometry: driveway)
        goalAreaNode.position = SCNVector3(x: 0, y: 0, z: -15)
        goalAreaNode.name = "goal"
        
        // Add physics to goal area
        let goalShape = SCNPhysicsShape(geometry: driveway, options: nil)
        let goalBody = SCNPhysicsBody(type: .static, shape: goalShape)
        goalBody.categoryBitMask = CollisionCategory.goal.rawValue
        goalBody.contactTestBitMask = CollisionCategory.car.rawValue
        goalAreaNode.physicsBody = goalBody
        
        scene.rootNode.addChildNode(goalAreaNode)
        
        // Create house (visual only)
        let house = SCNBox(width: 5, height: 3, length: 4, chamferRadius: 0)
        house.firstMaterial?.diffuse.contents = UIColor.brown
        let houseNode = SCNNode(geometry: house)
        houseNode.position = SCNVector3(x: 0, y: 1.5, z: -17)
        scene.rootNode.addChildNode(houseNode)
        
        // Create roof
        let roof = SCNPyramid(width: 6, height: 2, length: 5)
        roof.firstMaterial?.diffuse.contents = UIColor.red
        let roofNode = SCNNode(geometry: roof)
        roofNode.position = SCNVector3(x: 0, y: 4, z: -17)
        scene.rootNode.addChildNode(roofNode)
        
        // Create car
        carNode = createCar()
        
        // Create obstacles
        createObstacles()
        
        // Create invisible walls to prevent car from going off-road
        createBoundaryWalls()
    }
    
    private func createCar() -> SCNNode {
        // Load the detailed car model
        if let carNode = CarModel.loadCar() {
            carNode.position = SCNVector3(0, 0.5, 0)
            carNode.rotation = SCNVector4(0, 1, 0, 0)
            return carNode
        }
        
        // Fallback to basic car if model loading fails
        let carNode = SCNNode()
        let chassis = SCNBox(width: 1.8, height: 0.5, length: 4.5, chamferRadius: 0.1)
        chassis.materials.first?.diffuse.contents = UIColor.red
        carNode.geometry = chassis
        carNode.position = SCNVector3(0, 0.5, 0)
        
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: chassis, options: nil))
        body.mass = 5
        body.restitution = 0.1
        body.friction = 0.5
        body.rollingFriction = 0.5
        body.categoryBitMask = CollisionCategory.car.rawValue
        body.collisionBitMask = CollisionCategory.obstacle.rawValue | CollisionCategory.boundary.rawValue
        body.contactTestBitMask = CollisionCategory.obstacle.rawValue | CollisionCategory.goal.rawValue
        carNode.physicsBody = body
        
        return carNode
    }
    
    private func createObstacles() {
        let obstacleTypes = ["trashbin", "bicycle", "pet", "human"]
        let obstacleCount = 8
        
        for _ in 0..<obstacleCount {
            let type = obstacleTypes.randomElement() ?? "trashbin"
            let obstacleNode: SCNNode
            
            switch type {
            case "trashbin":
                let trashbin = SCNCylinder(radius: 0.4, height: 1)
                trashbin.firstMaterial?.diffuse.contents = UIColor.gray
                obstacleNode = SCNNode(geometry: trashbin)
                obstacleNode.position.y = 0.5
                
            case "bicycle":
                let frame = SCNBox(width: 0.1, height: 0.8, length: 1.5, chamferRadius: 0)
                frame.firstMaterial?.diffuse.contents = UIColor.black
                obstacleNode = SCNNode(geometry: frame)
                obstacleNode.position.y = 0.4
                
            case "pet":
                let pet = SCNSphere(radius: 0.3)
                pet.firstMaterial?.diffuse.contents = UIColor.yellow
                obstacleNode = SCNNode(geometry: pet)
                obstacleNode.position.y = 0.3
                
            case "human":
                let body = SCNCylinder(radius: 0.2, height: 1.2)
                body.firstMaterial?.diffuse.contents = UIColor.blue
                let head = SCNSphere(radius: 0.25)
                head.firstMaterial?.diffuse.contents = UIColor(red: 1, green: 0.8, blue: 0.6, alpha: 1)
                
                obstacleNode = SCNNode(geometry: body)
                let headNode = SCNNode(geometry: head)
                headNode.position.y = 0.8
                obstacleNode.addChildNode(headNode)
                obstacleNode.position.y = 0.6
                
            default:
                obstacleNode = SCNNode()
            }
            
            // Random position within bounds but not too close to car or goal
            let xPos = Float.random(in: -4.0...4.0)
            let zPos = Float.random(in: -10.0...8.0)
            
            // Ensure obstacles aren't placed on the car's starting position or goal area
            if abs(xPos) < 2 && zPos > 8 {
                continue
            }
            
            obstacleNode.position.x = xPos
            obstacleNode.position.z = zPos
            obstacleNode.name = "obstacle"
            
            // Add physics
            let shape = SCNPhysicsShape(geometry: obstacleNode.geometry!, options: nil)
            let body = SCNPhysicsBody(type: .static, shape: shape)
            body.categoryBitMask = CollisionCategory.obstacle.rawValue
            body.contactTestBitMask = CollisionCategory.car.rawValue
            obstacleNode.physicsBody = body
            
            scene.rootNode.addChildNode(obstacleNode)
            obstacles.append(obstacleNode)
        }
    }
    
    private func createBoundaryWalls() {
        let wallThickness: CGFloat = 0.5
        let wallHeight: CGFloat = 2.0
        let roadLength: CGFloat = 20
        let roadWidth: CGFloat = 5
        
        // Left wall
        let leftWall = SCNBox(width: wallThickness, height: wallHeight, length: roadLength, chamferRadius: 0)
        leftWall.firstMaterial?.diffuse.contents = UIColor.clear
        let leftWallNode = SCNNode(geometry: leftWall)
        leftWallNode.position = SCNVector3(x: Float(-roadWidth/2 - wallThickness/2), y: Float(wallHeight/2), z: 0)
        
        // Right wall
        let rightWall = SCNBox(width: wallThickness, height: wallHeight, length: roadLength, chamferRadius: 0)
        rightWall.firstMaterial?.diffuse.contents = UIColor.clear
        let rightWallNode = SCNNode(geometry: rightWall)
        rightWallNode.position = SCNVector3(x: Float(roadWidth/2 + wallThickness/2), y: Float(wallHeight/2), z: 0)
        
        // Front wall (near car starting position)
        let frontWall = SCNBox(width: roadWidth + wallThickness*2, height: wallHeight, length: wallThickness, chamferRadius: 0)
        frontWall.firstMaterial?.diffuse.contents = UIColor.clear
        let frontWallNode = SCNNode(geometry: frontWall)
        frontWallNode.position = SCNVector3(x: 0, y: Float(wallHeight/2), z: Float(roadLength/2 + wallThickness/2))
        
        // Back wall (near house)
        let backWall = SCNBox(width: roadWidth + wallThickness*2, height: wallHeight, length: wallThickness, chamferRadius: 0)
        backWall.firstMaterial?.diffuse.contents = UIColor.clear
        let backWallNode = SCNNode(geometry: backWall)
        backWallNode.position = SCNVector3(x: 0, y: Float(wallHeight/2), z: Float(-roadLength/2 - wallThickness/2))
        
        // Add physics to walls
        for wallNode in [leftWallNode, rightWallNode, frontWallNode, backWallNode] {
            let shape = SCNPhysicsShape(geometry: wallNode.geometry!, options: nil)
            let body = SCNPhysicsBody(type: .static, shape: shape)
            body.categoryBitMask = CollisionCategory.boundary.rawValue
            body.collisionBitMask = CollisionCategory.car.rawValue
            wallNode.physicsBody = body
            scene.rootNode.addChildNode(wallNode)
        }
    }
    
    func updateDirection(_ direction: ControlPadView.Direction?) {
        activeDirection = direction
    }
    
    // MARK: - SCNSceneRendererDelegate
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let carBody = carNode.physicsBody else { return }
        
        // Limit frame rate to avoid too frequent updates
        if time - lastUpdateTime < 0.016 { return } // ~60 FPS
        lastUpdateTime = time
        
        // Update car position in view model
        let carPos = carNode.presentation.position
        gameViewModel?.updateCarPosition(SIMD3<Float>(x: Float(carPos.x), y: Float(carPos.y), z: Float(carPos.z)))
        
        // Handle car movement based on active direction
        if let direction = activeDirection {
            var force = SCNVector3()
            var torque = SCNVector4()
            
            switch direction {
            case .up:
                force = SCNVector3(x: 0, y: 0, z: -moveSpeed)
            case .down:
                force = SCNVector3(x: 0, y: 0, z: moveSpeed/2) // Slower reverse
            case .left:
                torque = SCNVector4(x: 0, y: rotationSpeed, z: 0, w: 0)
            case .right:
                torque = SCNVector4(x: 0, y: -rotationSpeed, z: 0, w: 0)
            }
            
            // Apply force relative to car's orientation
            let carOrientation = carNode.presentation.orientation
            let rotatedForce = force.rotated(by: carOrientation)
            
            // Apply force at the center of mass
            carBody.applyForce(rotatedForce, asImpulse: false)
            
            // Apply torque for rotation
            if direction == .left || direction == .right {
                carBody.applyTorque(torque, asImpulse: false)
            }
        }
        
        // Apply some damping to make controls feel more natural
        carBody.angularVelocity = SCNVector4(
            x: carBody.angularVelocity.x * 0.9,
            y: carBody.angularVelocity.y * 0.9,
            z: carBody.angularVelocity.z * 0.9,
            w: carBody.angularVelocity.w * 0.9
        )
        
        // Limit maximum speed
        let maxSpeed: Float = 5.0
        let speed = carBody.velocity.length()
        if speed > maxSpeed {
            carBody.velocity = carBody.velocity.normalized() * maxSpeed
        }
    }
    
    // MARK: - SCNPhysicsContactDelegate
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        
        // Check if car hit an obstacle
        if (nodeA.name == "car" && nodeB.name == "obstacle") ||
           (nodeA.name == "obstacle" && nodeB.name == "car") {
            DispatchQueue.main.async {
                self.gameViewModel?.gameOver()
            }
        }
        
        // Check if car reached goal
        if (nodeA.name == "car" && nodeB.name == "goal") ||
           (nodeA.name == "goal" && nodeB.name == "car") {
            DispatchQueue.main.async {
                self.gameViewModel?.gameSuccess()
            }
        }
    }
}

// Collision categories
struct CollisionCategory: OptionSet {
    let rawValue: Int
    
    static let car = CollisionCategory(rawValue: 1 << 0)
    static let obstacle = CollisionCategory(rawValue: 1 << 1)
    static let goal = CollisionCategory(rawValue: 1 << 2)
    static let boundary = CollisionCategory(rawValue: 1 << 3)
}

// MARK: - Extensions
extension SCNVector3 {
    func length() -> Float {
        return sqrtf(x*x + y*y + z*z)
    }
    
    func normalized() -> SCNVector3 {
        let len = length()
        return SCNVector3(x: x/len, y: y/len, z: z/len)
    }
    
    static func * (vector: SCNVector3, scalar: Float) -> SCNVector3 {
        return SCNVector3(x: vector.x * scalar, y: vector.y * scalar, z: vector.z * scalar)
    }
    
    func rotated(by orientation: SCNQuaternion) -> SCNVector3 {
        let q = orientation
        let v = SIMD3<Float>(x, y, z)
        
        let qv = SIMD3<Float>(q.x, q.y, q.z)
        let uv = simd_cross(qv, v)
        let uuv = simd_cross(qv, uv)
        
        let rotated = v + 2 * (q.w * uv + uuv)
        return SCNVector3(rotated.x, rotated.y, rotated.z)
    }
}

extension SCNQuaternion {
    init(_ simdQuat: simd_quatf) {
        self.init(x: simdQuat.vector.x, y: simdQuat.vector.y, z: simdQuat.vector.z, w: simdQuat.vector.w)
    }
}

// MARK: - AssetLoader
// Scene/AssetLoader.swift
class AssetLoader {
    static func loadScene(named name: String) -> SCNScene? {
        guard let scene = SCNScene(named: "\(name).scn") else {
            print("Failed to load scene: \(name)")
            return nil
        }
        return scene
    }
    
    static func loadNode(from scene: SCNScene?) -> SCNNode? {
        guard let scene = scene else { return nil }
        
        // Clone the root node to avoid issues with multiple references
        let node = scene.rootNode.clone()
        
        // Fix materials for better rendering
        node.fixMaterials()
        
        return node
    }
}

extension SCNNode {
    func fixMaterials() {
        // Recursively fix materials for node and all child nodes
        self.geometry?.materials.forEach { material in
            material.lightingModel = .physicallyBased
            material.isDoubleSided = true
        }
        
        for child in childNodes {
            child.fixMaterials()
        }
    }
}
