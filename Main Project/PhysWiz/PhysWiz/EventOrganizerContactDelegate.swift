//
//  EventOrganizerContactDelegate.swift
//  PhysWiz
//
//  Created by Chiem Saeteurn on 4/26/16.
//  Copyright © 2016 Intuition. All rights reserved.
//
//  The contact delegate that will handle when two objects
//  collide. It will communicate with the EventOrganizer
//  to check if the objects collided is a highlighted event.

import Foundation
import UIKit
import SpriteKit

class EventOrganizerContactDelegate: NSObject, SKPhysicsContactDelegate {
    var timeEvents      = [Event](); // Anything that handles time
    var posEvents       = [Event](); // Anything that handles position, acceleration, velocity
    var collisionEvents = [Event](); // Handles Collision Events;

    func didBeginContact(contact: SKPhysicsContact) {
        let body1 = contact.bodyA;
        let body2 = contact.bodyB;
        
//        print((body1.node?.name)! + " collided with " + (body2.node?.name)!);
    }
    
}