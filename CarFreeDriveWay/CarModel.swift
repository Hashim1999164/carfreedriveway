import SceneKit

class CarModel {
    static func loadCar() -> SCNNode? {
        guard let carScene = SCNScene(named: "CarModel.scn") else {
            print("Failed to load car model")
            return nil
        }
        
        let carNode = carScene.rootNode.childNodes.first
        setupCarPhysics(carNode)
        setupCarMaterials(carNode)
        return carNode
    }
    
    private static func setupCarPhysics(_ node: SCNNode?) {
        guard let node = node else { return }
        
        // Create a simplified physics shape for the car
        let box = SCNBox(width: 1.8, height: 0.5, length: 4.5, chamferRadius: 0.1)
        let shape = SCNPhysicsShape(geometry: box, options: nil)
        
        let body = SCNPhysicsBody(type: .dynamic, shape: shape)
        body.mass = 5
        body.restitution = 0.1
        body.friction = 0.5
        body.rollingFriction = 0.5
        body.categoryBitMask = CollisionCategory.car.rawValue
        body.collisionBitMask = CollisionCategory.obstacle.rawValue | CollisionCategory.boundary.rawValue
        body.contactTestBitMask = CollisionCategory.obstacle.rawValue | CollisionCategory.goal.rawValue
        
        node.physicsBody = body
    }
    
    private static func setupCarMaterials(_ node: SCNNode?) {
        guard let node = node else { return }
        
        // Apply materials to all child nodes
        node.enumerateChildNodes { (childNode, _) in
            if let geometry = childNode.geometry {
                // Apply appropriate materials based on node name
                switch childNode.name {
                case "body":
                    applyCarPaintMaterial(to: geometry)
                case "windows":
                    applyGlassMaterial(to: geometry)
                case "wheels":
                    applyWheelMaterials(to: geometry)
                case "lights":
                    applyLightMaterials(to: geometry)
                default:
                    break
                }
            }
        }
    }
    
    private static func applyCarPaintMaterial(to geometry: SCNGeometry) {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(#colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1))
        material.metalness.contents = 0.9
        material.roughness.contents = 0.1
        material.normal.contents = "car_normal"
        material.ambientOcclusion.contents = "car_ao"
        geometry.materials = [material]
    }
    
    private static func applyGlassMaterial(to geometry: SCNGeometry) {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(white: 0.9, alpha: 0.3)
        material.metalness.contents = 0.0
        material.roughness.contents = 0.1
        material.transparency = 0.7
        material.reflective.contents = UIColor.white
        material.reflective.intensity = 0.5
        geometry.materials = [material]
    }
    
    private static func applyWheelMaterials(to geometry: SCNGeometry) {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.black
        material.roughness.contents = 0.8
        material.normal.contents = "tire_normal"
        geometry.materials = [material]
    }
    
    private static func applyLightMaterials(to geometry: SCNGeometry) {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.yellow
        material.emission.contents = UIColor.yellow
        material.emission.intensity = 2.0
        material.transparency = 0.8
        geometry.materials = [material]
    }
} 