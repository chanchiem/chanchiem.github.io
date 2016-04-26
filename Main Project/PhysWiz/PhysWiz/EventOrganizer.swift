//
//  EventOrganizer.swift
//  PhysWiz
//
//  Created by Chiem Saeteurn on 4/26/16.
//  Copyright © 2016 Intuition. All rights reserved.
//
/* Class that will be instantiated into the GameScene where physics
events will be enlisted. This class will allow the user to set
specific events that will stall the game scene when they happen;
it will communicate with the game scene so that the game scene may
know when exactly objects collide into other objects, and other
events that occur. */


import Foundation

class EventOrganizer: NSObject {
    
    var eventContactDelegate: EventOrganizerContactDelegate! = nil;
    var timer: NSTimer! = nil;
    var events: [Event];
    var objs: [PWObject]; // All the objects that has an event associated with it.
    
    var timeEvents:         [PWObject: Event]! = nil
    var collisionEvents:    [PWObject: Event]! = nil
    var posEvents:          [PWObject: Event]! = nil
    

    func createTimeEvent(sprite: PWObject, time: CGFloat) {
        let event = Event.createTime(sprite, time: time)
        
        if (event == nil) { return }
        events.append(event!);
        timeEvents[sprite] = event;
    }
    
    // Check all the events that need to happen. And returns all the
    // events that have happened.
    func checkEvents() -> [Event]! {
        
        return nil;
//        return timeEvents;
    }
    
    func startEventOrganizer() {
        return;
    }
    
    
    // Creates Event Organizer object and initializes
    // the contact delegate in preparation for the events.
    required init(gamescene: GameScene) {
        events          = [Event]();
        objs            = [PWObject]();
        timeEvents      = [PWObject: Event]();
        collisionEvents = [PWObject: Event]();
        posEvents       = [PWObject: Event]();
        eventContactDelegate = EventOrganizerContactDelegate.init();
        
        gamescene.physicsWorld.contactDelegate = eventContactDelegate;
        super.init();
    }
    
    
}