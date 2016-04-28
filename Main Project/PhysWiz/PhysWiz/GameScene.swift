//
//  GameScene.swift
//  PhysWiz
//
//  Created by James Lin on 3/21/16.
//  Copyright (c) 2016 Intuition. All rights reserved.
//

import SpriteKit
import Foundation

// Contact bitmasks.
struct PhysicsCategory {
    static let None              : UInt32 = 0
    static let All               : UInt32 = UInt32.max
    static let Sprites           : UInt32 = 0b1       // 1
    static let StaticObjects     : UInt32 = 0b10      // 2
}

class GameScene: SKScene , SKPhysicsContactDelegate{
    var gadgetNode1: PWObject! = nil;
    var gadgetNode2: PWObject! = nil;
    
    var springglobal = [SKSpriteNode: [PWObject]]() // Spring that maps to two other nodes. PWOBJECT
    var initialHeight = [SKSpriteNode: CGFloat](); // PWOBJECT
    var labelMap = [PWObject: SKLabelNode](); // Each sk spritenode will have a label associated with it. PWOBJECT
    
    // Maps each object's ID to the object itself.
    var objIdToSprite = [Int: PWObject]();
    
    var pwPaused = true // Paused
    var button: SKSpriteNode! = nil
    var stop: SKSpriteNode! = nil
    var trash: SKSpriteNode! = nil
    
    var background: SKSpriteNode! = nil
    let cam = SKCameraNode()
    var camPos = CGPoint()
    var PWObjects = [PWObject]()
    
    var toggledSprite = shapeType.CIRCLE;
    var shapeArray = [shapeType]();
    var containerVC: containerViewController!
    // The selected object for parameters
    var selectedSprite: PWObject! = nil
    var objectProperties: [PWObject : [Float]]!
    var updateFrameCounter = 0
    // used to scale all parameters from pixels to other metric system
    // not applied to mass or values not associated with pixels
    var pixelToMetric = Float(100)
    
    // gives each object an unique number ID
    var ObjectIDCounter = 0

    
    // keeps track of time parameter
    var runtimeCounter = 0
    
    // Event Organizers and contact delegates!
    var eventorganizer: EventOrganizer! = nil;
    
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
        
        let gestureRecognizer = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
        self.view!.addGestureRecognizer(gestureRecognizer)
        
        self.addChild(self.cam)
        self.camera = cam
        self.camera?.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        camPos = self.camera!.position
        
