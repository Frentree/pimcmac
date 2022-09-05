//
//  AppDelegate.swift
//  PIMC
//
//  Created by gontai Kim on 2022/08/26.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var menu: NSMenu!
    @IBOutlet weak var startPIMCService: NSMenuItem!

    @IBAction func actionStartPIMCService(_ sender: Any) {
        viewController.run()
    }

    @IBAction func actionAbout(_ sender: Any) {
        let window = NSWindow(contentViewController: aboutViewController)
        window.center()
        let windowController = NSWindowController(window: window)
        windowController.showWindow(nil)
    }
    
    var window: NSWindow!

    var statusBar: StatusBarController?
    var viewController: ViewController!
    var aboutViewController: AboutViewController!
    let popover = NSPopover()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        // Create the window and set the content view.
        window = NSApplication.shared.windows.first
        window.orderOut(self)

        //
        viewController = ViewController.freshController()
        aboutViewController = AboutViewController.freshController()
        statusBar = StatusBarController.init(menu)

        viewController.checkHelperVersionAndUpdateIfNecessary { installed in
            if !installed {
                self.viewController.installHelperDaemon()
            }
            // Create an empty authorization reference
            self.viewController.initAuthorizationRef()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        viewController.freeAuthorizationRef()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

