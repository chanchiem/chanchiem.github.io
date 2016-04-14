//
//  GameScene.swift
//  PhysWiz
//
//  Created by James Lin on 3/21/16.
//  Copyright (c) 2016 Intuition. All rights reserved.
//

import SpriteKit
import Foundation

private let movableNodeName = "movable"

class GameScene: SKScene {
    var ropeOn = false; // The flag for the ropes.
    var ropeNode1: SKSpriteNode! = nil;
    var ropeNode2: SKSpriteNode! = nil;
    
    var stopped = true
    var button: SKShapeNode! = nil
    var flag = shapeType.CIRCLE;
    var shapeArray = [shapeType]()
    var viewController: GameViewController!
    // The selected object for parameters
    var selectedShape: SKSpriteNode! = nil
    var objectProperties: [SKSpriteNode: [Float]]!
    var counter = 0
    // temporary variable to signify start or simulation
    var start = 0
    // used to scale all parameters from pixels to other metric system 
    // not applied to mass or values not associated with pixels
    var metricScale = Float(100)
    // saves the color of the currently selected node
    var savedColor = SKColor.whiteColor()
    let background = SKSpriteNode(imageNamed: "bg.png")
    enum shapeType: String {
        case CIRCLE = "circle.png"
        case SQUARE = "square.png"
        case TRIANGLE = "triangle.png"
        case CRATE = "crate.png"
        case BASEBALL = "baseball.png"
        case BRICKWALL = "brickwall.png"
        case AIRPLANE = "airplane.png"
        case BIKE = "bike.png"
        case CAR = "car.png"
    }
    // keeps track of time parameter
    var timeCounter = 0
    // This enumeration defines the standard indices for each of the shape properties.
    // To use, you will have to obtain the raw value of the enumeration:
    // shapePropertyIndex(rawValue)
    enum shapePropertyIndex : Int{
        case MASS   = 0
        case PX     = 1
        case PY     = 2
        case VX     = 3
        case VY     = 4
        case ANG_V  = 5
        case AX     = 6
        case AY     = 7
        case FX     = 8
        case FY     = 9

    }
    
    
    // The game view controller will be the strong owner of the gamescene
    // This reference holds the link of communication between the interface
    // and the game scene itself.
    override func didMoveToView(view: SKView) {
        // Adds a background to the scene
        /*background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.size.height = self.size.height
        background.size.width = self.size.width
        background.zPosition = -1
        self.addChild(background)*/
        // make gravity equal to 981 pixels
        self.physicsWorld.gravity = CGVectorMake(0.0, -6.54);
        /* Setup your scene here */
        self.addChild(self.createFloor())
        self.addChild(self.pausePlay())
        objectProperties = [SKSpriteNode: [Float]]()
        physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        // INIT Shape arrays to call later in flag function
        shapeArray.append(shapeType.CIRCLE)
        shapeArray.append(shapeType.SQUARE)
        shapeArray.append(shapeType.TRIANGLE)
        shapeArray.append(shapeType.CRATE)
        shapeArray.append(shapeType.BASEBALL)
        shapeArray.append(shapeType.BRICKWALL)
        shapeArray.append(shapeType.AIRPLANE)
        shapeArray.append(shapeType.BIKE)
        shapeArray.append(shapeType.CAR)
    }
    
    // Creates a floor for the physics simulation.
    func createFloor() -> SKSpriteNode {
        let floor = SKSpriteNode(color: SKColor.brownColor(), size: CGSizeMake(self.frame.size.width, 20))
        floor.anchorPoint = CGPointMake(0, 0)
        floor.name = "floor"
        floor.physicsBody = SKPhysicsBody(edgeLoopFromRect: floor.frame)
        floor.physicsBody?.dynamic = false
        floor.physicsBody?.friction = 0
        return floor
    }
    
