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
    var gadgetNode1: SKSpriteNode! = nil;
    var gadgetNode2: SKSpriteNode! = nil;
    
    var springglobal = [SKSpriteNode: [SKSpriteNode]]() // Spring that maps to two other nodes.
    var initialHeight = [SKSpriteNode: CGFloat]();
    
    var stopped = true
    var button: SKSpriteNode! = nil
    var stop: SKSpriteNode! = nil
    var trash: SKSpriteNode! = nil
    var bg: SKSpriteNode! = nil
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
        case BLACK = "black.png"
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
        // make gravity equal to 981 pixels
        self.physicsWorld.gravity = CGVectorMake(0.0, -6.54);
        /* Setup your scene here */
        self.addChild(self.createFloor())
        self.addChild(self.createPausePlay())
        self.addChild(self.createStop())
        self.addChild(self.createTrash())
        self.addChild(self.createBG())
        objectProperties = [SKSpriteNode: [Float]]()
        //physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x: 0, y: 0, width: bg.size.width, height: bg.size.height))
        //physicsBody = SKPhysicsBody(rectangleOfSize: bg.size)
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
        shapeArray.append(shapeType.BLACK)
    }
    
    // Creates a background for the gamescene
    func createBG() -> SKSpriteNode {
        bg = SKSpriteNode(imageNamed: "bg")
        bg.anchorPoint = CGPointZero
        bg.name = "background"
        bg.size.height = self.size.height * 2
        bg.size.width = self.size.width * 3
        bg.zPosition = -2
        return bg
    }
    
    // Creates a floor for the physics simulation.
    func createFloor() -> SKSpriteNode {
        let floor = SKSpriteNode(color: SKColor.brownColor(), size: CGSizeMake(self.frame.size.width * 3, 20))
        floor.anchorPoint = CGPointZero
        floor.name = "floor"
        floor.physicsBody = SKPhysicsBody(edgeLoopFromRect: floor.frame)
        floor.physicsBody?.dynamic = false
        floor.physicsBody?.friction = 0
        return floor
    }
    
    // Creates a node that will act as a pause play button for the user.
    func createPausePlay() -> SKSpriteNode {
        button = SKSpriteNode(imageNamed: "play.png")
        button.position = CGPoint(x: self.size.width - self.size.width/15, y: self.size.height - self.size.height/10)
        button.size = CGSize(width: 50, height: 50)
        button.name = "button"
        return button
    }
    
    // Creates a trash bin on the lower right hand side of the screen
    func createTrash() -> SKSpriteNode {
        trash = SKSpriteNode(imageNamed: "trash.png")
        trash.position = CGPoint(x: self.size.width - self.size.width/15, y: self.size.height/10)
        trash.zPosition = -1
        trash.size = CGSize(width: 60, height: 60)
        trash.name = "trash"
        return trash
    }
    
    // Creates a node that will act as a stop button for the user.
    func createStop() -> SKSpriteNode {
        stop = SKSpriteNode(imageNamed: "stop.png")
        stop.position = CGPoint(x: self.size.width - self.size.width/8, y: self.size.height - self.size.height/10)
        stop.size = CGSize(width: 50, height: 50)
        stop.name = "stop"
        return stop
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
        object.physicsBody?.friction = 0.7
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
    
    func createRopeBetweenNodes(node1: SKSpriteNode, node2: SKSpriteNode) {
        let node1Mid = node1.position
        let node2Mid = node2.position
        let spring = SKPhysicsJointLimit.jointWithBodyA(node1.physicsBody!, bodyB: node2.physicsBody!, anchorA: node1Mid, anchorB: node2Mid)
        self.physicsWorld.addJoint(spring)
        
        self.addChild(Rope.init(parentScene: self, node: node1, node: node2, texture: "rope.png"))
    }
    
    func createSpringBetweenNodes(node1: SKSpriteNode, node2: SKSpriteNode) {
        let n1 = node1.position
        let n2 = node2.position
        let deltax = n1.x - n2.x
        let deltay = n1.y - n2.y
        let distance = sqrt(deltax * deltax + deltay*deltay)
        
        // Create the joint between the two objects
        let spring = SKPhysicsJointSpring.jointWithBodyA(node1.physicsBody!, bodyB: node2.physicsBody!, anchorA: n1, anchorB: n2)
        spring.damping = 0.5
        spring.frequency = 0.5
        self.physicsWorld.addJoint(spring)
        
        // Actually create a spring image with physics properties.
        let springobj = SKSpriteNode(imageNamed: "spring.png")
        
        let nodes = [node1, node2];
        springglobal[springobj] = nodes;
        
        let angle = atan2f(Float(deltay), Float(deltax))
        springobj.zRotation = CGFloat(angle + 1.57) // 1.57 because image is naturally vertical
        initialHeight[springobj] = springobj.size.height;
        springobj.yScale = distance/springobj.size.height;
        let xOffset = deltax / 2
        let yOffset = deltay / 2
        springobj.position = CGPoint.init(x: n1.x - xOffset, y: n1.y - yOffset)
        springobj.zPosition = -1
//        springobj.physicsBody = SKPhysicsBody.init(rectangleOfSize: springobj.size)
//        springobj.physicsBody?.dynamic = false;
        self.addChild(springobj);
        
    
    }
    
    func updateSprings()
    {
        for (spring, nodes) in springglobal {
            let springnode1 = nodes[0];
            let springnode2 = nodes[1];
            
            let deltax = springnode1.position.x - springnode2.position.x
            let deltay = springnode1.position.y - springnode2.position.y
            let distance = sqrt(deltax * deltax + deltay*deltay)
            spring.yScale = distance/initialHeight[spring]!;
            let xOffset = deltax / 2
            let yOffset = deltay / 2
            let angle = atan2f(Float(deltay), Float(deltax))
            spring.zRotation = CGFloat(angle + 1.57) // 1.57 because image is naturally vertical
            spring.position = CGPoint.init(x: springnode1.position.x - xOffset, y: springnode1.position.y - yOffset)
        }
    }
    
    
    func createRodBetweenNodes(node1: SKSpriteNode, node2: SKSpriteNode) {
        let n1 = node1.position
        let n2 = node2.position
        
        let deltax = n1.x - n2.x
        let deltay = n1.y - n2.y
        let distance = sqrt(deltax * deltax + deltay*deltay)
        let dimension = CGSizeMake(distance, 4)
        let rod = SKShapeNode(rectOfSize: dimension)
        rod.physicsBody = SKPhysicsBody.init(rectangleOfSize: dimension)
        rod.physicsBody?.dynamic = false;
        
        let angle = atan2f(Float(deltay), Float(deltax))
        rod.zRotation = CGFloat(angle)
        let xOffset = deltax / 2
        let yOffset = deltay / 2
        rod.position = CGPoint.init(x: n1.x - xOffset, y: n1.y - yOffset)
        rod.zPosition = -1
        
        rod.fillColor = UIColor.blueColor()
        
        self.addChild(rod);
        
        let rodJoint1 = SKPhysicsJointFixed.jointWithBodyA(node1.physicsBody!, bodyB: rod.physicsBody!, anchor: n1)
        let rodJoint2 = SKPhysicsJointFixed.jointWithBodyA(node2.physicsBody!, bodyB: rod.physicsBody!, anchor: n2)
        self.physicsWorld.addJoint(rodJoint1)
        self.physicsWorld.addJoint(rodJoint2)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let location:CGPoint = touch.locationInNode(bg)
            let floor:SKNode? = self.childNodeWithName("floor")
            let touchedNode = self.nodeAtPoint(location)
            // If the person selected a node, set it as the selected node.
            if touchedNode is SKSpriteNode && touchedNode.name == movableNodeName {
                
                // Applying the rope!!!
                if (viewController.getGadgetFlag() != 0) { // Rope
                    if (gadgetNode1 == nil) {
                        gadgetNode1 = touchedNode as! SKSpriteNode
                    } else if(gadgetNode2 == nil) {
                        gadgetNode2 = touchedNode as! SKSpriteNode
                        if (gadgetNode1 != gadgetNode2) {
                            if (viewController.getGadgetFlag() == 1) { createRopeBetweenNodes(gadgetNode1, node2: gadgetNode2) }
                            if (viewController.getGadgetFlag() == 2) { createSpringBetweenNodes(gadgetNode1, node2: gadgetNode2) }
                            if (viewController.getGadgetFlag() == 3) { createRodBetweenNodes(gadgetNode1, node2: gadgetNode2) }
                        }
                        gadgetNode2 = nil;
                        gadgetNode1 = nil;
                    }
                } else {
                    selectedShape = touchedNode as! SKSpriteNode
                    viewController.setsInputBox(objectProperties[selectedShape]!)
                }
            }
            if floor?.containsPoint(location) == false {
                // Make sure the point that is being touched is part of the game scene plane is part of the game
                if(checkValidPoint(location) && stopped) {
                    let objectType = shapeArray[viewController.getObjectFlag()]
                    if (objectType == shapeType.BLACK) {
                        selectedShape = nil
                    } else {
                        let img = String(objectType).lowercaseString + ".png"
                        let newObj = self.createObject(location, image: img)
                        self.addChild(newObj)
                        //selectedShape = newObj
                        //self.addChild(self.createObject(location, image: img))
                    }
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            // Removes the selectedShape if it's over the trash bin
            if trash.containsPoint(location) {
                objectProperties.removeValueForKey(selectedShape)
                selectedShape.removeFromParent()
                selectedShape = nil
            }
            // Removes all non-essential nodes from the gamescene
            if stop.containsPoint(location) {
                for node in self.children {
                    node.removeFromParent()
                    stopped = true
                    button.texture = SKTexture(imageNamed: "play.png")
                }
                self.addChild(self.createFloor())
                self.addChild(self.createPausePlay())
                self.addChild(self.createStop())
                self.addChild(self.createTrash())
                self.addChild(self.createBG())
            }
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
                    button.texture = SKTexture(imageNamed: "pause.png")
                } else {
                    stopped = true
                    button.texture = SKTexture(imageNamed: "play.png")
                }
            }
            
        }
    }
    
    //being used to try and figure out the time component
    func runtime() {
        timeCounter += 1
        var time = Int(viewController.getTime())
        if timeCounter ==  time {
            for shape in self.children {
                if (stopped) {
                    // Playing
//                    shape.physicsBody?.dynamic = true
                }
                else if (!stopped) {
                    // Paused
//                    shape.physicsBody?.dynamic = false
                }
                button.physicsBody?.dynamic = false 
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
        if (selectedShape != nil && stopped) { //&& start == 0) {
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
        updateSprings();
    }
    override func didSimulatePhysics() {
        self.enumerateChildNodesWithName("ball", usingBlock: { (node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            if node.position.y < 0 {
                node.removeFromParent()
            }
        })
    }
    
    // Bounds how far the user can pan the gamescene according to the size of the background.
    func boundLayerPos(aNewPosition: CGPoint) -> CGPoint {
        let winSize = self.size
        var retval = aNewPosition
        retval.x = CGFloat(min(retval.x, 0))
        retval.x = CGFloat(max(retval.x, -(bg.size.width) + winSize.width))
        retval.y = CGFloat(min(retval.y, 0))
        retval.y = CGFloat(max(retval.y, -(bg.size.height) + winSize.height))
        
        return retval
    }

    // Allows users to drag and drop selectedShapes and the background
    func panForTranslation(translation: CGPoint) {
        if selectedShape != nil {
            let position = selectedShape.position
            if selectedShape.name! == movableNodeName {
                selectedShape.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
                //changes values in the input box to the position it is dragged to
                viewController.setsInputBox(getParameters(selectedShape))
                
                // Connects selectedShape to its nearestNodes
                //connectNodes(selectedShape)
            }
        }
        else {
            let position = bg.position
            let aNewPosition = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
            bg.position = self.boundLayerPos(aNewPosition)
            moveObjects(translation)
        }
    }
    
    // Moves the objects that are on the screen by the amount that the background is being moved
    func moveObjects(translation: CGPoint) {
        let movableObjects = ["movable", "floor"]
        for node in self.children {
            if node.name == nil || movableObjects.contains(node.name!) {
                let position = node.position
                let aNewPosition = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
                let boundedPosition = self.boundLayerPos(aNewPosition)
                if node.name == "floor" {
                    node.position = boundedPosition
                } else {
                    if bg.position.x != 0.0 && bg.position.x != -2*self.size.width {
                        node.position.x = aNewPosition.x
                    } else {
                        node.position.x = position.x
                    }
                    if bg.position.y != 0.0 && bg.position.y != -self.size.height {
                        node.position.y = aNewPosition.y
                    } else {
                        node.position.y = position.y
                    }
                }
            }
        }
    }
    
    // Makes sure the user can only drag objects when the simulation is paused and sets up for panForTranslation
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
        let joinDist: CGFloat = 30.0
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
    
    // Connects the selectedNode with all nodes in its vicinity.
    func connectNodes(selectedNode: SKSpriteNode) {
        let nearest = nearestNodes(selectedShape)
        for node in nearest {
            let midPoint = CGPoint(x: (selectedNode.position.x + node.position.x)/2, y: (selectedNode.position.y + node.position.y)/2)
            let joinNodes = SKPhysicsJointFixed.jointWithBodyA(selectedShape.physicsBody!, bodyB: node.physicsBody!, anchor: midPoint)
            self.physicsWorld.addJoint(joinNodes)
        }
    }
}
