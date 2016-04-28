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
    var event: Event!;  // The event that we will be analyzing.
    var scene: GameScene;
    
    
    // This function is called by the Contact Delegate to check if
    // collision matches with the event. It is called pretty constantly.
    func triggerAndCheckCollision(sprite1: PWObject, sprite2: PWObject)
    {
        if (event == nil) { return }
        if (!event.isCollisionEvent()) { return; }
        
        let eventSprites = event.getSprites();
        if (eventSprites?.count != 2) { return; }
        
        
        if (!(eventSprites?.contains(sprite1))!) { return; }
        if (!(eventSprites?.contains(sprite2))!) { return; }
        
        // Collision matches with event!
        event.setHappened();
        scene.collisionEventTriggered(sprite1, sprite2: sprite2);
    }
    
    
    func createCollisionEvent(sprite1: PWObject, sprite2: PWObject) {
        let event = Event.createCollision(sprite1, sprite2: sprite2)
        
        if (event == nil) { return };
        print("Created collision event");
        
        self.event = event!
    }
    
//    func createTimeEvent(time: CGFloat)
//    {
//        let event = Event.createTime(<#T##sprite: PWObject##PWObject#>, time: <#T##CGFloat#>)
//    }
    
    // Resets the current event.
    func resetEvent() -> Event! {
        if (event == nil) { return nil; }
        
        let prev = event;
        event = nil;
        
        return prev;
    }
    
    // Has the event occured yet?
    func hasEventOccurred() -> Bool { return event.hasHappened() }
    
    func containsEvent() -> Bool { return (event != nil) }
    
    // Creates Event Organizer object and initializes
    // the contact delegate in preparation for the events.
    required init(gamescene: GameScene) {
        scene = gamescene;
        super.init();
        eventContactDelegate = EventOrganizerContactDelegate.init(eo: self);
        gamescene.physicsWorld.contactDelegate = eventContactDelegate;
    }
    
    
}