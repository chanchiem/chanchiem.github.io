//
//  MenuController.swift
//  SidebarMenu
//
//  Created by Simon Ng on 2/2/15.
//  Copyright (c) 2015 AppCoda. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    @IBOutlet var objectMenu: UITableView!
    @IBOutlet var gadgetMenu: UITableView!
    
    var shapes = ["circle.png", "square.png", "triangle.png", "crate.png", "baseball.png", "brickwall.png", "airplane.png", "bike.png", "car.png"]
    var gadgets = ["rope.png"]
    override func viewDidLoad() {
        super.viewDidLoad()
        if (objectMenu != nil) {
        self.objectMenu!.separatorStyle = UITableViewCellSeparatorStyle.None
        }
        if (gadgetMenu != nil) {
        self.gadgetMenu!.separatorStyle = UITableViewCellSeparatorStyle.None
        }
      
}
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count: Int?
        
        // Size of the shapes table
         if (objectMenu != nil) {
        if tableView == self.objectMenu {
            count = self.shapes.count
        }
        }
        // Size of the gadgets table
        if (gadgetMenu != nil) {
        if tableView == self.gadgetMenu {
            count = self.gadgets.count
        }
        }
        return count!
    }
    
    // Sets the contents of the two table views
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        if (gadgetMenu != nil) {
        // Contents of the gadgets Table
        if tableView == self.gadgetMenu {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
            //cell.textLabel?.text = shapes[indexPath.row]
            cell!.imageView!.image = UIImage(named: gadgets[indexPath.row] )
            cell!.backgroundColor = UIColor.blackColor()
        }
        }
        
        // Contents of the shapes table
        if (objectMenu != nil) {
        if tableView == self.objectMenu {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
            //cell.textLabel?.text = shapes[indexPath.row]
            cell!.imageView!.image = UIImage(named: shapes[indexPath.row])
            cell!.backgroundColor = UIColor.blackColor()
        }
        }
        return cell!
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    self.performSegueWithIdentifier("toHomeView", sender: self)
        
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toHomeView" {
            let destinationViewController = segue.destinationViewController as! GameViewController;
            if (objectMenu != nil) {
            destinationViewController.setflag((objectMenu.indexPathForSelectedRow?.row)!)
            }
            // setup the destination controller
        }
    }
}