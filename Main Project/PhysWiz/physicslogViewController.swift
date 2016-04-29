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
    var endSetterParameterNames = ["Distance", "Height","Velocity x", "Velocity y", "Angular Velocity", "Acceleration x", "Acceleration y" ]
    var objectIDMap = [Int: String](); // Each object name will have an ID associated with it
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
    @IBAction func changeVelocityType(sender: AnyObject) {
        if velocityType.on {
            ThirdLabel.text = "V"
            FourthLabel.text = "θ"
            Vx.text = truncateString(String(toMagnitude(Vx.text!, y: Vy.text!)), decLen: 2)
            Vy.text = truncateString(String(toTheta(Vx.text!, y: Vy.text!)), decLen: 2)
            }
        if !velocityType.on {
            ThirdLabel.text = "Vx"
            FourthLabel.text = "Vy"
            Vx.text = toX(self.Vx.text!, theta: self.Vy.text!)
            Vy.text = toY(self.Vx.text!, theta: self.Vy.text!)
        }
    }
    // changes acceleration types tells whether acceleration input is cartesian (off) or polar/vectorial (on)
    @IBOutlet weak var accelerationType: UISwitch!
    @IBAction func changeAccelerationType(sender: AnyObject) {
        if accelerationType.on {
            FifthLabel.text = "A"
            SixthLabel.text = "θ"
        }
        if !accelerationType.on {
            FifthLabel.text = "Ax"
            SixthLabel.text = "Ay"
        }
    }
    // changes force types tells whether force input is cartesian (off) or polar/vectorial (on)
    @IBOutlet weak var forceType: UISwitch!
    @IBAction func changeForceType(sender: AnyObject) {
        if forceType.on {
            SeventhLabel.text = "F"
            EighthLabel.text = "θ"
        }
        if !forceType.on {
            SeventhLabel.text = "Fx"
            EighthLabel.text = "Fy"
        }
    }
    // ##############################################################
    //  InputBox
    // ####################################
    @IBOutlet weak var TopLabel: UILabel!
    @IBOutlet weak var FirstLabel: UILabel! //Px
    @IBOutlet weak var SecondLabel: UILabel! //Py
    @IBOutlet weak var ThirdLabel: UILabel! //Vx
    @IBOutlet weak var FourthLabel: UILabel! //Vy
    @IBOutlet weak var FifthLabel: UILabel! //Ax
    @IBOutlet weak var SixthLabel: UILabel! //Ay
    @IBOutlet weak var SeventhLabel: UILabel! //Fx
    @IBOutlet weak var EighthLabel: UILabel! //Fy
    @IBOutlet weak var NinthLabel: UILabel! //Av
    
    
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
    func getGadgetInput(gadgetType: String)-> [String] {
        var values = [String]()
        //properties [ scale, posx, posy, height, base, angle, friction]
        if gadgetType == "Ramp" {
             values.append(Mass.text!) //scale
             values.append(Px.text!) // position x
             values.append(Py.text!) // position y
             values.append(Vx.text!) // height
             values.append(Vy.text!) // base
             values.append(Ax.text!) // angle
             values.append(Ay.text!) // friction
            
        }
        else if gadgetType == "Platform" {
            values.append(Mass.text!) //scale
            values.append(Px.text!) // position x
            values.append(Py.text!) // position y
            values.append(Vx.text!) // length
            values.append(Vy.text!) // width
            values.append(Ax.text!) // rotate
            values.append(Ay.text!) // friction
        }
        else if gadgetType == "Wall" {
            values.append(Mass.text!) //scale
            values.append(Px.text!) // position x
            values.append(Py.text!) // position y
            values.append(Vx.text!) // height
            values.append(Vy.text!) // width
            values.append(Ax.text!) // rotate
            values.append(Ay.text!) // friction
        }
        else if gadgetType == "Round" {
            values.append(Mass.text!) //scale
            values.append(Px.text!) // position x
            values.append(Py.text!) // position y
            values.append(Vx.text!) // radius
            values.append(Vy.text!) // width
            values.append(Ax.text!) // rotate
            values.append(Ay.text!) // friction
     
        }
        else if gadgetType == "Pulley" {
            values.append(Mass.text!) //scale
            values.append(Px.text!) // position x
            values.append(Py.text!) // position y
            values.append(Vx.text!) // radius
            values.append(Vy.text!) // width
            values.append(Ax.text!) // rotate
            values.append(Ay.text!) // friction
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
    func changeToGadgetInputBox(gadgetType: String) {
        if gadgetType == "Ramp" {
            TopLabel.text = "Scale"
            ThirdLabel.text = "Height"
            FourthLabel.text = "Base"
            FifthLabel.text = "Angle"
            SixthLabel.text = "Friction"
            SeventhLabel.hidden = true
            Fx.hidden = true
            EighthLabel.hidden = true
            Fy.hidden = true
            NinthLabel.hidden = true
            Av.hidden = true
        }
        else if gadgetType == "Platform" {
            TopLabel.text = "Scale"
            ThirdLabel.text = "Length"
            FourthLabel.text = "Width"
            FifthLabel.text = "Rotate"
            SixthLabel.text = "Friction"
            SeventhLabel.hidden = true
            Fx.hidden = true
            EighthLabel.hidden = true
            Fy.hidden = true
            NinthLabel.hidden = true
            Av.hidden = true
        }
        else if gadgetType == "Wall" {
            TopLabel.text = "Scale"
            ThirdLabel.text = "Height"
            FourthLabel.text = "Width"
            FifthLabel.text = "Rotate"
            SixthLabel.text = "Friction"
            SeventhLabel.hidden = true
            Fx.hidden = true
            EighthLabel.hidden = true
            Fy.hidden = true
            NinthLabel.hidden = true
            Av.hidden = true
        }
        else if gadgetType == "Round" {
            TopLabel.text = "Scale"
            ThirdLabel.text = "Radius"
            FourthLabel.text = "Curve"
            FifthLabel.text = "Friction"
            SixthLabel.text = "Rotate"
            SeventhLabel.hidden = true
            Fx.hidden = true
            EighthLabel.hidden = true
            Fy.hidden = true
            NinthLabel.hidden = true
            Av.hidden = true
        }
        else if gadgetType == "Pulley" {
            TopLabel.text = "Scale"
            ThirdLabel.text = "Radius"
            FourthLabel.text = "Friction"
            FifthLabel.text = "Angle"
            SixthLabel.text = "Rotate"
            SeventhLabel.hidden = true
            Fx.hidden = true
            EighthLabel.hidden = true
            Fy.hidden = true
            NinthLabel.hidden = true
            Av.hidden = true
        }
    }
    // Resets the input fields in the input box state variable is either static or editable
    func setsGadgetInputBox(gadgetType: String, input: [Float], state: String ) {
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
        Ax.text = truncateString(String(input[5]), decLen: 2)
        Ay.text = truncateString(String(input[6]), decLen: 2)
    }
    func changeToObjectInputBox() {
        TopLabel.text = "Mass"
        ThirdLabel.text = "Vx"
        FourthLabel.text = "Vy"
        FifthLabel.text = "Ax"
        SixthLabel.text = "Ay"
        SeventhLabel.hidden = false
        Fx.hidden = false
        EighthLabel.hidden = false
        Fy.hidden = false
        NinthLabel.hidden = false
        Av.hidden = false
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
    @IBAction func negative(sender: AnyObject) {
        if currentTextField != nil {
            currentTextField?.text = (currentTextField?.text)! + "-"
        }
    }
    @IBAction func clear(sender: AnyObject) {
        if currentTextField != nil {
            currentTextField?.text = ""
        }
    }
    // ##############################################################
    //  MainView
    // ##############################################################
    func changeToMainView() {
        activeLogView!.hidden = true
        mainLogView.hidden = false
        activeLogView = mainLogView
    }
    
    
    
    
    // ##############################################################
    //  Table Settings for mainView and for Endsetter
    // ##############################################################
    @IBOutlet weak var mainLogView: UIView!
    @IBOutlet weak var objectSelector: UITableView!
    let cellIdentifier = "cellIdentifier"
    var selectionTableData = [String]()
    func addObjectToList(ID: Int) {
       let objectName = "object " + String(ID)
       selectionTableData.append(objectName)
       objectIDMap[ID] = objectName
       objectSelector.reloadData()
       EndObjectList.reloadData()
    }
    func removeObjectFromList(ID: Int) {
        for i in Range(0 ..< selectionTableData.count) {
            let objectName = objectIDMap[ID]
            if (selectionTableData[i] == objectName) {
                selectionTableData.removeAtIndex(i)
                objectIDMap[ID] = nil;
                objectSelector.reloadData()
                EndObjectList.reloadData()
                break
            }
        }
    }
    func removeAllFromList() {
        selectionTableData = [String]()
        objectIDMap.removeAll()
        objectSelector.reloadData()
        EndObjectList.reloadData()
    }
    // UITableViewDataSource methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return count of parameter names list
        if (tableView == EndParameterList) {
          return endSetterParameterNames.count
        }
        // return count list of objects in the scene
        return selectionTableData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        // populate parameter names table
        if (tableView == EndParameterList) {
             cell.textLabel?.text = endSetterParameterNames[indexPath.row] as String
        }
        // populate tables with
        else {
        cell.textLabel?.text = selectionTableData[indexPath.row] as String
        }
        
        return cell
    }
    
    // UITableViewDelegate methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if tableView == objectSelector {
            for ID in objectIDMap.keys {
                if objectIDMap[ID] == selectionTableData[indexPath.row] {
                    parentVC.changeSelectedObject(ID)
                }
     
            }
        }
        // deals with object table selection for endsetter
        if tableView == EndObjectList {
            
           EndObject = selectionTableData[indexPath.row]
            ForObjectLabel.text = "For " + getEndobject()
        }
        // deals with parameter table selection for endsetter
        if tableView == EndParameterList {
            EndParameter = endSetterParameterNames[indexPath.row]
             ParameterEqualsTo.text = EndParameter + " ="
            
        }

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
    var endSettings: [String] = ["", "", "", ""]
    var EndType = ""
    var EndParameter = ""
    var EndObject = ""
    var EndObject2 = ""
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
        return EndObject
    }
    //returns the end event that is currently set
    func getEndSetter() -> [String] {
        if EndType == "Time" {
            endSettings[0] = "Time"
            endSettings[1] = EndParameterInputBox.text!
            endSettings[2] = ""
            endSettings[3] = ""
            
        }
        if EndType == "End-Parameter" {
            endSettings[0] = EndParameter
            endSettings[1] = EndParameterInputBox.text!
            endSettings[2] = EndObject
            endSettings[3] = ""
            
        }
        if EndType == "Event" {
            endSettings[0] = EndParameter
            endSettings[1] = EndParameterInputBox.text!
            endSettings[2] = EndObject
            endSettings[3] = EndObject2
        }

        return endSettings
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
        EndViewTitle.text = "Event"
        EndType = "Event"
        ForObjectLabel.hidden = false
        StopWhenLabel.hidden = false
        ForObjectLabel.hidden = false
        EndParameterListBox.hidden = false
        EndObjectListBox.hidden = false
        ChosenEndView.hidden = false
        activeLogView!.hidden = true
        activeLogView = ChosenEndView
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
