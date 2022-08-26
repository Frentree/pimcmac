//
//  AppDelegate.swift
//  PIMC
//
//  Created by gontai Kim on 2022/08/26.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    
    var window: NSWindow!

    var statusBar: StatusBarController?
    var popover: NSPopover!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        // Create the window and set the content view.
        window = NSApplication.shared.windows.first
        window.orderOut(self)

        //
        popover = NSPopover.init()
        popover.contentSize = NSSize(width: 360, height: 360)
        popover.contentViewController = window.contentViewController

        statusBar = StatusBarController.init(popover)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

