//
//  GameViewController.swift
//  SlideOut
//
//  Created by James Lin on 3/27/16.
//  Copyright (c) 2016 Intuition. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet
    var tableView: UITableView?
    var shapes = ["circle.png", "square.png", "triangle.png"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = GameScene(fileNamed:"GameScene") {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
        }
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.None
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.shapes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        
        //cell.textLabel?.text = shapes[indexPath.row]
        cell.imageView!.image = UIImage(named: shapes[indexPath.row])
        
        return cell
        
    }
    
}
