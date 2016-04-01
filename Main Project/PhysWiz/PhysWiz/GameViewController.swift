//
//  GameViewController.swift
//  PhysWiz
//
//  Created by James Lin on 3/21/16.
//  Copyright (c) 2016 Intuition. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    // The strong reference to the game scene. This reference
    // is the link of communication between the interface
    // and the scene.
    var currentGame: GameScene!
    var parameternames = ["mass", "Vx", "Vy", "Px", "Py", "w"]
    enum shapeType{
        case BALL
        case RECT
    }
    
    @IBOutlet
    var tableView: UITableView?
    // var shapes = ["circle.png", "square.png", "triangle.png"]
    var shapes = ["circle.png", "square.png"]
    var shapeArray = [shapeType]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        shapeArray.append(shapeType.BALL)
        shapeArray.append(shapeType.RECT)
        
        currentGame = GameScene(fileNamed: "GameScene")

        if currentGame != nil {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            currentGame.scaleMode = .AspectFit
            
            skView.presentScene(currentGame)
        }
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.None

        currentGame.viewController = self
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // TABLE STUFF STARTS BELOW
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.shapes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        
        //cell.textLabel?.text = shapes[indexPath.row]
        cell.imageView!.image = UIImage(named: shapes[indexPath.row])
        cell.backgroundColor = UIColor.blackColor()
        
        return cell
        
    }
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        currentGame.setFlag(indexPath.row)
        NSLog("Test")
    }
    // parameter label output
    @IBOutlet weak var parameters: UILabel!
    // display parameters of selected object in label
    func setparameter(input: [String]) {
    self.parameters.text = ""
        for i in 0...input.count - 1 {
    self.parameters.text = self.parameters.text! + parameternames[i] + " = " + input[i] + "\n"
        }
    }
    
    // Input Box
    @IBOutlet weak var mass: UITextField!

    @IBOutlet weak var Px: UITextField!
    
    @IBOutlet weak var Vx: UITextField!
    
    @IBOutlet weak var Ax: UITextField!
    
    @IBOutlet weak var Fx: UITextField!
    
    @IBOutlet weak var Py: UITextField!
    
    @IBOutlet weak var Vy: UITextField!
    
    @IBOutlet weak var Ay: UITextField!
    func getInputValues() -> [String] {
    var values = [String]()
    values.append(self.mass.text!)
    values.append(self.Px.text!)
    values.append(self.Vx.text!)
    values.append(self.Ax.text!)
    values.append(self.Fx.text!)
    values.append(self.Py.text!)
    values.append(self.Vy.text!)
    values.append(self.Ay.text!)
        return values
    }
    
    
}
