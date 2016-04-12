//
//  PWObject.swift
//  PhysWiz
//
//  Created by Chiem Saeteurn on 4/11/16.
//  Copyright © 2016 Intuition. All rights reserved.
//
// Class that represents each actual sprite object in the scene.
// This will contain acceleration, velocity, force, and other 
// important object properties that will facilitate in 
// solving the physics problems.

import Foundation
import SpriteKit


class PWObject: SKSpriteNode
{
    var skObj: SKSpriteNode?
    
    // False if the static class has been initialized, meaning that
    // the object texture map has been populated.
    private static var hasStaticBeenInit = false;
    
    // This static dictionary contains the map from the string
    // representation of an object to the string file name of the
    // texture that will reprsent it. 
    // Example: "ball" will refer to "ball.jpg" which will later
    // be used to actually apply the texture for the object.
    private static var objectTextureMap = [String: String]()
    
    // Flag that will determine if this object can be moved by the
    // game scene.
    private var movable: Bool       = true
    private var selectable: Bool    = true
    private var metricScale         = 100   // Factor to convert pixel units to metric units
    private var isDegrees           = true  // Checks to see if calculations should be made in rads or degs.
    
    // String to its object type representation
    // This is what will be passed in when we want to create
    // a new object.
    enum shapeType: String {
        case CIRCLE     = "circle"
        case SQUARE     = "square"
        case TRIANGLE   = "triangle"
        case CRATE      = "crate"
        case BASEBALL   = "baseball"
        case BRICKWALL  = "brickwall"
        case AIRPLANE   = "airplane"
        case BIKE       = "bike"
        case CAR        = "car"
        case BUTTON     = "button"
    }
    
    
    // This initializes the static variables if it hasn't been initialized yet.
    // This MUST be called when at least one instance of the PWObject
    // has been created.
    private static func initStaticVariables()
    {
        if (!hasStaticBeenInit) { return }
        hasStaticBeenInit = true;
        
        objectTextureMap["circle"]      = "circle.jpg"
        objectTextureMap["square"]      = "square.jpg"
        objectTextureMap["triangle"]    = "triangle.jpg"
        objectTextureMap["crate"]       = "crate.jpg"
        objectTextureMap["baseball"]    = "baseball.jpg"
        objectTextureMap["brickwall"]   = "brickwall.jpg"
        objectTextureMap["airplane"]    = "airplane.jpg"
        objectTextureMap["bike"]        = "bike.jpg"
        objectTextureMap["car"]         = "car.jpg"
        objectTextureMap["button"]      = "button.jpg"
    }
    
    // Returns the string name of the image texture that represents
    // the object. Returns nil if the texture name is not in the
    // dictionary.
    static func getObjectTextureName(objectName: String) -> String!
    {
        if let val = objectTextureMap[objectName] {
            return val
        } else {
            return nil
        }
    }
    
    // Checks if the object name exists as a PWObject.
    // Returns true if it does, otherwise it returns false.
    static func doesObjectExist(objectName: String) -> Bool
    {
        if (objectTextureMap[objectName]) != nil {
            return true
        } else {
            return false
        }
    }
    
    // ##############################################################
    //
    //  Flag functions belong here! Implement all the functions
    //  that call to or write to a flag variable here.
    //
    // ##############################################################
    
    
    // Makes this node movable by setting the movable flag to true.
    // This will allow the user to be able to move the object.
    func makeMovable() {
        self.movable = true;
    }
    
    // Makes this node selectable by setting the selectable flag to true.
    // This will allow the user to be able to select the object.
    // Selecting the object allows the user to see its properties
    func makeSelectable() {
        self.movable = true;
    }
    
    // Makes this node movable by setting the movable flag to true.
    // This will allow the user to be able to move the object.
    func isMovable() -> Bool {
        return self.movable;
    }
    
    // Makes this node selectable by setting the selectable flag to true.
    // This will allow the user to be able to move the object.
    func isSelectable() -> Bool {
        return self.selectable;
    }
    
    
    // ##############################################################
    //
    //  Parameter functions belong here! Implement all the functions
    //  that call for or modify specific parameters that are not native to
    //  spritekit (Acceleration, Moment of Inertia, Rotational Accel.
    //
    // ##############################################################
    
