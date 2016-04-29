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
    private var isCollision                     = false;
    private var isTime                          = false;
    private var isPos                           = false;
    private var alive                           = true;  // Is the event still being checked?
    private var eventorganizer: EventOrganizer
    
    ////////////////////////////////////////////////////////////
    //////////////// Collision Variables ///////////////////////
    ////////////////////////////////////////////////////////////
    private var sprite1: PWObject! = nil; // Also used for time
    private var sprite2: PWObject! = nil;
    
    ////////////////////////////////////////////////////////////
    //////////////// Time Variables ////////////////////////////
    ////////////////////////////////////////////////////////////
    private var time: CGFloat!  = nil;
    private var timer: NSTimer! = nil;
    
    
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
    
    // This function is called by the Contact Delegate to check if
    // collision matches with the event. It is called pretty constantly.
    func checkAndTriggerCollision(sprite1: PWObject, sprite2: PWObject)
    {
        if (!self.isCollisionEvent()) { return; }
        
        let eventSprites = self.getSprites();
        if (eventSprites?.count != 2) { return; }
        
        
        if (!(eventSprites?.contains(sprite1))!) { return; }
        if (!(eventSprites?.contains(sprite2))!) { return; }
        
        // Collision matches with event!
        self.setHappened();
        eventorganizer.triggerEvent(self);
    }
    
    
    ////////////////////////////////////////////////////////////
    //////////////// Time Parameters ///////////////////////////
    ////////////////////////////////////////////////////////////
    
    func isTimerEvent() -> Bool { return self.isTime }

    // Gets the upper bound of the
    func getMaxTime() -> CGFloat? {
        if (!isTime) { return nil; }
        return time;
    }
    
    func setTime(time: CGFloat) {
        if (!isTime) { return }
        self.time = time;
    }
    
    func startTimer() {
        if (!isTime) { return }
        if (self.timer == nil) { return }
        self.timer.fire();
    }
    
    func pauseTimer() {
        if (!isTime) { return }
        if (self.timer == nil) { return };
    }
    
    func initTimer(time: CGFloat) {
        self.setTime(time);
        let selector_func = #selector(self.triggerTimer)
        self.timer = NSTimer.scheduledTimerWithTimeInterval(Double(time), target: self, selector: selector_func, userInfo: nil, repeats: false);
    }
    
    func triggerTimer() {
        NSLog("Timer triggered!");
        self.setHappened();
        eventorganizer.triggerEvent(self);
    }
    
    
    ////////////////////////////////////////////////////////////
    
    
    private init(isCollision: Bool, isTime: Bool, isPos: Bool, eo: EventOrganizer) {
        self.isCollision    = isCollision;
        self.isTime         = isTime;
        self.isPos          = isPos;
        self.eventorganizer = eo;
    }
    
    static func createCollision(eo:EventOrganizer, sprite1: PWObject, sprite2: PWObject) -> Event? {
        if (!PWObject.isPWObject(sprite1) && !PWObject.isPWObject(sprite2)) { return nil; }
        let event = Event.init(isCollision: true, isTime: false, isPos: false, eo: eo)
    
        event.sprite1 = sprite1;
        event.sprite2 = sprite2;
        
        return event;
    }
    
    static func createTime(eo:EventOrganizer, sprite: PWObject, time: CGFloat) -> Event? {
        if (!PWObject.isPWObject(sprite)) { return nil; }
        let event = Event.init(isCollision: false, isTime: true, isPos: false, eo: eo)
        
        event.sprite1 = sprite;
        event.initTimer(time);
        
        return event;
    }
    
}