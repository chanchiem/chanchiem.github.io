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
    @IBOutlet weak var NavigationBar: UINavigationItem!
    @IBOutlet weak var physicsLogButton: UIBarButtonItem!
    var GameVC: GameViewController!
    var PhysicsLogVC: physicslogViewController!
    var objectflag = 0
    var gadgetflag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // handles animation of object and gadget menus
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
    // give access from childviewcontrollers to the parentview controller(self)
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if (segue.identifier == "toGameView") {
    GameVC = segue.destinationViewController as! GameViewController
    GameVC.parentVC = self
        }
    if (segue.identifier == "toPhysicsLog") {
        PhysicsLogVC = segue.destinationViewController as! physicslogViewController
        PhysicsLogVC.parentVC = self
        }
    }
    // return from selecting table object
    @IBAction func unwindSegue(segue: UIStoryboardSegue) {
        // do stuff
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
    // Gets the input from all the TextFields inside the inputBox.
    func getInput() -> [String] {
        return PhysicsLogVC.getInput()
    }
    
    // Resets the input fields in the input box
    func setsInputBox(input: [Float]) {
        PhysicsLogVC.setsInputBox(input, state: "editable")
    }
    
    // display parameters of selected object in label by modifying
    // labels in the static box.
    // metric parameter is added to scale according to users desired metric ( meter/feet etc
    func setsStaticBox(input: [Float]) {
        return PhysicsLogVC.setsInputBox(input, state: "static")
    }
    func addObjectToList(ID: Int) {
        PhysicsLogVC.addObjectToList(ID)
    }
    func removeObjectFromList(ID: Int) {
        PhysicsLogVC.removeObjectFromList(ID)
    }
    func removeAllFromList() {
        PhysicsLogVC.removeAllFromList()
    }
    func changeSelectedObject(ID: Int) {
       GameVC.changeSelectedObject(ID)
    }
    func getTime() -> String {
            return GameVC.getTime()
        }
    func changeToEndSetter() {
        PhysicsLogVC.changeToEndSetter()
    }
    func changeToMainView(){
        PhysicsLogVC.changeToMainView()
    }

}
