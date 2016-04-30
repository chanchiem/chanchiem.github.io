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

class PWStaticObject: SKShapeNode
{
    var skObj: SKShapeNode?
    
    // Color of the highlights around selected nodes.
    private static var standardHighlightColor = UIColor.blueColor()
    
    // Flag that will determine if this object can be moved by the
    // game scene.
    private var movable: Bool       = true
    private var selectable: Bool    = true
    private var metricScale         = 100   // Factor to convert pixel units to metric units
    private var staticObjectID      = -1    // Unique ID Assigned to each sprite.
    private var selected            = true  // Flag that determines if the object is selected by the scene.
    private var glowNode: SKShapeNode?      // The node representing the glow of this object.
    private var values: [Float] = []


    
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
    
    static func isPWStaticObject(node: SKNode) -> Bool {
        let pwObj = node as? PWStaticObject
        
        if (pwObj == nil) { return false}
        return (pwObj!.isSprite());
    }

    // ##############################################################
    //  These Functions modify the parameters of each of the gadgets
    // ##############################################################
    
    func editRamp(scale: CGFloat, location: CGPoint, height: CGFloat, base: CGFloat, angle: CGFloat, friction: CGFloat) {
        // save new values
        self.values = [Float(scale), Float(position.x), Float(position.y), Float(height), Float(base), Float(angle), Float(friction)]
        // degrees to radians 
        let angleInDegrees = degToRad(Float(angle))
        let polygonPath = CGPathCreateMutable()
        
        CGPathMoveToPoint(polygonPath, nil, -scale*base/2, -scale*base*CGFloat(Darwin.tan(Float(angleInDegrees)))/2)
        CGPathAddLineToPoint(polygonPath, nil,scale*(base/2), -scale*base*CGFloat(Darwin.tan(Float(angleInDegrees)))/2)
        CGPathAddLineToPoint(polygonPath, nil, -scale*base/2, scale*base*CGFloat(Darwin.tan(Float(angleInDegrees)))/2)
        CGPathAddLineToPoint(polygonPath, nil, -scale*base/2 , -scale*base*CGFloat(Darwin.tan(Float(angleInDegrees)))/2)
        self.path = polygonPath
        self.strokeColor = UIColor.blackColor()
        self.fillColor = UIColor.blackColor()
        
        self.physicsBody = SKPhysicsBody(polygonFromPath: polygonPath)
        self.physicsBody?.dynamic = false
        self.physicsBody?.restitution = 0
        self.physicsBody?.friction = friction
        self.position = location
    }
    
    func editPlatform(scale: CGFloat, location: CGPoint, length: CGFloat, width: CGFloat,  rotation: CGFloat, friction: CGFloat) {
        // save new values
        self.values = [Float(scale), Float(position.x), Float(position.y), Float(length), Float(width), Float(rotation), Float(friction)]
        let polygonPath = CGPathCreateMutable()
        CGPathMoveToPoint(polygonPath, nil, -scale*length/2, -scale*width/2)
        CGPathAddLineToPoint(polygonPath, nil, scale*length/2, -scale*width/2)
        CGPathAddLineToPoint(polygonPath, nil, scale*length/2, scale*width/2)
        CGPathAddLineToPoint(polygonPath, nil, -scale*length/2, scale*width/2)
        CGPathAddLineToPoint(polygonPath, nil, -scale*length/2 , -scale*width/2)
        self.path = polygonPath
        self.strokeColor = UIColor.blackColor()
        self.fillColor = UIColor.blackColor()
        
        self.physicsBody = SKPhysicsBody(polygonFromPath: polygonPath)
        self.physicsBody?.dynamic = false
        self.physicsBody?.restitution = 0
        self.physicsBody?.friction = friction
        self.position = location
    }
    
    func editWall(scale: CGFloat, location: CGPoint, height : CGFloat, width: CGFloat,  rotation: CGFloat, friction: CGFloat) {
        // save new values
        self.values = [Float(scale), Float(position.x), Float(position.y), Float(height), Float(width), Float(rotation), Float(friction)]
        let polygonPath = CGPathCreateMutable()
        CGPathMoveToPoint(polygonPath, nil, -scale*width/2, -scale*height/2)
        CGPathAddLineToPoint(polygonPath, nil, scale*width/2, -scale*height/2)
        CGPathAddLineToPoint(polygonPath, nil, scale*width/2, scale*height/2)
        CGPathAddLineToPoint(polygonPath, nil, -scale*width/2, scale*height/2)
        CGPathAddLineToPoint(polygonPath, nil, -scale*width/2 , -scale*height/2)
        self.path = polygonPath
        self.strokeColor = UIColor.blackColor()
        self.fillColor = UIColor.blackColor()
        
        self.physicsBody = SKPhysicsBody(polygonFromPath: polygonPath)
        self.physicsBody?.dynamic = false
        self.physicsBody?.restitution = 0
        self.physicsBody?.friction = friction
        self.position = location
    }
    func editRound(scale: CGFloat, location: CGPoint, radius: CGFloat, other: CGFloat,  other2: CGFloat, friction: CGFloat) {
        // save new values
        self.values = [Float(scale), Float(position.x), Float(position.y), Float(radius), Float(other), Float(other2), Float(friction)]
        let polygonPath = CGPathCreateMutable()
        CGPathMoveToPoint(polygonPath, nil, 0, -radius)
        CGPathAddArc(polygonPath, nil, CGFloat(0), CGFloat(0), CGFloat(radius),CGFloat(-M_PI_2), CGFloat(M_PI_2*3), false);
        self.path = polygonPath
        self.strokeColor = UIColor.blackColor()
        self.physicsBody = SKPhysicsBody(edgeLoopFromPath: polygonPath)
        
        self.physicsBody?.dynamic = false
        self.physicsBody?.restitution = 0
        self.physicsBody?.friction = friction
        self.position = location
    }

