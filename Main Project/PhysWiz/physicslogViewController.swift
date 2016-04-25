 //
//  physicslogViewController.swift
//  PhysWiz
//
//  Created by Yosvani Lopez on 4/16/16.
//  Copyright © 2016 Intuition. All rights reserved.
//

import Foundation
import UIKit
import Darwin
 class physicslogViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate  {
    var activeLogView: UIView?
    var currentTextField: UITextField?
    var objects = ["none", "test"]
    var parameterNames = ["Mass", "Px", "Py","Vx", "Vy", "Av", "Ax", "Ay", "Fx", "Fy"]
    var parentVC = containerViewController()
    @IBOutlet var physicsLog: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register the UITableViewCell class with the tableView
        self.objectSelector?.registerClass(UITableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)
        // make input box text fields delegates of physicslog view controller so that we could find which is currently being edited (all the text boxes to be edited by num pad must be added here)
        Mass.delegate = self;
        Px.delegate = self;
        Py.delegate = self;
        Vx.delegate = self;
        Vy.delegate = self;
        Ax.delegate = self;
        Ay.delegate = self;
        Fx.delegate = self;
        Fy.delegate = self;
        Av.delegate = self;
        EndParameterInputBox.delegate = self;
        // Move all the option boxes to the same spot in so that toggling is simply done with hide and unhide 
        self.activeLogView = self.mainLogView
        self.EndSetter.transform = CGAffineTransformMakeTranslation(0, -200)
        self.SettingsBox.transform = CGAffineTransformMakeTranslation(0, -400)
         self.ChosenEndView.transform = CGAffineTransformMakeTranslation(0, -600)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        

    }
    
    // save the text field that is being edited
    func textFieldDidBeginEditing(textField: UITextField) {
        currentTextField = textField
        currentTextField?.inputView = nil
    }

    
    // The input box contains all the text fields for the user to input information.
    // The type of information being passed is declared below the inputbox declaration.
    // This includes mass, px, py, vx, vy, ax, ay, etc...
    // Gets the input from all the TextFields inside the inputBox.
    @IBOutlet weak var InputBox: UIView!
    @IBOutlet weak var Mass: UITextField!
    @IBOutlet weak var Px: UITextField!
    @IBOutlet weak var Py: UITextField!
    @IBOutlet weak var Vx: UITextField!
    @IBOutlet weak var Vy: UITextField!
    @IBOutlet weak var Ax: UITextField!
    @IBOutlet weak var Ay: UITextField!
    @IBOutlet weak var Fx: UITextField!
    @IBOutlet weak var Fy: UITextField!
    @IBOutlet weak var Av: UITextField!
    
    // Textbox used to output values 
    @IBOutlet weak var OutputValues: UILabel!
    
    
    // ##############################################################
    //  Settings View
    // ##############################################################
    @IBOutlet weak var SettingsBox: UIView!
    @IBAction func SettingsButton(sender: AnyObject) {
        activeLogView?.hidden = true
        SettingsBox.hidden = false
        activeLogView = SettingsBox
    }
    // changes velocities types tells whether velocity input is cartesian (off) or polar/vectorial (on)
    @IBOutlet weak var velocityType: UISwitch!
    @IBOutlet weak var velocityXLabel: UILabel!
    @IBOutlet weak var velocityYLabel: UILabel!
    @IBAction func changeVelocityType(sender: AnyObject) {
        if velocityType.on {
            velocityXLabel.text = "V"
            velocityYLabel.text = "θ"
            Vx.text = truncateString(String(toMagnitude(Vx.text!, y: Vy.text!)), decLen: 2)
            Vy.text = truncateString(String(toTheta(Vx.text!, y: Vy.text!)), decLen: 2)
            }
        if !velocityType.on {
            velocityXLabel.text = "Vx"
            velocityYLabel.text = "Vy"
            Vx.text = toX(self.Vx.text!, theta: self.Vy.text!)
            Vy.text = toY(self.Vx.text!, theta: self.Vy.text!)
        }
    }
    // changes acceleration types tells whether acceleration input is cartesian (off) or polar/vectorial (on)
    @IBOutlet weak var accelerationType: UISwitch!
    @IBOutlet weak var accelerationXLabel: UILabel!
    @IBOutlet weak var accelerationYLabel: UILabel!
    @IBAction func changeAccelerationType(sender: AnyObject) {
        if accelerationType.on {
            accelerationXLabel.text = "A"
            accelerationYLabel.text = "θ"
        }
        if !accelerationType.on {
            accelerationXLabel.text = "Ax"
            accelerationYLabel.text = "Ay"
        }
    }
    // changes force types tells whether force input is cartesian (off) or polar/vectorial (on)
    @IBOutlet weak var forceType: UISwitch!
    @IBOutlet weak var forceXLabel: UILabel!
    @IBOutlet weak var forceYLabel: UILabel!
    @IBAction func changeForceType(sender: AnyObject) {
        if forceType.on {
            forceXLabel.text = "F"
            forceYLabel.text = "θ"
        }
        if !forceType.on {
            forceXLabel.text = "Fx"
            forceYLabel.text = "Fy"
        }
    }
    // ##############################################################
    //  InputBox
    // ##############################################################
    
    // Gets the input from all the TextFields inside the inputBox.
    func getInput() -> [String] {
        var values = [String]()
        values.append(self.Mass.text!)
        values.append(self.Px.text!)
        values.append(self.Py.text!)
        // check velocity type
        if !velocityType.on {
        values.append(self.Vx.text!)
        values.append(self.Vy.text!)
        }
        else {
        values.append(toX(self.Vx.text!, theta: self.Vy.text!))
        values.append(toY(self.Vx.text!, theta: self.Vy.text!))
        }
        values.append(self.Av.text!)
        // check acceleration type
        if !accelerationType.on {
            values.append(self.Ax.text!)
            values.append(self.Ay.text!)
        }
        else {
            values.append(toX(self.Ax.text!, theta: self.Ay.text!))
            values.append(toY(self.Ax.text!, theta: self.Ay.text!))
        }
        // check force type
        if !accelerationType.on {
            values.append(self.Fx.text!)
            values.append(self.Fy.text!)
        }
        else {
            values.append(toX(self.Fx.text!, theta: self.Fy.text!))
            values.append(toY(self.Fx.text!, theta: self.Fy.text!))
        }
        
        return values
    }
    
    // Resets the input fields in the input box state variable is either static or editable
    func setsInputBox(input: [Float], state: String ) {
        if state == "static" {
        makeInputBoxStatic()
        }
        else if state == "editable" {
        makeInputBoxEditable()
        }
        Mass.text = truncateString(String(input[0]), decLen: 2)
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
    
    // changes inputbox to static state
    func makeInputBoxStatic() {
        Mass.userInteractionEnabled = false
        Mass.backgroundColor = UIColor.clearColor()
        Px.userInteractionEnabled = false
        Px.backgroundColor = UIColor.clearColor()
        Py.userInteractionEnabled = false
        Py.backgroundColor = UIColor.clearColor()
        Vx.userInteractionEnabled = false
        Vx.backgroundColor = UIColor.clearColor()
        Vy.userInteractionEnabled = false
        Vy.backgroundColor = UIColor.clearColor()
        Av.userInteractionEnabled = false
        Av.backgroundColor = UIColor.clearColor()
        Ax.userInteractionEnabled = false
        Ax.backgroundColor = UIColor.clearColor()
        Ay.userInteractionEnabled = false
        Ay.backgroundColor = UIColor.clearColor()
        Fx.userInteractionEnabled = false
        Fx.backgroundColor = UIColor.clearColor()
        Fy.userInteractionEnabled = false
        Fy.backgroundColor = UIColor.clearColor()
        
    }
    // changes input box to editable state
    func makeInputBoxEditable() {
        Mass.userInteractionEnabled = true
        Mass.backgroundColor = UIColor.whiteColor()
        Px.userInteractionEnabled = true
        Px.backgroundColor = UIColor.whiteColor()
        Py.userInteractionEnabled = true
        Py.backgroundColor = UIColor.whiteColor()
        Vx.userInteractionEnabled = true
        Vx.backgroundColor = UIColor.whiteColor()
        Vy.userInteractionEnabled = true
        Vy.backgroundColor = UIColor.whiteColor()
        Av.userInteractionEnabled = true
        Av.backgroundColor = UIColor.whiteColor()
        Ax.userInteractionEnabled = true
        Ax.backgroundColor = UIColor.whiteColor()
        Ay.userInteractionEnabled = true
        Ay.backgroundColor = UIColor.whiteColor()
        Fx.userInteractionEnabled = true
        Fx.backgroundColor = UIColor.whiteColor()
        Fy.userInteractionEnabled = true
        Fy.backgroundColor = UIColor.whiteColor()
        
    }
    // ##############################################################
    //  Number Pad
    // ##############################################################
    @IBOutlet weak var KeyPad: UIView!
    @IBAction func one(sender: AnyObject) {
        if currentTextField != nil {
            currentTextField?.text = (currentTextField?.text)! + "1"
        }
    }
    @IBAction func two(sender: AnyObject) {
        if currentTextField != nil {
            currentTextField?.text = (currentTextField?.text)! + "2"
        }
    }
    @IBAction func three(sender: AnyObject) {
        if currentTextField != nil {
            currentTextField?.text = (currentTextField?.text)! + "3"
        }
    }
    @IBAction func four(sender: AnyObject) {
        if currentTextField != nil {
            currentTextField?.text = (currentTextField?.text)! + "4"
        }
    }
    @IBAction func five(sender: AnyObject) {
        if currentTextField != nil {
            currentTextField?.text = (currentTextField?.text)! + "5"
        }
    }
    @IBAction func six(sender: AnyObject) {
        if currentTextField != nil {
            currentTextField?.text = (currentTextField?.text)! + "6"
        }
    }
    @IBAction func seven(sender: AnyObject) {
        if currentTextField != nil {
            currentTextField?.text = (currentTextField?.text)! + "7"
        }
    }
    @IBAction func eight(sender: AnyObject) {
        if currentTextField != nil {
            currentTextField?.text = (currentTextField?.text)! + "8"
        }
    }
    @IBAction func nine(sender: AnyObject) {
        if currentTextField != nil {
            currentTextField?.text = (currentTextField?.text)! + "9"
        }
    }
    @IBAction func zero(sender: AnyObject) {
        if currentTextField != nil {
            currentTextField?.text = (currentTextField?.text)! + "0"
        }
    }
    @IBAction func decimal(sender: AnyObject) {
        if currentTextField != nil {
            currentTextField?.text = (currentTextField?.text)! + "."
        }
    }
    @IBAction func clear(sender: AnyObject) {
        if currentTextField != nil {
            currentTextField?.text = ""
        }
    }
    
    // ##############################################################
    //  Main View - has Object Selection Table and log
    // ##############################################################
    @IBOutlet weak var mainLogView: UIView!
    @IBOutlet weak var objectSelector: UITableView!
    let cellIdentifier = "cellIdentifier"
    var selectionTableData = [String]()
    func addObjectToList(ID: Int) {
       selectionTableData.append(String(ID))
       objectSelector.reloadData()
    }
    func removeObjectFromList(ID: Int) {
        for i in Range(0 ..< selectionTableData.count) {
            if (selectionTableData[i] == (String(ID))) {
                selectionTableData.removeAtIndex(i)
                objectSelector.reloadData()
                break
            }
        }
    }
    func removeAllFromList() {
        selectionTableData = [String]()
        objectSelector.reloadData()
    }
    // UITableViewDataSource methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectionTableData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        cell.textLabel?.text = selectionTableData[indexPath.row] as! String
        return cell
    }
    
    // UITableViewDelegate methods
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        parentVC.changeSelectedObject(Int(selectionTableData[indexPath.row])!)

    }
    // ##############################################################
    //  Simulation End setter
    // ##############################################################
    @IBOutlet weak var EndSetter: UIView!
    @IBOutlet weak var TimeButton: UIButton!
    @IBOutlet weak var EndParameterButton: UIButton!
    @IBOutlet weak var EventButton: UIButton!
    @IBOutlet weak var ChosenEndView: UIView!
    @IBOutlet weak var EndViewTitle: UILabel!
    @IBOutlet weak var EndViewBackButton: UIButton!
    @IBOutlet weak var EndParameterInputBox: UITextField!
    
    @IBOutlet weak var StopWhenLabel: UILabel!
    @IBOutlet weak var ForObjectLabel: UILabel!
    @IBOutlet weak var EndObjectListBox: UIScrollView!
    @IBOutlet weak var EndObjectList: UITableView!
    @IBOutlet weak var ParameterEqualsTo: UILabel!
    @IBOutlet weak var EndParameterListBox: UIScrollView!
    @IBOutlet weak var EndParameterList: UITableView!
    var EndType = ""
    func changeToEndSetter() {
        activeLogView!.hidden = true
        EndSetter.hidden = false
        activeLogView = EndSetter
    }
    @IBAction func ReturnToEndSetter(sender: AnyObject) {
        changeToEndSetter()
    }
    // the parameter we are ending for
    func getEndType() -> String {
        return EndType
    }
    // the inputed value to end at
    func getEndData() -> String {
        return EndParameterInputBox.text!
    }
    // the object that the end value is associated with
    func getEndobject() -> String {
        return ""
        
    }
    // Set up endssetter View for Entering Time
    @IBAction func timeSet(sender: AnyObject) {
       EndType = "Time"
       EndViewTitle.text = "Time"
       ParameterEqualsTo.text = "End-Time:"
       activeLogView!.hidden = true
       StopWhenLabel.hidden = true
       ForObjectLabel.hidden = true
       EndParameterListBox.hidden = true
       EndObjectListBox.hidden = true
       ChosenEndView.hidden = false
       activeLogView = ChosenEndView
    }
    
    @IBAction func EndParameterSet(sender: AnyObject) {
        EndViewTitle.text = "End-Parameter"
        EndType = "End-Parameter"
        ParameterEqualsTo.text = getEndType() + "Equals To:"
        ForObjectLabel.text = "For" + getEndobject()
        ForObjectLabel.hidden = false
        StopWhenLabel.hidden = false
        ForObjectLabel.hidden = false
        EndParameterListBox.hidden = false
        EndObjectListBox.hidden = false
        ChosenEndView.hidden = false
        activeLogView!.hidden = true
        activeLogView = ChosenEndView
    }
  
    @IBAction func eventSet(sender: AnyObject) {
    }

    // ##############################################################
    //  Helper Functions
    // ##############################################################

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
    
    // converts degrees to radians (for use in darwin math)
    func degToRad(degrees: Float) -> Float {
        // M_PI is defined in Darwin.C.math
        return Float(M_PI) * 2.0 * degrees / 360.0
    }
    
    // converts to X given magnitude and angle returns 0 if either value is nil (Note: this may need to change to keep current val)
    func toX(velocity: String, theta: String)->String{
        if (Float(velocity) != nil  && Float(theta) != nil) {
            return String(Float(velocity)!*Darwin.cos(degToRad(Float(theta)!)))
        }
        return "0"
    }
    // converts to Y given magnitude and angle returns 0 if either value is nil (Note: this may need to change to keep current val)
    func toY(velocity: String, theta: String)->String{
        if (Float(velocity) != nil  && Float(theta) != nil) {
            return String(Float(velocity)!*Darwin.sin(degToRad(Float(theta)!)))
        }
        return "0"
    }
    func toTheta(x:String, y: String) -> String{
        while (Float(x) != nil  && Float(y) != nil) {
            return  String(Darwin.atan(Float(y)!/Float(x)!)*100)
        }
        return "0"
    }
    func toMagnitude (x:String, y: String) -> String {
        while (Float(x) != nil  && Float(y) != nil) {
            return String(Darwin.sqrt(Darwin.powf(Float(x)!, 2) + Darwin.powf(Float(y)!, 2)))
        }
        return "0"
        
    }
}
