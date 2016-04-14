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
    var parameternames = ["mass", "Px", "Py","Vx", "Vy", "Av", "Ax", "Ay", "Fx", "Fy"]
<<<<<<< Updated upstream
    enum shapeType{
        case BALL
        case RECT
    }
    
    @IBOutlet var shapesTableView: UITableView?
    @IBOutlet var gadgetsTableView: UITableView?
    // var shapes = ["circle.png", "square.png", "triangle.png"]
    var shapes = ["circle.png", "square.png", "triangle.png", "crate.png", "baseball.png", "brickwall.png", "airplane.png", "bike.png", "car.png"]
    var shapeArray = [shapeType]()
    var gadgets = ["rope.png", "blank.png"]
=======
    var flag = 0
>>>>>>> Stashed changes

    
    // Implementation of slide out menus
    @IBOutlet weak var gadgetMenu: UIBarButtonItem!
    @IBOutlet weak var objectMenu: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            gadgetMenu.target = self.revealViewController()
            gadgetMenu.action = "revealToggle:"
            
            objectMenu.target = revealViewController()
            objectMenu.action = "rightRevealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
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


        currentGame.viewController = self
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Landscape
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
       
    }
    

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
   
    // Finds the index on the table that the user selected
    func setflag(index: Int) {
        // NOTICE: MUST IMPLEMENT FOR BOTH THE SHAPES AND THE GADGETS VIEW. CURRENTLY DOES THE SAME THING FOR BOTH.
<<<<<<< Updated upstream
        if (tableView == self.shapesTableView) {
            currentGame.setFlag(indexPath.row)
        }
        if (tableView == self.gadgetsTableView) {
            if (indexPath.item == 0) { // Rope
                currentGame.ropeOn = true;
            }
            if (indexPath.item == 1) {
                currentGame.ropeOn = false;
            }
        }
=======
        print(index)
        flag = index
>>>>>>> Stashed changes
        NSLog("Test")
    }
    func getflag()->Int{
        return flag
    }
    
    // return from selecting table object
    @IBAction func unwindSegue(segue: UIStoryboardSegue) {
        // do stuff
    }
    // Label that contains the information about the px, py, etc...
    // This is used to let the user know information about the selected
    // objects.
    @IBOutlet weak var staticBox: UILabel!

    // display parameters of selected object in label by modifying
    // labels in the static box.
    // metric parameter is added to scale according to users desired metric ( meter/feet etc
    func setsStaticBox(input: [Float]) {
        self.staticBox.text = ""
        for i in 0...input.count - 1 {
            self.staticBox.text = self.staticBox.text! + parameternames[i] + " = " + truncateString(String(input[i]), decLen: 2) + "\n"
        }
    }
    
    // The input box contains all the text fields for the user to input information.
    // The type of information being passed is declared below the inputbox declaration.
    // This includes mass, px, py, vx, vy, ax, ay, etc...
    @IBOutlet weak var inputBox: UIScrollView!
    @IBOutlet weak var mass: UITextField!
    @IBOutlet weak var Px: UITextField!
    @IBOutlet weak var Py: UITextField!
    @IBOutlet weak var Vx: UITextField!
    @IBOutlet weak var Vy: UITextField!
    @IBOutlet weak var Ax: UITextField!
    @IBOutlet weak var Ay: UITextField!
    @IBOutlet weak var Fy: UITextField!
    @IBOutlet weak var Fx: UITextField!
    @IBOutlet weak var Av: UITextField!
    
    
   
    
    
    
    // Gets the input from all the TextFields inside the inputBox.
    func getInput() -> [String] {
        var values = [String]()
        values.append(self.mass.text!)
        values.append(self.Px.text!)
        values.append(self.Py.text!)
        values.append(self.Vx.text!)
        values.append(self.Vy.text!)
        values.append(self.Av.text!)
        values.append(self.Ax.text!)
        values.append(self.Ay.text!)
        values.append(self.Fx.text!)
        values.append(self.Fy.text!)
        return values
    }
    
    // Resets the input fields in the input box
    func setsInputBox(input: [Float]) {
        mass.text = truncateString(String(input[0]), decLen: 2)
        Px.text = truncateString(String(input[1]), decLen: 2)
        Py.text = truncateString(String(input[2]), decLen: 2)
        Vx.text = truncateString(String(input[3]), decLen: 2)
        Vy.text = truncateString(String(input[4]), decLen: 2)
        Av.text = truncateString(String(input[5]), decLen: 2)
        Ax.text = truncateString(String(input[6]), decLen: 2)
        Ay.text = truncateString(String(input[7]), decLen: 2)
        Fx.text = truncateString(String(input[8]), decLen: 2)
        Fy.text = truncateString(String(input[9]), decLen: 2)
    }
    
    // Truncates the string so that it shows only the given
    // amount of numbers after the first decimal.
    // For example:
    // decLen = 3; 3.1023915 would return 3.102
    //
    // If there are no decimals, then it just returns the string.
    func truncateString(inputString: String, decLen: Int) -> String
    {
        return String(format: "%.\(decLen)f", (inputString as NSString).floatValue)
    }
    
    // changes parameter box from input to static
    func changeParameterBox() {
        if inputBox.hidden == false {
            inputBox.hidden = true
            staticBox.hidden = false
        }
        else if inputBox.hidden == true {
            inputBox.hidden = false
            staticBox.hidden = true
        }
    }
    
    
    
    
}
