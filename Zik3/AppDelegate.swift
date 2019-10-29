//
//  AppDelegate.swift
//  Zik3
//
//  Created by Nicolas Thomas on 03/05/2018.
//  Copyright © 2018 Nicolas Thomas. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    
    let deviceState = DeviceState()
    var service: BTCommunicationServiceInterface?
    let statusItem = NSStatusBar.system.statusItem(withLength: -1)
    let iconOff = NSImage(named: NSImage.Name(rawValue: "disc"))
    let iconOn = NSImage(named: NSImage.Name(rawValue: "conn"))
    
    var notificationGiven: Bool = false;
    
//    @objc
//    func toggleNoiseCancellation(sender: AnyObject) {
//        service?.setNoiseControlLevel(NoiseControlState(level: 1, mode: "anc"))
//
//        let _ = service?.toggleAsyncNoiseCancellation(!self.deviceState.noiseCancellationEnabled)
//    }
    
    @objc
    func turnAncAocOff(sender: AnyObject) {
        service?.turnAncAocOff();
        
        let _ = false;
    }
    
    @objc
    func turnAncOn(sender: AnyObject) {
        service?.turnAncOn();
    }
    
    @objc
    func turnAncL2On(sender: AnyObject) {
        service?.turnAncL2On();
    }
    
    @objc
    func turnAocOn(sender: AnyObject) {
        service?.turnAocOn();
    }
    
    @objc
    func turnAocL2On(sender: AnyObject) {
        service?.turnAocL2On();
    }
    
    @objc
    func toggleConcertHall(sender: AnyObject) {
        let _ = service?.toggleAsyncConcertHall(!self.deviceState.concertHallEnabled)
    }
    
    @objc
    func toggleEqualizer(sender: AnyObject) {
        let _ = service?.toggleAsyncEqualizerStatus(!self.deviceState.equalizerEnabled)
    }
    
    @objc
    func quit(sender: AnyObject) {
        NSApplication.shared.terminate(self)
    }
    
    @objc
    func doMenu() {
        if self.deviceState.name == "" {
            iconOff?.isTemplate = true

            statusItem.button?.image = iconOff
        }else{
            iconOn?.isTemplate = true
            statusItem.button?.image = iconOn

        }
        
        let menu = NSMenu(title: "Contextual menu")
        var menuItem = menu.addItem(withTitle: self.deviceState.name, action: nil, keyEquivalent: "")
        
        var title = "Battery level: " + self.deviceState.batteryLevel + "%"
        menuItem = menu.addItem(withTitle: title, action: nil, keyEquivalent: "")
        menuItem.indentationLevel = 1
        
        let batterylevel: Int? = Int(self.deviceState.batteryLevel)
        if batterylevel != nil {
            if (batterylevel! == 20 || batterylevel! == 10) && !notificationGiven  {
                // Give a notification
                showNotification(title: "Parrot Zik", body: "Battery is low. Please recharge")
            }
            if batterylevel! < 20 && batterylevel! > 10 {
                notificationGiven = false
                }            
        }
        
        title = "Power Source: " + (self.deviceState.batteryStatus == "charging" ? "Power Adapter" : "Battery")
        menuItem = menu.addItem(withTitle: title, action: nil, keyEquivalent: "")
        menuItem.indentationLevel = 1
        
        menuItem = menu.addItem(withTitle: "OFF: Noise cancelling & Street Mode", action: #selector(self.turnAncAocOff), keyEquivalent: "")
        menuItem.indentationLevel = 1
        menuItem.state = !self.deviceState.noiseCancellationEnabled ?
            NSControl.StateValue.on : NSControl.StateValue.off
        
        menuItem = menu.addItem(withTitle: "Noise cancelling | Medium", action: #selector(self.turnAncOn), keyEquivalent: "")
        menuItem.indentationLevel = 2
        menuItem.state = self.deviceState.ancEnabled ?
            NSControl.StateValue.on : NSControl.StateValue.off
        
        menuItem = menu.addItem(withTitle: "Noise cancelling | Strong", action: #selector(self.turnAncL2On), keyEquivalent: "")
        menuItem.indentationLevel = 2
        menuItem.state = self.deviceState.ancL2Enabled ?
            NSControl.StateValue.on : NSControl.StateValue.off
        
        menuItem = menu.addItem(withTitle: "Street mode | Medium", action: #selector(self.turnAocOn), keyEquivalent: "")
        menuItem.indentationLevel = 2
        menuItem.state = self.deviceState.aocEnabled ?
            NSControl.StateValue.on : NSControl.StateValue.off
        
        menuItem = menu.addItem(withTitle: "Street mode | Strong", action: #selector(self.turnAocL2On), keyEquivalent: "")
        menuItem.indentationLevel = 2
        menuItem.state = self.deviceState.aocL2Enabled ?
            NSControl.StateValue.on : NSControl.StateValue.off
        
        menuItem = menu.addItem(withTitle: "Equalizer", action: #selector(self.toggleEqualizer), keyEquivalent: "")
        menuItem.indentationLevel = 1
        menuItem.state = self.deviceState.equalizerEnabled ?
            NSControl.StateValue.on : NSControl.StateValue.off
        
        menuItem = menu.addItem(withTitle: "Concert hall", action: #selector(self.toggleConcertHall(sender:)), keyEquivalent: "")
        menuItem.indentationLevel = 1
        menuItem.state = self.deviceState.concertHallEnabled ?
            NSControl.StateValue.on : NSControl.StateValue.off
        
        menuItem = menu.addItem(withTitle: "Quit", action: #selector(self.quit), keyEquivalent: "")
        menuItem.indentationLevel = 1
        statusItem.menu = menu
        
    
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.service = BTCommunicationService(api: ParrotZik2Api(),
                                              zikResponseHandler: ZikResponseHandler(deviceState: deviceState))
        let _ = BTConnectionService(service: self.service!)
        
        Timer.scheduledTimer(timeInterval: 1,
                             target: self,
                             selector: #selector(self.doMenu),
                             userInfo: nil,
                             repeats: true)
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func showNotification(title: String, body: String) -> Void {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = body
        notification.hasActionButton = true
        notification.actionButtonTitle = "Action Button"

        notification.soundName = NSUserNotificationDefaultSoundName

        notificationGiven = true;
        NSUserNotificationCenter.default.delegate = self as? NSUserNotificationCenterDelegate
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter,
                                shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    

    
}