    // Object numerical properties
    func setMass(mass: CGFloat) { self.physicsBody?.mass = mass }
    func getMass() -> CGFloat { return (self.physicsBody?.mass)! }
    func setFriction(friction: CGFloat) { self.physicsBody?.friction = friction }
    func getFriction() -> CGFloat { return (self.physicsBody?.friction)! }
    
    
    // Returns the current acceleration of the object.
    func getAcceleration() -> CGFloat {
        // Implement later using change of velocity
        return 1.0
    }
    
    // Returns the current angular acceleration of the object.
    func getAngularAcceleration() -> CGFloat
    {
        return 1.0
    }
    
    // Returns the kinetic energy of the object.
    func getKineticEnergy() -> CGFloat
    {
        let vel = (self.physicsBody?.velocity)!
        let v_squared = (vel.dx * vel.dx) + (vel.dy * vel.dy)
        return (1/2) * (self.physicsBody?.mass)! * (v_squared)
    }
    
    // Returns the momentum of the object.
    func getMomentum() -> CGVector
    {
        let vel = (self.physicsBody?.velocity)!
        let mass = (self.physicsBody?.mass)!
        let momentum = CGVector.init(dx: vel.dx * mass, dy: vel.dy * mass)
        
        return momentum
    }
    
    // Applies instantaneous acceleration to the object.
    // To make it continuous, have it call this function
    // every time step in the update function of GameScene.
    func applyAcceleration(x: CGFloat, y: CGFloat)
    {
        let mass = (self.physicsBody?.mass)!
        let accelerationVector = CGVector.init(dx: x * mass, dy: y * mass)
        self.physicsBody?.applyForce(accelerationVector);
    }
    func applyAcceleration(magnitude: CGFloat, direction: CGFloat) // Polar form
    {
        let mass = (self.physicsBody?.mass)!
        let x = magnitude * cos(direction) * mass
        let y = magnitude * sin(direction) * mass
        let accelerationVector = CGVector.init(dx: x * mass, dy: y * mass)
        self.physicsBody?.applyForce(accelerationVector)
        
    }
    
    // Applys an instaneous force to the object.
    func applyForce(x: CGFloat, y: CGFloat) // Cartesian Form
    {
        self.physicsBody?.applyForce(CGVector.init(dx: x, dy: y))
    }
    func applyForce(magnitude: CGFloat, direction: CGFloat) // Polar form
    {
        let x = magnitude * cos(direction)
        let y = magnitude * sin(direction)
        let vec = CGVector(dx: x, dy: y)
        self.physicsBody?.applyForce(vec)
    }
    
    
    // ##############################################################
    
    // Initializes the sprite object. This is what we will use to create
    // PWObjects set at specific coordinates.
    init(objectStringName: String, position: CGPoint, isMovable: Bool, isSelectable: Bool) {
        PWObject.initStaticVariables(); // Mandatory call to populate static variables.
        
        let objTextureName = PWObject.getObjectTextureName(objectStringName)
        assert(objTextureName != nil, "Error: Initialization of PWObject couldn't find the object passed.")
        
        let objectTexture = SKTexture.init(imageNamed: objTextureName!)
        let textureSize = objectTexture.size()
        let white = UIColor.init(white: 1.0, alpha: 1.0);
        super.init(texture: objectTexture, color: white, size: textureSize)
        
        let size = CGSize(width: 60, height: 60)
        
        self.movable = isMovable
        self.selectable = isSelectable
        
        self.size = size
        self.position = position
        self.name = objectStringName
        self.physicsBody = SKPhysicsBody(texture: objectTexture, size: size)
        self.physicsBody?.mass = 1
        self.physicsBody?.friction = 0
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.restitution = 0.7
    }
    
//    // Initialize object without texture, only color.
//    // This will be used to create a floor.
//    init(objName: String, position: CGPoint, color: UIColor, size: CGSize, isMovable: Bool, isSelectable: Bool)
//    {
//        PWObject.initStaticVariables(); // Mandatory call to populate static variables.
//        super.init(texture: nil, color: color, size: size)
//        
//        self.movable = isMovable
//        self.selectable = isSelectable
//        
//        self.size = size
//        self.position = position
//        self.name = objName
//        self.physicsBody = SKPhysicsBody(texture: nil, size: size)
//        self.physicsBody?.mass = 1
//        self.physicsBody?.friction = 0
//        self.physicsBody?.linearDamping = 0
//        self.physicsBody?.restitution = 0.7
//    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init(coder: aDecoder);
//        fatalError("init(coder:) has not been implemented")
    }
    
}