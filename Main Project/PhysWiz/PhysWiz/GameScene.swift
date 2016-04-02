//
//  GameScene.swift
//  PhysWiz
//
//  Created by James Lin on 3/21/16.
//  Copyright (c) 2016 Intuition. All rights reserved.
//

import SpriteKit
class GameScene: SKScene {
    var stopped = true
    var button: SKShapeNode! = nil
    var flag = shapeType.BALL;
    var shapeArray = [shapeType]()
    var viewController: GameViewController!
    // The selected object for parameters
    var selectedShape: SKShapeNode! = nil
   

    enum shapeType{
        case BALL
        case RECT
    }
    // The game view controller will be the strong owner of the gamescene
    // This reference holds the link of communication between the interface
    // and the game scene itself.
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.addChild(self.createFloor())
        self.addChild(self.pausePlay())
        physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        
        // INIT Shape arrays to call later in flag function
        shapeArray.append(shapeType.BALL)
        shapeArray.append(shapeType.RECT)
    }
    
    // Creates a floor for the physics simulation
    func createFloor() -> SKSpriteNode {
        let floor = SKSpriteNode(color: SKColor.brownColor(), size: CGSizeMake(self.frame.size.width, 20))
        
        floor.anchorPoint = CGPointMake(0, 0)
        floor.name = "floor"
        floor.physicsBody = SKPhysicsBody(edgeLoopFromRect: floor.frame)
        floor.physicsBody?.dynamic = false
        
        return floor
    }
    
    // Creates a node that will act as a pause play button for the user
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
        ball.name = "ball"
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 20.0)
        ball.physicsBody?.dynamic = !stopped
        ball.physicsBody?.restitution = 0.7
        ball.physicsBody?.friction = 0
        ball.physicsBody?.linearDamping = 0
        
        positionMark.fillColor = SKColor.blackColor()
        positionMark.position.y = -12
        ball.addChild(positionMark)
          // setting parameter
        selectedShape = ball
        return ball
    }
    // return parameters of given object
    func getParameters(object: SKShapeNode) -> [String]{
        var input = [String]()
        input.append((object.physicsBody?.mass.description)!)
        input.append((object.physicsBody?.velocity.dx.description)!)
        input.append((object.physicsBody?.velocity.dy.description)!)
        input.append((object.position.x.description))
        input.append((object.position.y.description))
        input.append((object.physicsBody?.angularVelocity.description)!)
        return input
        
    }
    // set parameters of given object from input box
    func setParameters(object: SKShapeNode) {
        let values = viewController.getInput
        if Float(values()[0]) != nil {object.physicsBody?.mass = CGFloat(Float(values()[0])!)}
        if Float(values()[1]) != nil {object.position.x = CGFloat(Float(values()[1])!)}
        if Float(values()[2]) != nil {object.physicsBody?.velocity.dx = CGFloat(Float(values()[2])!)}
        // make acceleration x object.physicsBody?.mass = CGFloat(Int(values()[3])!)
        /// apply force object.physicsBody?.applyForce(force: Int(values()[4])!, 0)
        if Float(values()[5]) != nil {object.position.y = CGFloat(Float(values()[5])!)}
        if Float(values()[6]) != nil {object.physicsBody?.velocity.dy = CGFloat(Float(values()[6])!)}
        // make acceleration y object.physicsBody?.mass = CGFloat(Int(values()[3])!)
        }

    // Returns the ball! Make sure you add it to the skscene yourself!
    func createRectangle(position: CGPoint) -> SKShapeNode {
        let dimensions = CGSizeMake(40, 40);
        let rect = SKShapeNode(rectOfSize: dimensions)
        
        rect.fillColor = SKColor(red: CGFloat(arc4random() % 256) / 256.0, green: CGFloat(arc4random() % 256) / 256.0, blue: CGFloat(arc4random() % 256) / 256.0, alpha: 1.0)
        rect.position = position
        rect.name = "rectangle"
        
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
    
    func setFlag(index: Int){
        
        flag = shapeArray[index]
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let location:CGPoint = touch.locationInNode(self)
            let floor:SKNode? = self.childNodeWithName("floor")
            if floor?.containsPoint(location) != nil {
                
            NSLog("Client requesting to create at %f, %f", location.x, location.y)
                
                // Make sure the point that is being touched is part of the game scene plane is part of the
                // game
                if(checkValidPoint(location)) {
                    
                    // If the person selected a node, set it as the selected node.
                    let selectedNode = checkLocforNode(location)
                    if  (selectedNode != nil) {
                        NSLog("Found node: \(selectedNode.name)")
                        return
                    }
                    
                    // Checks if the object being selected is not a node.
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
                for shape in self.children {
                    if (stopped) {
                        shape.physicsBody?.dynamic = true
                    }
                    else if (!stopped) {
                        
                        shape.physicsBody?.dynamic = false
                    }
                }
                
                button.physicsBody?.dynamic = false   // Keeps pause play button in place
                
                // Updates the value of the variable 'stopped'
                if (stopped) {
                    stopped = false
                    //self.viewController.tableView!.alpha = 0
                    UIView.animateWithDuration(1.5, animations: {self.viewController.tableView!.alpha = 0})
                } else {
                    stopped = true
                    UIView.animateWithDuration(1.5, animations: {self.viewController.tableView!.alpha = 1})
                }
                //fill in current values and changes parameter box
                if (selectedShape != nil) {
                    viewController.setsInputBox(getParameters(selectedShape))
                }
                viewController.changeParameterBox()

            }
            // updates selected shapes values with input box values when stopped
            if (selectedShape != nil && stopped) {
                setParameters(selectedShape)
            }
        }
    }
    
    /* Called before each frame is rendered */
    override func update(currentTime: CFTimeInterval) {
        // continously update values of parameters for selected object 
        if selectedShape != nil && !stopped  {
        viewController.setsStaticBox(getParameters(selectedShape))
        }
    }

    override func didSimulatePhysics() {
        self.enumerateChildNodesWithName("ball", usingBlock: { (node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            if node.position.y < 0 {
                node.removeFromParent()
            }
        })
    }

}
