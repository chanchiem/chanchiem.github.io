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
    var parentVC: containerViewController!
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
            currentGame.containerVC = parentVC
        }
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

    @IBOutlet weak var Time: UITextField!
    func getTime() -> String {
        return self.Time.text!
    }

   
}
