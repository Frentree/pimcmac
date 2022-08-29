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
    var viewController: ViewController!
    let popover = NSPopover()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        // Create the window and set the content view.
        window = NSApplication.shared.windows.first
        window.orderOut(self)

        //
        viewController = ViewController.freshController()

        popover.contentSize = NSSize(width: 640, height: 480)
        popover.contentViewController = viewController
        popover.behavior = NSPopover.Behavior.semitransient

        statusBar = StatusBarController.init(popover)

//        viewController.checkHelperVersionAndUpdateIfNecessary { installed in
//            if !installed {
                self.viewController.installHelperDaemon()
//            }
            // Create an empty authorization reference
            self.viewController.initAuthorizationRef()
//        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        viewController.freeAuthorizationRef()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

