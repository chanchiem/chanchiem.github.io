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
class physicslogViewController: UIViewController {
    var parameternames = ["Mass", "Px", "Py","Vx", "Vy", "Av", "Ax", "Ay", "Fx", "Fy"]
    @IBOutlet var physicsLog: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var test: UIButton!
    
    @IBAction func test(sender: AnyObject) {
        print("test")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

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
    
    
    // changes velocities types tells whether velocity input is cartesian (off) or polar/vectorial (on)
    @IBOutlet weak var velocityType: UISwitch!
    @IBOutlet weak var velocityXLabel: UILabel!
    @IBOutlet weak var velocityYLabel: UILabel!
    @IBAction func changeVelocityType(sender: AnyObject) {
        if velocityType.on {
            velocityXLabel.text = "V"
            velocityYLabel.text = "θ"
        }
        if !velocityType.on {
            velocityXLabel.text = "Vx"
            velocityYLabel.text = "Vy"
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
    
    // Resets the input fields in the input box
    func setsInputBox(input: [Float]) {
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
    
    // sets static label with values in a given input array
    func setsOutputBox(input: [Float]) {
        self.OutputValues.text = ""
        for i in 0...input.count - 1 {
            self.OutputValues.text = self.OutputValues.text! + parameternames[i] + " = " + truncateString(String(input[i]), decLen: 2) + "\n"
        }
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
    
    // converts degrees to radians (for use in darwin math)
    func degToRad(degrees: Float) -> Float {
        // M_PI is defined in Darwin.C.math
        return Float(M_PI) * 2.0 * degrees / 360.0
    }
    
    // converts to X given magnitude and angle returns 0 if either value is nil (Note: this may need to change to keep current val)
    func toX(velocity: String, theta: String)->String{
        while (Float(velocity) != nil  && Float(theta) != nil) {
            return String(Float(velocity)!*Darwin.cos(degToRad(Float(theta)!)))
        }
        return "0"
    }
    // converts to Y given magnitude and angle returns 0 if either value is nil (Note: this may need to change to keep current val)
    func toY(velocity: String, theta: String)->String{
        while (Float(velocity) != nil  && Float(theta) != nil) {
            return String(Float(velocity)!*Darwin.sin(degToRad(Float(theta)!)))
        }
        return "0"
    }

    
}
