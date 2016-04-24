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
    var objectflag = 0
    var gadgetflag = 0
    // Implementation of slide out menus
    var parentView = containerViewController()
    override func viewDidLoad() {
        super.viewDidLoad()
    
        currentGame = GameScene(fileNamed: "GameScene")
        if currentGame != nil {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the view*/
            currentGame.scaleMode = .ResizeFill
            skView.presentScene(currentGame)
        }

        currentGame.gameVC = self
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
    func setObjectFlag(index: Int) {
        //set other flag to null 
        if index != 9 {
            gadgetflag = 0
        }
        objectflag = index
        NSLog("Test")
    }
    func setGadgetFlag(index: Int) {
        // set other flag to null
        if index != 0 {
        objectflag = 9
        }
        gadgetflag = index
        NSLog("Test")
    }
    func getObjectFlag()->Int{
        return objectflag
    }
    func getGadgetFlag()->Int{
        return gadgetflag
    }

    // Label that contains the information about the px, py, etc...
    // This is used to let the user know information about the selected
    // objects.
    @IBOutlet weak var staticBox: UILabel!

    // display parameters of selected object in label by modifying
    // labels in the static box.
    // metric parameter is added to scale according to users desired metric ( meter/feet etc
    func setsStaticBox(input: [Float]) {
        let physicsLog = parentView.childViewControllers[0] as! physicslogViewController
        return physicsLog.setsInputBox(input, state: "static")
    }
    

    @IBOutlet weak var Time: UITextField!
    
   
    
    func getTime() -> String {
        return self.Time.text!
    }
    
    // Gets the input from all the TextFields inside the inputBox.
    func getInput() -> [String] {
        let physicsLog = parentView.childViewControllers[0] as! physicslogViewController
        return physicsLog.getInput()
    }
    
    // Resets the input fields in the input box
    func setsInputBox(input: [Float]) {
        let physicsLog = parentView.childViewControllers[0] as! physicslogViewController
        physicsLog.setsInputBox(input, state: "editable")
    }
    

    // changes parameter box from input to static
    func changeParameterBox() {

    }
    
    
    
    
}
