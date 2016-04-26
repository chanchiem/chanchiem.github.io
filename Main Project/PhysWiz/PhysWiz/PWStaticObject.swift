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


// String to its object type representation
// This is what will be passed in when we want to create
// a new object. Each enumeration defines the types of objects
// that the user can create in the GameScene.
enum StaticObjectType: String {
    case RAMP     = "ramp.png"
    case PLATFORM   = "platform.png"
    case WALL      = "wall.png"
    case PULLEY    = "pulley.png"
}


class PWStaticObject: SKSpriteNode
{
    var skObj: SKSpriteNode?
    
    // This static dictionary contains the map from the string
    // representation of an object to the string file name of the
    // texture that will reprsent it.
    // Example: "ball" will refer to "ball.png" which will later
    // be used to actually apply the texture for the object.
    private static var objectTextureMap = [String: String]()
    
    // Color of the highlights around selected nodes.
    private static var standardHighlightColor = UIColor.blueColor()
    
    // Flag that will determine if this object can be moved by the
    // game scene.
    private var movable: Bool       = true
    private var selectable: Bool    = true
    private var metricScale         = 100   // Factor to convert pixel units to metric units
    private var staticObjectID            = -1    // Unique ID Assigned to each sprite.
    private var selected            = true  // Flag that determines if the object is selected by the scene.
    private var glowNode: SKShapeNode?      // The node representing the glow of this object.

    
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
    func makeUnmovable() {
        self.movable = false;
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
    
    // Checks if the PWObject is a sprite (i.e. any shape that will
    // contain physical properties).
    func isSprite() -> Bool {
        return self.movable;
    }
    
    // Returns the unique object ID
    func getID() -> Int {
        return self.staticObjectID;
    }
    
    // Sets the unique object ID
    func setID(id: Int) {
        self.staticObjectID = id;
    }
    
    // Signifies that this object is selected in the game scene.
    func setSelected() {
        self.highlight(PWStaticObject.standardHighlightColor)
        self.selected = true;
    }
    
    // Unselects the object in the game scene.
    // Also unhighlights it.
    func setUnselected() {
        self.unhighlight()
        self.selected = false;
    }
    
    // Checks if this object's flag is currently represented as selected.
    // Also highlights it.
    func isSelected() -> Bool {
        return self.selected;
    }
    
    
    // ##############################################################
    //
    //  Parameter functions belong here! Implement all the functions
    //  that call for or modify specific parameters that are not native to
    //  spritekit (Acceleration, Moment of Inertia, Rotational Accel.
    //
    // ##############################################################
    
    // Object numerical properties
    func setPos(position: CGPoint) { self.position = position }
    func setPos(x: CGFloat, y: CGFloat) { self.position = CGPointMake(x, y) }
    func getPos() -> CGPoint { return self.position; }
    
    func setFriction(friction: CGFloat) { self.physicsBody?.friction = friction }
    func getFriction() -> CGFloat { return (self.physicsBody?.friction)! }
    
    func setHeight(height: CGFloat) {
        self.yScale = height
    }
    func setWidth(width: CGFloat) {
        self.xScale = width
    }
    // ##############################################################
    //
    //  Descriptor functions:
    //  Functions that aid in finding information about other sprites
    //  relative to this one.
    //
    // ##############################################################
    
    // Finds the nonscaled distance between two sprite nodes. It is
    // nonscaled in the sense that it returns the absolute distance
    // in terms of pixels rather than the scaled metric.
    func distanceTo(sprite: PWObject) -> CGFloat {
        assert(PWObject.isPWObject(sprite));
        
        let n1 = self.position
        let n2 = sprite.position
        let deltax = n1.x - n2.x
        let deltay = n1.y - n2.y
        let distance = sqrt(deltax * deltax + deltay*deltay)
        
        return distance;
    }
    
    // Returns the angle from this object to sprite relative to
    // the horizontal x axis.
    func angleTo(sprite: PWObject) -> CGFloat {
        let n1 = self.getPos();
        let n2 = sprite.getPos();
        let deltax = n1.x - n2.x
        let deltay = n1.y - n2.y
        
        let angle = atan2f(Float(deltay), Float(deltax))
        return CGFloat(angle);
    }
    
    // Highlights the node. Currently used when being selected.
    func highlight(color: UIColor) {
        let glow = SKShapeNode.init(rectOfSize: self.size)
        glow.position = CGPoint(x: 0, y: 0)
        glow.fillColor = color;
        glow.alpha = 0.5
        glow.blendMode = SKBlendMode.Subtract
        
        self.glowNode = glow
        self.addChild(glow);
    }
    
    // Unhighlights the node.
    func unhighlight() {
        if (glowNode == nil) { return }
        glowNode!.removeFromParent()
    }
    
    
    // ##############################################################
    
    // Initializes the sprite object. This is what we will use to create
    // PWObjects set at specific coordinates.
    required init(objectStringName: String, position: CGPoint, isMovable: Bool, isSelectable: Bool) {
        
        let objTextureName = objectStringName + "png"
        let objectTexture = SKTexture.init(imageNamed: objTextureName)
        let textureSize = objectTexture.size()
        let white = UIColor.init(white: 1.0, alpha: 1.0);
        super.init(texture: objectTexture, color: white, size: textureSize)
        let size = CGSize(width: 40, height: 40)
        self.movable = isMovable
        self.selectable = isSelectable
        self.size = size
        self.position = position
        self.name = objectStringName
        self.physicsBody = SKPhysicsBody(texture: objectTexture, size: size)
        self.physicsBody?.mass = 1
        self.physicsBody?.friction = 0
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.restitution = 0.0
        self.physicsBody?.contactTestBitMask = PhysicsCategory.All;
    }

    
    // Don't know why this is needed. Swift semantics...
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(coder: aDecoder);
        //        fatalError("init(coder:) has not been implemented")
    }
    
}