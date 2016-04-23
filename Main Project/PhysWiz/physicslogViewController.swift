//
//  physicslogViewController.swift
//  PhysWiz
//
//  Created by Yosvani Lopez on 4/16/16.
//  Copyright © 2016 Intuition. All rights reserved.
//

import Foundation
import UIKit

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
        let physicsLog = segue.sourceViewController as! physicslogViewController
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
    
    // Gets the input from all the TextFields inside the inputBox.
    func getInput() -> [String] {
        var values = [String]()
        values.append(self.Mass.text!)
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
    
    func setsOutputBox(input: [Float]) {
        self.OutputValues.text = ""
        for i in 0...input.count - 1 {
            self.OutputValues.text = self.OutputValues.text! + parameternames[i] + " = " + truncateString(String(input[i]), decLen: 2) + "\n"
        }
    }
    
    
}
