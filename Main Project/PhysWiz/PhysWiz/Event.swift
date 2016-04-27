//
//  Event.swift
//  PhysWiz
//
//  Created by Chiem Saeteurn on 4/26/16.
//  Copyright © 2016 Intuition. All rights reserved.
//
//  An Event object that will be used by the Event Organizer.
//  Every event that is created will instantiate this event object.
//  This object can either be a time element, a contact element,
//  or a distance element.
//  There are three types of events:
//  Collision - Any type of collision between two objects.
//  Time      - Any type of event that relies on time passing by.
//  Pos       - Any type of event that requires change of position (Velocity, acceleration, etc)

import Foundation

class Event: NSObject {
    private var isCollision = false;
    private var isTime      = false;
    private var isPos       = false;
    private var alive       = true;  // Is the event still being checked?
    
    ////////////////////////////////////////////////////////////
    //////////////// Collision Variables ///////////////////////
    ////////////////////////////////////////////////////////////
    private var sprite1: PWObject! = nil; // Also used for time
    private var sprite2: PWObject! = nil;
    
    ////////////////////////////////////////////////////////////
    //////////////// Time Variables ////////////////////////////
    ////////////////////////////////////////////////////////////
    private var time: CGFloat! = nil;
    
    
    // Has the event already been executed?
    func hasHappened() -> Bool { return !self.alive; }
    func setHappened() { self.alive = false; }
    
    ////////////////////////////////////////////////////////////
    //////////////// Collision Parameters //////////////////////
    ////////////////////////////////////////////////////////////
    
    // Returns the sprites of the event. If it's not collision event,
    // then it returns nothing.
    func getSprites() -> [PWObject]? {
        if (!isCollision) { return nil; }
        return [sprite1, sprite2];
    }
    func setSprites(sprite1: PWObject, sprite2: PWObject) {
        if (!isCollision) { return; }
        self.sprite1 = sprite1;
        self.sprite2 = sprite2;
    }
    
    func isCollisionEvent() -> Bool { return self.isCollision }
    
    
    ////////////////////////////////////////////////////////////
    //////////////// Time Parameters ///////////////////////////
    ////////////////////////////////////////////////////////////
    
    func compTime(event1: Event, event2:Event) -> Bool {
        return (event1.getTime() > event2.getTime());
    }

    func getTime() -> CGFloat? {
        if (!isTime) { return nil; }
        return time;
    }
    func setTime(time: CGFloat) { self.time = time; }
    
    
    ////////////////////////////////////////////////////////////
    
    
    private init(isCollision: Bool, isTime: Bool, isPos: Bool) {
        self.isCollision = isCollision;
        self.isTime      = isTime;
        self.isPos       = isPos;
    }
    
    static func createCollision(sprite1: PWObject, sprite2: PWObject) -> Event? {
        if (!PWObject.isPWObject(sprite1) && !PWObject.isPWObject(sprite2)) { return nil; }
        let event = Event.init(isCollision: true, isTime: false, isPos: false)
    
        event.sprite1 = sprite1;
        event.sprite2 = sprite2;
        
        return event;
    }
    
    static func createTime(sprite: PWObject, time: CGFloat) -> Event? {
        if (!PWObject.isPWObject(sprite)) { return nil; }
        let event = Event.init(isCollision: false, isTime: true, isPos: false)
        
        event.sprite1 = sprite;
        event.time = time;
        
        return event;
    }
    
}