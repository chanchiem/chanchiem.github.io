//
//  GameScene.swift
//  PhysWiz
//
//  Created by James Lin on 3/21/16.
//  Copyright (c) 2016 Intuition. All rights reserved.
//

import SpriteKit

private let movableNodeName = "movable"

class GameScene: SKScene {
    var stopped = true
    var button: SKShapeNode! = nil
    var flag = shapeType.BALL;
    var shapeArray = [shapeType]()
    var viewController: GameViewController!
    // The selected object for parameters
    var selectedShape: SKShapeNode! = nil
    var selectedNode = SKShapeNode()
    var objectProperties: [SKShapeNode: [Float]]!
    var counter = 0
    // temporary variable to signify start or simulation
    var start = 0
    // saves the color of the currently selected node
    var savedColor = SKColor.whiteColor()
    
    enum shapeType{
        case BALL
        case RECT
    }
    
    
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
        /* Setup your scene here */
        self.addChild(self.createFloor())
        self.addChild(self.pausePlay())
        objectProperties = [SKShapeNode: [Float]]()
        physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        // INIT Shape arrays to call later in flag function
        shapeArray.append(shapeType.BALL)
        shapeArray.append(shapeType.RECT)
    }
    
    // Creates a floor for the physics simulation.
    func createFloor() -> SKSpriteNode {
        let floor = SKSpriteNode(color: SKColor.brownColor(), size: CGSizeMake(self.frame.size.width, 20))
        floor.anchorPoint = CGPointMake(0, 0)
        floor.name = "floor"
        floor.physicsBody = SKPhysicsBody(edgeLoopFromRect: floor.frame)
        floor.physicsBody?.dynamic = false
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
    
    // Returns the ball! Make sure you add it to the skscene yourself!
    func createBall(position: CGPoint) -> SKShapeNode {
        let ball = SKShapeNode(circleOfRadius: 20.0)
        let positionMark = SKShapeNode(circleOfRadius: 6.0)
        
        ball.fillColor = SKColor(red: CGFloat(arc4random() % 256) / 256.0, green: CGFloat(arc4random() % 256) / 256.0, blue: CGFloat(arc4random() % 256) / 256.0, alpha: 1.0)
        ball.position = position
        ball.name = movableNodeName
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 20.0)
        ball.physicsBody?.dynamic = !stopped
        ball.physicsBody?.restitution = 0.7
        ball.physicsBody?.friction = 0
        ball.physicsBody?.linearDamping = 0
        
        positionMark.fillColor = SKColor.blackColor()
        positionMark.position.y = -12
        ball.addChild(positionMark)
        return ball
    }
    
    // return parameters of given object
    func getParameters(object: SKShapeNode) -> [Float]{
        var input = [Float]()
        input.insert(Float((object.physicsBody?.mass)!), atIndex: shapePropertyIndex.MASS.rawValue)
        input.insert(Float((object.position.x)), atIndex: shapePropertyIndex.PX.rawValue)
        input.insert(Float((object.position.y)), atIndex: shapePropertyIndex.PY.rawValue)
        input.insert(Float((object.physicsBody?.velocity.dx)!), atIndex: shapePropertyIndex.VX.rawValue)
        input.insert(Float((object.physicsBody?.velocity.dy)!), atIndex: shapePropertyIndex.VY.rawValue)
        input.insert(Float((object.physicsBody?.angularVelocity)!), atIndex: shapePropertyIndex.ANG_V.rawValue)
        return input
    }
    
    // set parameters of given object from input box
    // DEVELOPER'S NOTE: CHANGE THE FUNCTION OF THIS SO THAT IT CHANGES
    // THE PARAMETERS OF A GIVEN OBJECT GIVEN A PARAMETER (SUCH AS AN ARRAY).
    // THEN TO MAKE IT INTERACT WITH THE TEXTFIELDS, GAMEVIEWCONTROLLER
    // WILL CALL THIS TO ENACT THE CHANGES
    func setParameters(object: SKShapeNode) {
        let values = viewController.getInput
        if Float(values()[0]) != nil {object.physicsBody?.mass = CGFloat(Float(values()[0])!)}
        if Float(values()[1]) != nil {object.position.x = CGFloat(Float(values()[1])!)}
        if Float(values()[2]) != nil {object.position.y = CGFloat(Float(values()[2])!)}
        if Float(values()[3]) != nil {object.physicsBody?.velocity.dx = CGFloat(Float(values()[3])!)}
        if Float(values()[4]) != nil {object.physicsBody?.velocity.dy = CGFloat(Float(values()[4])!)}
        // make acceleration x object.physicsBody?.mass = CGFloat(Int(values()[3])!)
        if Float(values()[5]) != nil && Float(values()[6]) != nil {object.physicsBody?.applyForce(CGVector(dx: CGFloat(Float(values()[5])!), dy: CGFloat(Float(values()[6])!)))}
 
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
    func saveAllObjectProperties() -> [SKShapeNode: [Float]]
    {
        var propertyDict = [SKShapeNode: [Float]]()
        for object in self.children {
            if (isShapeObject(object)) {
                let shape = object as! SKShapeNode
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
    func restoreAllobjectProperties(inputDictionary: [SKShapeNode: [Float]])
    {
        if (inputDictionary.count == 0) { return } // input contains nothing
        
        for (object, properties) in inputDictionary {
            if (isShapeObject(object)) {
                
                // Note: This format is based on the getObjectProperties function.
                object.physicsBody?.mass = CGFloat(properties[0])
                object.position.x = CGFloat(properties[1])
                object.position.y = CGFloat(properties[2])
                object.physicsBody?.velocity.dx = CGFloat(properties[3])
                object.physicsBody?.velocity.dy = CGFloat(properties[4])
                object.physicsBody?.angularVelocity = CGFloat(properties[5])
            }
        }
    }


    // Returns the Rectangle! Make sure you add it to the skscene yourself!
    func createRectangle(position: CGPoint) -> SKShapeNode {
        let dimensions = CGSizeMake(40, 40);
        let rect = SKShapeNode(rectOfSize: dimensions)
        
        rect.fillColor = SKColor(red: CGFloat(arc4random() % 256) / 256.0, green: CGFloat(arc4random() % 256) / 256.0, blue: CGFloat(arc4random() % 256) / 256.0, alpha: 1.0)
        rect.position = position
        rect.name = movableNodeName
        
        rect.physicsBody = SKPhysicsBody(rectangleOfSize: dimensions)
        rect.physicsBody?.dynamic = !stopped
        rect.physicsBody?.restitution = 0.7
        
        return rect
    }
    
    // Checks to see if the location that is valid (i.e. if it's actually a point on the game scene plane itself)
    // The button is not considered a valid point.
    func checkValidPoint(location: CGPoint) -> Bool {
        if(nodeAtPoint(location).name == button.name) {
            return false
        }
        if(nodeAtPoint(location).name == movableNodeName) {
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


    func setFlag(index: Int) {
        flag = shapeArray[index]
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let location:CGPoint = touch.locationInNode(self)
            let floor:SKNode? = self.childNodeWithName("floor")
            let touchedNode = self.nodeAtPoint(location)
            // If the person selected a node, set it as the selected node.
            if touchedNode is SKShapeNode && touchedNode.name == movableNodeName {
                print("touchedNode ran")
                // reset color of old selected node
                if selectedShape != nil {
                    selectedShape.fillColor = savedColor
                }
                viewController.setsInputBox(getParameters(touchedNode as! SKShapeNode))
                selectedShape = touchedNode as! SKShapeNode
                // set selected node to black color
                savedColor = selectedShape.fillColor
                selectedShape.fillColor = SKColor.blackColor()
            }
            if floor?.containsPoint(location) != nil {
                
            //NSLog("Client requesting to create at %f, %f", location.x, location.y)
                
                // Make sure the point that is being touched is part of the game scene plane is part of the
                // game
                if(checkValidPoint(location) && stopped) {
                    
                    // Creates an object based on what was toggled. All new objects created
                    // become the newly selected node.
                    switch flag {
                        case .BALL:
                            if stopped {
                            self.addChild(self.createBall(location))
                        }
                        case .RECT:
                            if stopped {
                            self.addChild(self.createRectangle(location))
                        }
                    }
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
                if (stopped) {
                    restoreAllobjectProperties(objectProperties)
                }
                
                button.physicsBody?.dynamic = false   // Keeps pause play button in place
                
                // Updates the value of the variable 'stopped'
                if (stopped) {
                    stopped = false
                    //self.viewController.tableView!.alpha = 0
                    UIView.animateWithDuration(1.5, animations: {self.viewController.shapesTableView!.alpha = 0})
                } else {
                    stopped = true
                    UIView.animateWithDuration(1.5, animations: {self.viewController.shapesTableView!.alpha = 1})
                }

            }

        }
    }
    
    /* Called before each frame is rendered */
    override func update(currentTime: CFTimeInterval) {
        // continously update values of parameters for selected object
        counter += 1
        if (counter % 20 == 0) {
            if selectedShape != nil && !stopped  {
                viewController.setsStaticBox(getParameters(selectedShape))
            }
            // updates selected shapes values with input box values when stopped
            if (selectedShape != nil && stopped && start == 0) {
                setParameters(selectedShape)
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
}