    // Creates a node that will act as a pause play button for the user.
    func pausePlay() -> SKShapeNode {
        button = SKShapeNode(circleOfRadius: 20.0)
        button.fillColor = SKColor(red: 0.0, green: 0.0, blue: 256.0, alpha: 1)
        button.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        button.name = "button"
        button.physicsBody = SKPhysicsBody(circleOfRadius: 20.0)
        button.physicsBody?.dynamic = false
        return button
    }
    
    
    // return parameters of given object from either the object itself or dictionary
   func getParameters(object: SKSpriteNode) -> [Float]{
        var input = [Float]()
        // handle properties that remain the same when static and when dynamic
        input.insert(Float((object.physicsBody?.mass)!), atIndex: shapePropertyIndex.MASS.rawValue)
        input.insert(Float((object.position.x))/metricScale, atIndex: shapePropertyIndex.PX.rawValue)
        input.insert(Float((object.position.y))/metricScale, atIndex: shapePropertyIndex.PY.rawValue)
        // handle properties that lose values when static 
        if stopped {
            if objectProperties[object] != nil {
                for i in Range(start: 3, end: 10) {
                    input.insert(Float(objectProperties[object]![i]), atIndex: i)
                }
            }
            else {
                for i in Range(start: 3, end: 10) {
                input.insert(0, atIndex: i)
                }
            }
        }
        else {
            input.insert(Float((object.physicsBody?.velocity.dx)!)/metricScale, atIndex: shapePropertyIndex.VX.rawValue)
            input.insert(Float((object.physicsBody?.velocity.dy)!)/metricScale, atIndex: shapePropertyIndex.VY.rawValue)
            input.insert(Float((object.physicsBody?.angularVelocity)!)/metricScale, atIndex: shapePropertyIndex.ANG_V.rawValue)
            for i in Range(start: 6, end: 10) {
                input.insert(Float(objectProperties[object]![i]), atIndex: i)
            }
        }
        return input
    }
    
    // Checks to see if the passed in node is a valid
    // shape object (meaning that it's either a ball or rectangle)
    func isShapeObject(object: SKNode) -> Bool {
        // DEVELOPER NOTES: CHANGE THIS IN THE FUTURE SO THAT IT
        // ITERATES THROUGH A DATA STRUCTURE THAT CONTAINS ALL
        // THE CORRECT OBJECTS! THIS CURRENTLY IS A HACKISH ADDITION BECAUSE
        // EVERYTHING THAT WE'VE IMPLEMENTED SO FAR HAS NOT BEEN MODULARIZED
        // TO CONTAIN AN OBJECT SHAPE CLASS.
        if (object.name == nil) { return false }
        if (object.name == movableNodeName) { return true }
        return false
    }
    
    // Stores all object properties in the scene (velocity, position, and acceleration) to a data structure.
    // This function will be called when the user presses pause. 
    // Returns a dictionary with keys as each shape in the scene and
    // the values as a float array with the shape properties as defined
    // in the shapePropertyIndex enumeration.
    func saveAllObjectProperties() -> [SKSpriteNode: [Float]]
    {
        var propertyDict = [SKSpriteNode: [Float]]()
        for object in self.children {
            if (isShapeObject(object)) {
                let shape = object as! SKSpriteNode
                propertyDict[shape] = getParameters(shape)
            }
        }
        
        return propertyDict
    }
    
    // Restores all the object properties of each shape given an dictionary
    // with keys as each shape in the scene and values as a float array 
    // with the shape properties as defined in the shapePropertyindex enumeration.
    // DEVELOPER'S NOTE: MAKE SURE TO ADD FORCES TO THIS
    // WITH THE CURRENT IMPLMENETATION OF getParameters,
    // WE ARE MISSING FORCES/ACCELERATION
    func restoreAllobjectProperties(inputDictionary: [SKSpriteNode: [Float]])
    {
        if (inputDictionary.count == 0) { return } // input contains nothing
        
        for (object, properties) in inputDictionary {
            if (isShapeObject(object)) {
    
                // Note: This format is based on the getObjectProperties function.
                object.physicsBody?.mass = CGFloat(properties[0])
                object.position.x = CGFloat(properties[1]*metricScale)
                object.position.y = CGFloat(properties[2]*metricScale)
                object.physicsBody?.velocity.dx = CGFloat(properties[3]*metricScale)
                object.physicsBody?.velocity.dy = CGFloat(properties[4]*metricScale)
                object.physicsBody?.angularVelocity = CGFloat(properties[5]*metricScale)

            }
        }
    }

