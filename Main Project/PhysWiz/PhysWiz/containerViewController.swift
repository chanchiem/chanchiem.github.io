//
//  physicslogViewController.swift
//  PhysWiz
//
//  Created by Yosvani Lopez on 4/16/16.
//  Copyright © 2016 Intuition. All rights reserved.
//

import Foundation
import UIKit

class containerViewController: UIViewController {
    
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var physicsLog: UIView!
    @IBOutlet weak var objectMenu: UIBarButtonItem!
    @IBOutlet weak var gadgetMenu: UIBarButtonItem!
    
    @IBOutlet weak var physicsLogButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            gadgetMenu.target = self.revealViewController()
            gadgetMenu.action = "revealToggle:"
            objectMenu.target = revealViewController()
            objectMenu.action = "rightRevealToggle:"
            // self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //This Builds and animates the input box this is  called when the physics log button is pressed it also maintains a global on off switch logpresented in order to correctly resize the screen
    let duration = 0.5
    var Logpresented = false
    @IBAction func showPhysicsLog(sender: AnyObject) {
        UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: [], animations: {
            
            if !self.Logpresented {
                var t = CGAffineTransformIdentity
                t = CGAffineTransformScale(t, 1.0 , 0.75)
                t = CGAffineTransformTranslate(t, 0.0, -110.0)
                self.gameView.transform = t
                self.physicsLog.transform = CGAffineTransformMakeTranslation(0, -110)
                self.Logpresented = true
                
                
            } else {
                self.physicsLog.transform = CGAffineTransformMakeTranslation(0, self.view.frame.height - self.gameView.frame.height)
                self.gameView.transform = CGAffineTransformIdentity
                self.Logpresented = false
            }
            
            }, completion: { finished in
        })
        
    }
    
    // return from selecting table object
    @IBAction func unwindSegue(segue: UIStoryboardSegue) {
        // do stuff
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if (segue.identifier == "toGameView") {
    let GameVC = segue.destinationViewController as! GameViewController
    GameVC.parentView = self
        }
        
    }
    
    
}