        /* Setup your scene here */
        cam.addChild(self.createPausePlay())
        cam.addChild(self.createStop())
        cam.addChild(self.createTrash())
        self.addChild(self.createBG())
        self.addChild(PWObject.createFloor(CGSize.init(width: background.size.width, height: 20))) // Floor
        self.physicsWorld.speed = 0
        objectProperties = [PWObject: [Float]]()
        physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x: 0, y: 0, width: background.size.width, height: background.size.height))
        
        if let savedSprites = loadSprites() {
            for obj in savedSprites {
                var values = [Float]()
                values.append(Float(obj.getMass()))
                values.append(Float(obj.getPos().x)/pixelToMetric)
                values.append(Float(obj.getPos().y)/pixelToMetric)
                values.append(Float(obj.getVelocity().dx)/pixelToMetric)
                values.append(Float(obj.getVelocity().dy)/pixelToMetric)
                values.append(Float(obj.getAngularVelocity()))
                values.append(Float(0.0))
                values.append(Float(0.0))
                values.append(Float(0.0))
                values.append(Float(0.0))
                objectProperties[obj] = values
                PWObjects += [obj]
                print(obj)
                print(values)
                self.addChild(obj)
            }
        }
        
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
        
        PWObject.initStaticVariables();
        
        ////////////////////////////////////////////////////////////
        //////////////// Initialize Event Organizers ///////////////
        ////////////////////////////////////////////////////////////
        eventorganizer = EventOrganizer.init(gamescene: self); // Sets contact delegate inside.
    }
    
    
    
    // Creates a background for the gamescene
    func createBG() -> SKSpriteNode {
        background = SKSpriteNode(imageNamed: "bg")
        background.anchorPoint = CGPointZero
        background.name = "background"
        background.size.height = self.size.height * 20
        background.size.width = self.size.width * 30
        background.zPosition = -2
        return background
    }

    // Creates a node that will act as a pause play button for the user.
    func createPausePlay() -> SKSpriteNode {
        button = SKSpriteNode(imageNamed: "play.png")
        button.position.x += self.camera!.position.x/1.1
        button.position.y += self.camera!.position.y/1.4
        button.size = CGSize(width: 50, height: 50)
        button.name = "button"
        return button
    }
    
    // Creates a trash bin on the lower right hand side of the screen
    func createTrash() -> SKSpriteNode {
        trash = SKSpriteNode(imageNamed: "trash.png")
        trash.position.x += self.camera!.position.x/1.1
        trash.position.y -= self.camera!.position.y/1.2
        trash.zPosition = -1
        trash.size = CGSize(width: 60, height: 60)
        trash.name = "trash"
        return trash
    }
    
    // Creates a node that will act as a stop button for the user.
    func createStop() -> SKSpriteNode {
        stop = SKSpriteNode(imageNamed: "stop.png")
        stop.position.x += self.camera!.position.x/1.3
        stop.position.y += self.camera!.position.y/1.4
        stop.size = CGSize(width: 50, height: 50)
        stop.name = "stop"
        return stop
    }
    
    // return parameters of given object from either the object itself or dictionary
   func getParameters(object: PWObject) -> [Float]{
        var parameterOutput = [Float]()
        // handle properties that remain the same when static and when dynamic
        parameterOutput.insert(Float(object.getMass()), atIndex: shapePropertyIndex.MASS.rawValue)
        parameterOutput.insert(Float((object.getPos().x))/pixelToMetric, atIndex: shapePropertyIndex.PX.rawValue)
        parameterOutput.insert(Float((object.getPos().y))/pixelToMetric, atIndex: shapePropertyIndex.PY.rawValue)
        // handle properties that lose values when paused, because velocity goes to zero when paused
        if pwPaused {
            if objectProperties[object] != nil {
                for i in 3 ..< 10 { parameterOutput.insert(Float(objectProperties[object]![i]), atIndex: i) }
            }
            else {
                for i in 3 ..< 10 { parameterOutput.insert(0, atIndex: i) }
            }
        } else {
            parameterOutput.insert(Float((object.getVelocity().dx))/pixelToMetric, atIndex: shapePropertyIndex.VX.rawValue)
            parameterOutput.insert(Float((object.getVelocity().dy))/pixelToMetric, atIndex: shapePropertyIndex.VY.rawValue)
            parameterOutput.insert(Float((object.getAngularVelocity()))/pixelToMetric, atIndex: shapePropertyIndex.ANG_V.rawValue)
            for i in 6 ..< 10 { parameterOutput.insert(Float(objectProperties[object]![i]), atIndex: i) }
        }
        return parameterOutput
    }
    
    // Stores all object properties in the scene (velocity, position, and acceleration) to a data structure.
    // This function will be called when the user presses pause. 
    // Returns a dictionary with keys as each shape in the scene and
    // the values as a float array with the shape properties as defined
    // in the shapePropertyIndex enumeration.
    func saveAllObjectProperties() -> [PWObject: [Float]]
    {
        var propertyDict = [PWObject: [Float]]()
        for object in self.children {
            if (!PWObject.isPWObject(object)) { continue; }
            
            let sprite = object as! PWObject
            if (sprite.isSprite()) {
                propertyDict[sprite] = getParameters(sprite)
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
    func restoreAllobjectProperties(inputDictionary: [PWObject: [Float]])
    {
        if (inputDictionary.count == 0) { return } // input contains nothing
        
        for (sprite, properties) in inputDictionary {
            if (sprite.isSprite()) {
                // Note: This format is based on the getObjectProperties function.
                sprite.setMass (CGFloat(properties[0]))
                sprite.setPos(CGFloat(properties[1]*pixelToMetric), y: CGFloat(properties[2]*pixelToMetric))
                sprite.setVelocity(CGFloat(properties[3]*pixelToMetric), y: CGFloat(properties[4]*pixelToMetric))
                sprite.setAngularVelocity(CGFloat(properties[5]*pixelToMetric))

            }
        }
    }
    
    // Checks to see if the location that is valid (i.e. if it's actually a point on the game scene plane itself)
    // The button is considered a valid point, so long as it is not another PWObject.
    func checkValidPoint(location: CGPoint) -> Bool {
        let nodes = nodesAtPoint(location);
        for node in nodes {
            if(node.name == "button") { return false }
            if(PWObject.isPWObject(node)) { return false }
        }
        
        return true
    }
    
    // Checks to see if there is a node at the location
    // Returns the sprite if it's true, otherwise return
    // the false.
    func checkLocforNode(location: CGPoint) -> SKNode! {
        if(nodeAtPoint(location) == self) {
            return nil
        }
        return nodeAtPoint(location)
        
    }
    
    func createRopeBetweenNodes(node1: PWObject, node2: PWObject) {
        let node1Mid = node1.getPos()
        let node2Mid = node2.getPos()
        let spring = SKPhysicsJointLimit.jointWithBodyA(node1.physicsBody!, bodyB: node2.physicsBody!, anchorA: node1Mid, anchorB: node2Mid)
        self.physicsWorld.addJoint(spring)
        
        self.addChild(Rope.init(parentScene: self, node: node1, node: node2, texture: "rope.png"))
    }
    
    func createSpringBetweenNodes(node1: PWObject, node2: PWObject) {
        let n1 = node1.getPos()
        let n2 = node2.getPos()
        let deltax = n1.x - n2.x
        let deltay = n1.y - n2.y
        let distance = node1.distanceTo(node2)
        
        // Create the joint between the two objects
        let spring = SKPhysicsJointSpring.jointWithBodyA(node1.physicsBody!, bodyB: node2.physicsBody!, anchorA: n1, anchorB: n2)
        spring.damping = 0.5
        spring.frequency = 0.5
        self.physicsWorld.addJoint(spring)
        
        // Actually create a spring image with physics properties.
        let springobj = SKSpriteNode(imageNamed: "spring.png")
        let nodes = [node1, node2];
        springglobal[springobj] = nodes;
        
        let angle = node1.angleTo(node2)
        springobj.zRotation = angle + 1.57 // 1.57 because image is naturally vertical
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
    
    // Scales the springs between objects according to their distances.
    func updateSprings()
    {
        for (spring, nodes) in springglobal {
            let springnode1 = nodes[0];
            let springnode2 = nodes[1];
            
            let deltax = springnode1.position.x - springnode2.position.x
            let deltay = springnode1.position.y - springnode2.position.y
            let distance = springnode1.distanceTo(springnode2)
            spring.yScale = distance/initialHeight[spring]!;
            let xOffset = deltax / 2
            let yOffset = deltay / 2
            let angle = springnode1.angleTo(springnode2)
            spring.zRotation = CGFloat(angle + 1.57) // 1.57 because image is naturally vertical
            spring.position = CGPoint.init(x: springnode1.position.x - xOffset, y: springnode1.position.y - yOffset)
        }
    }
    
    // Updates relative distance labels when an object is being dragged.
    func updateNodeLabels()
    {
        
        // Otherwise, label is on when simulation is NOT running
        for node in self.children
        {
            if (!PWObject.isPWObject(node)) { continue; }
            if (selectedSprite == nil) { return }
            let sprite = node as! PWObject
            if (sprite == selectedSprite) { continue }
            
            if (labelMap[sprite] == nil) {
                let newLabel = SKLabelNode.init(text: "name")
                newLabel.fontColor = UIColor.blackColor();
                newLabel.fontSize = 15.0
                newLabel.fontName = "AvenirNext-Bold"
                labelMap[sprite] = newLabel;
                self.addChild(newLabel);
            }
            
            let label = labelMap[sprite];
            label?.hidden = false;
            let dist = String(selectedSprite.distanceTo(sprite) / CGFloat(pixelToMetric))
            label?.text = truncateString(dist, decLen: 3)
            let pos = sprite.getPos();
            label?.position = CGPoint.init(x: pos.x, y: pos.y + sprite.size.height/2)
        }
    }
    
    // Truncates the string so that it shows only the given
    // amount of numbers after the first decimal.
    // For example:
    // decLen = 3; 3.1023915 would return 3.102
    //
    // If there are no decimals, then it just returns the string.
    func truncateString(inputString: String, decLen: Int) -> String {
        return String(format: "%.\(decLen)f", (inputString as NSString).floatValue)
    }
    
    func hideLabels()
    {
        for node in self.children{
            if (!PWObject.isPWObject(node)) { continue }
            let sprite = node as! PWObject
            let label = labelMap[sprite];
            
            if (label != nil) { label?.hidden = true; }
        }
    }
    
    
    func createRodBetweenNodes(node1: PWObject, node2: PWObject) {
        let n1 = node1.getPos()
        let n2 = node2.getPos()
        let deltax = n1.x - n2.x
        let deltay = n1.y - n2.y
        let distance = node1.distanceTo(node2);
        let angle = node1.angleTo(node2)
        
        let dimension = CGSizeMake(distance, 4)
        let rod = SKShapeNode(rectOfSize: dimension)
        rod.physicsBody = SKPhysicsBody.init(rectangleOfSize: dimension)
        
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


    func createRamp(location:CGPoint){
//        let newObj = self.createObject(location, image: "ramp.png")
//        newObj.size = CGSize(width: 200, height: 200)
//        let objectTexture = SKTexture.init(imageNamed: "ramp.png")
//        newObj.physicsBody = SKPhysicsBody(texture: objectTexture, size: newObj.size)
        let ramp = PWObject.init(objectStringName: "ramp", position: location, isMovable: false, isSelectable: false)
        self.addChild(ramp)
    }
    
    
    // Selects a sprite in the game scene.
    func selectSprite(sprite: PWObject?) {
        let prevSprite = selectedSprite;
        if (prevSprite != nil) { prevSprite.setUnselected() }
        
        // Passed in sprite is nil so nothing is selected now.
        if (sprite == nil) {
            selectedSprite = nil
            return;
        }
        
        selectedSprite = sprite!;
        containerVC.setsInputBox(objectProperties[selectedSprite]!)
        selectedSprite.setSelected();
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let location:CGPoint = touch.locationInNode(background)
            let touchedNode = self.nodeAtPoint(location)
            
            //////////////////////////////////
            //////// CREATE OBJECT ///////////
            //////////////////////////////////
            // Make sure the point that is being touched is part of the game scene plane is part of the game
            if(checkValidPoint(location) && pwPaused) {
                // When clicking outside a In the scene return to main scene
                containerVC.changeToMainView()
                if (containerVC.getGadgetFlag() == 4) {
                    createRamp(location)
                }
                let objectType = shapeArray[containerVC.getObjectFlag()]
                if (objectType == shapeType.BLACK) {
                    self.selectSprite(nil);
                } else {
                    let spriteName = String(objectType).lowercaseString
                    let newObj = PWObject.init(objectStringName: spriteName, position: location, isMovable: true, isSelectable: true)
                    objectProperties[newObj] = getParameters(newObj) /**********************************************/
                    self.ObjectIDCounter += 1
                    newObj.setID(self.ObjectIDCounter);
                    containerVC.addObjectToList(newObj.getID())
                    objIdToSprite[newObj.getID()] = newObj;
                    self.addChild(newObj)
                    self.selectSprite(newObj)
                    PWObjects += [newObj]
                    saveSprites()
                }
                continue;
            }
            
            
            //////////////////////////////////
            //////// APPLY GADGETS ///////////
            //////////////////////////////////
            if (!PWObject.isPWObject(touchedNode)) { continue };
            let sprite = touchedNode as! PWObject
            if (containerVC.getGadgetFlag() != 0) { // Rope
                if (gadgetNode1 == nil) {
                    gadgetNode1 = sprite
                } else if(gadgetNode2 == nil) {
                    gadgetNode2 = sprite
                    if (gadgetNode1 != gadgetNode2) {
                        if (containerVC.getGadgetFlag() == 1) { createRopeBetweenNodes(gadgetNode1, node2: gadgetNode2) }
                        if (containerVC.getGadgetFlag() == 2) { createSpringBetweenNodes(gadgetNode1, node2: gadgetNode2) }
                        if (containerVC.getGadgetFlag() == 3) { createRodBetweenNodes(gadgetNode1, node2: gadgetNode2) }
                    }
                    gadgetNode2 = nil;
                    gadgetNode1 = nil;
                }
            } else {
                self.selectSprite(sprite);
               containerVC.setsInputBox(objectProperties[selectedSprite]!)
            }
            
            
        }
    }
    
    func getObjFromID(ID: Int) -> PWObject {
        let obj = objIdToSprite[ID] as PWObject!
        
        return obj;
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let cameraNodeLocation = cam.convertPoint(location, fromNode: self)
            hideLabels();
            // Removes the selectedShape if it's over the trash bin
            if trash.containsPoint(cameraNodeLocation) {
                objectProperties.removeValueForKey(selectedSprite) /**********************************************/
                selectedSprite.removeFromParent()
                containerVC.removeObjectFromList(selectedSprite.getID())
                self.selectSprite(nil);
            }
            // Removes all non-essential nodes from the gamescene
            if stop.containsPoint(cameraNodeLocation) {
                for node in self.children {
                    if (node != cam) {
                        node.removeFromParent()
                    }
                    pwPaused = true
                    button.texture = SKTexture(imageNamed: "play.png")
                    PWObjects.removeAll()
                    saveSprites()
                }
                containerVC.removeAllFromList()
                let floor = PWObject.createFloor(CGSize.init(width: background.size.width, height: 20))
                self.addChild(floor)
                self.addChild(self.createBG())
            }
            // Gives the pause play button the ability to pause and play a scene
            if button.containsPoint(cameraNodeLocation) {
                if (!pwPaused) { objectProperties = saveAllObjectProperties() } /**********************************************/
                
                // Applies changes made by the user to sprite parameters
                restoreAllobjectProperties(objectProperties) /**********************************************/
                
                // Pause / Resume the world
                if (pwPaused) {
                    // being used to try and figure put the time component
                  //var timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "runtime", userInfo: nil, repeats: true)
                    self.physicsWorld.speed = 1
                    pwPaused = false
                    button.texture = SKTexture(imageNamed: "pause.png")
                } else {
                    self.physicsWorld.speed = 0
                    pwPaused = true
                    button.texture = SKTexture(imageNamed: "play.png")
                    if selectedSprite != nil {
                        containerVC.setsInputBox(objectProperties[selectedSprite]!)
                    }
                }
            }
            
        }
    }
    
    
    //being used to try and figure out the time component
    func runtime() {
        runtimeCounter += 1
        let time = Int(containerVC.getTime())
        if runtimeCounter ==  time {
            if (pwPaused) { self.physicsWorld.speed = 1 }
            else if (!pwPaused) { self.physicsWorld.speed = 0 }
            
            button.physicsBody?.dynamic = false 
        }
    }
    
    /* Called before each frame is rendered */
    override func update(currentTime: CFTimeInterval) {        // continously update values of parameters for selected object
        updateFrameCounter += 1
        if (updateFrameCounter % 20 == 0) {
            if selectedSprite != nil && !pwPaused  {
                containerVC.setsStaticBox(getParameters(selectedSprite))
            }
        }

            // updates selected shapes values with input box values when pwPaused
        if (selectedSprite != nil && pwPaused) {
                var values = objectProperties[selectedSprite]!
                let input = containerVC.getInput()
                for i in 0 ..< 10 {
                    if (Float(input[i]) != nil) { values[i] = Float(input[i])! }
                }
                objectProperties[selectedSprite] = values /**********************************************/
                restoreAllobjectProperties(objectProperties) /**********************************************/
            }
        
        for object in self.children {
            if (!PWObject.isPWObject(object)) { continue };
            let sprite = object as! PWObject

            
            let xComponent = CGFloat(objectProperties[sprite]![shapePropertyIndex.AX.rawValue]*pixelToMetric);
            let yComponent = CGFloat(objectProperties[sprite]![shapePropertyIndex.AY.rawValue]*pixelToMetric);
            sprite.applyForce(xComponent, y: yComponent)
        }

        updateSprings();
        if selectedSprite != nil && !pwPaused {
            self.camera!.position = boundedCamMovement(selectedSprite.position)
        }
    }
    
    
    override func didSimulatePhysics() {
        self.enumerateChildNodesWithName("ball", usingBlock: { (node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            if node.position.y < 0 { node.removeFromParent() }
        })
    }
    
    // Bounds how far the user can pan the gamescene according to the size of the background.
    func boundLayerPos(aNewPosition: CGPoint) -> CGPoint {
        let winSize = self.size
        var retval = aNewPosition
        retval.x = CGFloat(min(retval.x, 0))
        retval.x = CGFloat(max(retval.x, -(background.size.width) + winSize.width))
        retval.y = CGFloat(min(retval.y, 0))
        retval.y = CGFloat(max(retval.y, -(background.size.height) + winSize.height))
        
        return retval
    }

    // Allows users to drag and drop selectedShapes and the background
    func panForTranslation(translation: CGPoint) {
        updateNodeLabels();
        if selectedSprite != nil {
            let position = selectedSprite.position
            if selectedSprite.isMovable() {
                selectedSprite.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
                //changes values in the input box to the position it is dragged to
                containerVC.setsInputBox(getParameters(selectedSprite))
                PWObjects[PWObjects.indexOf(selectedSprite)!].setPos(selectedSprite.position)
                saveSprites()
                
                // Connects selectedShape to its nearestNodes
                //connectNodes(selectedShape)
            }
        }
        else {
            //let position = background.position
            //let aNewPosition = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
            //background.position = self.boundLayerPos(aNewPosition)
            //
            //moveObjects(translation)
            
            let newPosition = CGPoint(x: self.camera!.position.x - translation.x, y: self.camera!.position.y - translation.y)
            self.camera!.position = boundedCamMovement(newPosition)
        }
    }
    
    func boundedCamMovement(newPosition: CGPoint) -> CGPoint {
        
        var retval = newPosition
        
        let lower_bg_x = background.position.x
        let upper_bg_x = background.position.x + background.size.width
        let lower_bg_y = background.position.y
        let upper_bg_y = background.position.y + background.size.height
        
        let lower_cam_x = newPosition.x - (self.size.width * (self.camera?.xScale)!)/2
        let upper_cam_x = newPosition.x + (self.size.width * (self.camera?.xScale)!)/2
        let lower_cam_y = newPosition.y - (self.size.height * (self.camera?.yScale)!)/2
        let upper_cam_y = newPosition.y + (self.size.height * (self.camera?.yScale)!)/2
        
        if (lower_cam_x < lower_bg_x) { retval.x = lower_bg_x + (self.size.width * (self.camera?.xScale)!)/2 }
        if (upper_cam_x > upper_bg_x) { retval.x = upper_bg_x - (self.size.width * (self.camera?.xScale)!)/2 }
        if (lower_cam_y < lower_bg_y) { retval.y = lower_bg_y + (self.size.height * (self.camera?.yScale)!)/2 }
        if (upper_cam_y > upper_bg_y) { retval.y = upper_bg_y - (self.size.height * (self.camera?.yScale)!)/2 }
        
        return retval
    }
    
    // Moves the objects that are on the screen by the amount that the background is being moved
    func moveObjects(translation: CGPoint) {
        let movableObjects = ["movable", "floor"]
        for node in self.children {
            if node.name == nil || movableObjects.contains(node.name!) {
                let position = node.position
                let aNewPosition = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
                let boundedPosition = self.boundLayerPos(aNewPosition)
                print(background.position.y)
                if node.name == "floor" {
                    node.position = boundedPosition
                } else {
                    if background.position.x != 0.0 && background.position.x != -2*self.size.width {
                        node.position.x = aNewPosition.x
                    }
                    if background.position.y != 0.0 && background.position.y != -self.size.height {
                        node.position.y = aNewPosition.y
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
        if pwPaused {
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
        let nearest = nearestNodes(selectedSprite)
        for node in nearest {
            let midPoint = CGPoint(x: (selectedNode.position.x + node.position.x)/2, y: (selectedNode.position.y + node.position.y)/2)
            let joinNodes = SKPhysicsJointFixed.jointWithBodyA(selectedSprite.physicsBody!, bodyB: node.physicsBody!, anchor: midPoint)
            self.physicsWorld.addJoint(joinNodes)
        }
    }
    
    func handlePinch(recognizer: UIPinchGestureRecognizer) {
        if recognizer.state == .Changed {
            let xdim = CGFloat(self.size.width * (self.camera?.xScale)!);
            let ydim = CGFloat(self.size.height * (self.camera?.yScale)!);
            
            
            var hasChanged = false;
            if (xdim < background.size.width && ydim < background.size.height) {
                let lower_bg_x = background.position.x
                let upper_bg_x = background.position.x + background.size.width
                let lower_bg_y = background.position.y
                let upper_bg_y = background.position.y + background.size.height
                
                let lower_cam_x = (self.camera?.position.x)! - (self.size.width * (self.camera?.xScale)!)/2
                let upper_cam_x = (self.camera?.position.x)! + (self.size.width * (self.camera?.xScale)!)/2
                let lower_cam_y = (self.camera?.position.y)! - (self.size.height * (self.camera?.yScale)!)/2
                let upper_cam_y = (self.camera?.position.y)! + (self.size.height * (self.camera?.yScale)!)/2
                
                if (lower_cam_x <= lower_bg_x && recognizer.scale >= 1) { return }
                if (upper_cam_x >= upper_bg_x && recognizer.scale >= 1) { return }
                if (lower_cam_y <= lower_bg_y && recognizer.scale >= 1) { return }
                if (upper_cam_y >= upper_bg_y && recognizer.scale >= 1) { return }
                
                let next_lower_cam_x = (self.camera?.position.x)! - (self.size.width * (self.camera!.xScale + recognizer.scale)/2)/2
                let next_upper_cam_x = (self.camera?.position.x)! + (self.size.width * self.camera!.xScale * recognizer.scale)/2
                let next_lower_cam_y = (self.camera?.position.y)! - (self.size.height * (self.camera!.yScale + recognizer.scale)/2)/2
                let next_upper_cam_y = (self.camera?.position.y)! + (self.size.height * self.camera!.yScale * recognizer.scale)/2
                
                if (next_lower_cam_x < lower_bg_x) {
                    self.camera?.position.x = lower_bg_x + (self.size.width * (self.camera?.xScale)!)/2
                    hasChanged = true;
                }
                if (next_lower_cam_y < lower_bg_y) {
                    self.camera?.position.y = lower_bg_y + (self.size.height * (self.camera?.yScale)!)/2
                    hasChanged = true;
                }
                if (next_upper_cam_x > upper_bg_x) {
                    self.camera?.position.x = upper_bg_x - (self.size.width * (self.camera?.xScale)!)/2
                    hasChanged = true;
                }
                if (next_upper_cam_y > upper_bg_y) {
                    self.camera?.position.y = upper_bg_y - (self.size.height * (self.camera?.yScale)!)/2
                    hasChanged = true;
                }
                
                if (!hasChanged) { self.camera?.setScale(recognizer.scale) }
                self.camera?.position = boundedCamMovement(self.camera!.position)
            }
        }
    }
    
    // Saves the sprites that are currently in the scene
    func saveSprites() {
        print("saving")
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(PWObjects, toFile: PWObject.ArchiveURL.path!)
        if !isSuccessfulSave {
            print("Failed to save sprites.")
        }
    }
    
    // Loads the sprites from hardware memory
    func loadSprites() -> [PWObject]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(PWObject.ArchiveURL.path!) as? [PWObject]
    }
}