    func getProperties(gadgetType: String) -> [Float] {
        self.values[1] = Float(self.position.x)
        self.values[2] = Float(self.position.y)
        return self.values
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
    
//    // Returns the angle from this object to sprite relative to
//    // the horizontal x axis.
//    func angleTo(sprite: PWObject) -> CGFloat {
//        let n1 = self.getPos();
//        let n2 = sprite.getPos();
//        let deltax = n1.x - n2.x
//        let deltay = n1.y - n2.y
//        
//        let angle = atan2f(Float(deltay), Float(deltax))
//        return CGFloat(angle);
//    }
    
    // Highlights the node. Currently used when being selected.
    func highlight(color: UIColor) {
        let size = CGSize(width: 40, height: 40)
        let glow = SKShapeNode.init(rectOfSize: size)
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
    convenience init(objectStringName: String, position: CGPoint, isMovable: Bool, isSelectable: Bool) {
        self.init()

        // Create path for drawing a triangle
        let polygonPath = CGPathCreateMutable()
        CGPathMoveToPoint(polygonPath, nil, 0, 0)
        if (objectStringName == "Ramp") {
            CGPathMoveToPoint(polygonPath, nil, -50, -50)
            CGPathAddLineToPoint(polygonPath, nil, 50, -50)
            CGPathAddLineToPoint(polygonPath, nil, -50, 50)
            CGPathAddLineToPoint(polygonPath, nil, -50 , -50)
            self.init(path: polygonPath)
            self.strokeColor = UIColor.blackColor()
            self.fillColor = UIColor.blackColor()
            self.physicsBody = SKPhysicsBody(polygonFromPath: polygonPath)
            self.values = [1, Float(position.x), Float(position.y), 100, 100, 45,0] // default values
        }
        // create rectangle path flatform
        if (objectStringName == "Platform") {
            CGPathMoveToPoint(polygonPath, nil, -50, 0)
            CGPathAddLineToPoint(polygonPath, nil, 50, 0)
            CGPathAddLineToPoint(polygonPath, nil, 50, 5)
            CGPathAddLineToPoint(polygonPath, nil, -50, 5)
            CGPathAddLineToPoint(polygonPath, nil, -50 , 0)
            self.init(path: polygonPath)
            self.strokeColor = UIColor.blackColor()
            self.fillColor = UIColor.blackColor()
            self.physicsBody = SKPhysicsBody(polygonFromPath: polygonPath)
             self.values = [1, Float(position.x), Float(position.y), 100, 5, 0, 0] // default values
        }
        if (objectStringName == "Wall") {
            CGPathMoveToPoint(polygonPath, nil, -50, -250)
            CGPathAddLineToPoint(polygonPath, nil, 50, -250)
            CGPathAddLineToPoint(polygonPath, nil, 50, 250)
            CGPathAddLineToPoint(polygonPath, nil, -50, 250)
            CGPathAddLineToPoint(polygonPath, nil, -50 , -250)
            self.init(path: polygonPath)
            self.strokeColor = UIColor.blackColor()
            self.fillColor = UIColor.blackColor()
            self.physicsBody = SKPhysicsBody(polygonFromPath: polygonPath)
            self.values = [1, Float(position.x), Float(position.y), 500, 100, 0, 0] // default values
        }
        if (objectStringName == "Round") {
                CGPathMoveToPoint(polygonPath, nil, 0, -100)
                CGPathAddArc(polygonPath, nil, CGFloat(0), CGFloat(0), CGFloat(100),CGFloat(-M_PI_2), CGFloat(M_PI_2*3), false);
                self.init(path: polygonPath)
                self.strokeColor = UIColor.blackColor()
                self.physicsBody = SKPhysicsBody(edgeLoopFromPath: polygonPath)
                self.values = [1, Float(position.x), Float(position.y), 100, 0, 0, 0] // default values
            }
        if (objectStringName == "Pulley") {
            CGPathMoveToPoint(polygonPath, nil, 0, -20)
            CGPathAddArc(polygonPath, nil, CGFloat(0), CGFloat(0), CGFloat(20), CGFloat(-M_PI_2), CGFloat(M_PI_2*3), false);
            self.init(path: polygonPath)
            self.strokeColor = UIColor.blackColor()
            self.fillColor = UIColor.grayColor()
            self.physicsBody = SKPhysicsBody(polygonFromPath: polygonPath)
        }
       
       
        self.movable = isMovable
        self.selectable = isSelectable
        self.position = position
        self.name = objectStringName
        self.physicsBody?.friction = 0
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.restitution = 0.0
        self.physicsBody?.dynamic = false
        self.physicsBody?.contactTestBitMask = PhysicsCategory.All;
    }

    
    // Don't know why this is needed. Swift semantics...
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(coder: aDecoder);
        //        fatalError("init(coder:) has not been implemented")
    }
    
    // ##############################################################
    // Helper Functions
    // ##############################################################
    
    func degToRad(degrees: Float) -> Float {
        // M_PI is defined in Darwin.C.math
        return Float(M_PI) * 2.0 * degrees / 360.0
    }
}