    // Creates an SKSpriteNode object at the location marked by position using the image passed in.
    func createObject(position: CGPoint, image: String) -> SKSpriteNode {
        let size = CGSize(width: 40, height: 40)
        var object = SKSpriteNode()
        let objectTexture = SKTexture(imageNamed: image)
        object = SKSpriteNode(texture: objectTexture)
        object.size = size
        object.position = position
        object.name = movableNodeName
        object.physicsBody = SKPhysicsBody(texture: objectTexture, size: size)
        object.physicsBody?.dynamic = !stopped
        object.physicsBody?.mass = 1
        object.physicsBody?.friction = 0
        object.physicsBody?.linearDamping = 0
        object.physicsBody?.restitution = 0.7
        objectProperties[object] = getParameters(object)
        return object
    }
    
    // Checks to see if the location that is valid (i.e. if it's actually a point on the game scene plane itself)
    // The button is not considered a valid point.
    func checkValidPoint(location: CGPoint) -> Bool {
        if(nodeAtPoint(location).name == movableNodeName || nodeAtPoint(location) == button ) {
            return false
        }
        return true
    }
    
    // Checks to see if there is a node at the location
    // Returns the shape if it's true, otherwise return 
    // the false.
    func checkLocforNode(location: CGPoint) -> SKNode! {
        if(nodeAtPoint(location) == self) {
            return nil
        }
        return nodeAtPoint(location)
        
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let location:CGPoint = touch.locationInNode(self)
            let floor:SKNode? = self.childNodeWithName("floor")
            let touchedNode = self.nodeAtPoint(location)
            // If the person selected a node, set it as the selected node.
            if touchedNode is SKSpriteNode && touchedNode.name == movableNodeName {
                // Applying the rope!!!
                if (ropeOn == true) {
                    if (ropeNode1 == nil) {
                        ropeNode1 = touchedNode as! SKSpriteNode
                    } else if(ropeNode2 == nil) {
                        ropeNode2 = touchedNode as! SKSpriteNode
                        if (ropeNode1 != ropeNode2) {
                            self.addChild(Rope.init(parentScene: self, node: ropeNode1, node: ropeNode2, texture: "rope.png"))
                        }
                        ropeNode2 = nil;
                        ropeNode1 = nil;
                    }
                } else {
                    selectedShape = touchedNode as! SKSpriteNode
                    viewController.setsInputBox(objectProperties[selectedShape]!)
                }
            }
            if floor?.containsPoint(location) != nil {
                
            //NSLog("Client requesting to create at %f, %f", location.x, location.y)
                
                // Make sure the point that is being touched is part of the game scene plane is part of the
                // game
                if(checkValidPoint(location) && stopped) {
                    var objecttype = shapeArray[viewController.getObjectFlag()]
                    let img = String(objecttype).lowercaseString + ".png"
                    self.addChild(self.createObject(location, image: img))
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            // Gives the pause play button the ability to pause and play a scene
            if button.containsPoint(location) {
                // temp variable to signify start of program
                if start == 0 {
                    viewController.changeParameterBox()
                    start = 1;
                }
                if (!stopped) {
                    objectProperties = saveAllObjectProperties()
                }
                for shape in self.children {
                    if (stopped) {
                        // Playing
                        shape.physicsBody?.dynamic = true
                    }
                    else if (!stopped) {
                        // Paused
                        shape.physicsBody?.dynamic = false
                    }
                }
                // apply forces and  velocities to object as it can not be done before
                // dynamic is set to true or the force and velocity value are set to 0
                restoreAllobjectProperties(objectProperties)
                button.physicsBody?.dynamic = false   // Keeps pause play button in place
                
                // Updates the value of the variable 'stopped'
                if (stopped) {
                    // being used to try and figure put the time component
                  var timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "runtime", userInfo: nil, repeats: true)
                    stopped = false
                } else {
         

                }

            }

        }
    }
    //being used to try and figure out the time component
    func runtime() {
        timeCounter += 1
        if timeCounter == 4 {
            for shape in self.children {
                if (stopped) {
                    // Playing
                    shape.physicsBody?.dynamic = true
                }
                else if (!stopped) {
                    // Paused
                    shape.physicsBody?.dynamic = false
                }
 
        }
        
    }
    }
    /* Called before each frame is rendered */
    override func update(currentTime: CFTimeInterval) {        // continously update values of parameters for selected object
        counter += 1
        if (counter % 20 == 0) {
            if selectedShape != nil && !stopped  {
                viewController.setsStaticBox(getParameters(selectedShape))
            }
        }

            // updates selected shapes values with input box values when stopped
            if (selectedShape != nil && stopped && start == 0) {
                var values = objectProperties[selectedShape]!
                let input = viewController.getInput()
                for i in Range(start: 0, end: 10) {
                    if Float(input[i]) != nil {
                     values[i] = Float(input[i])!
                    }
                }
                objectProperties[selectedShape] = values
                restoreAllobjectProperties(objectProperties)
            }
        
            if (start == 1) {
                for object in self.children {
                    if (isShapeObject(object)) {
                        let shape = object as! SKSpriteNode
                        shape.physicsBody?.applyForce(CGVector(dx: CGFloat(objectProperties[shape]![shapePropertyIndex.AX.rawValue]*metricScale) , dy: CGFloat(objectProperties[shape]![shapePropertyIndex.AY.rawValue]*metricScale)));
            }
        }

    }
    }
    override func didSimulatePhysics() {
        self.enumerateChildNodesWithName("ball", usingBlock: { (node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            if node.position.y < 0 {
                node.removeFromParent()
            }
        })
    }

    func panForTranslation(translation: CGPoint) {
        if selectedShape != nil {
            let position = selectedShape.position
            if selectedShape.name! == movableNodeName {
                selectedShape.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
                //changes values in the input box to the position it is dragged to
                viewController.setsInputBox(getParameters(selectedShape))
                
                // Connects selectedShape to its nearestNodes
                let nearest = nearestNodes(selectedShape)
                for node in nearest {
                    let joinNodes = SKPhysicsJointFixed.jointWithBodyA(selectedShape.physicsBody!, bodyB: node.physicsBody!, anchor: node.position)
                    self.physicsWorld.addJoint(joinNodes)
                }
            }
        }
        
    
        // Add this when we have a background image
        /*else {
            background.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
        }*/
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        let positionInScene = touch?.locationInNode(self)
        let previousPosition = touch?.previousLocationInNode(self)
        let translation = CGPoint(x: positionInScene!.x - previousPosition!.x, y: positionInScene!.y - previousPosition!.y)
        if stopped {
            panForTranslation(translation)
        }
    }
    
    // Returns an array of all nodes within a certain distance away from the queryNode.
    func nearestNodes(queryNode: SKSpriteNode) -> [SKNode] {
        let joinDist: CGFloat = 40.0
        var array = [SKNode]()
        for object in self.children {
            let dx = queryNode.position.x - object.position.x
            let dy = queryNode.position.y - object.position.y
            
            let distance = sqrt(dx*dx + dy*dy)
            if (distance <= joinDist) {
                array.append(object)
            }
        }
        return array
    }
}
