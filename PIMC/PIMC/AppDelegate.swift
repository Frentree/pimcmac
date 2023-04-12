//
//  AppDelegate.swift
//  PIMC
//
//  Created by gontai Kim on 2022/08/26.
//

import Cocoa
import OSLog

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var menu: NSMenu!
    @IBOutlet weak var startPIMCService: NSMenuItem!

    @IBAction func actionStartPIMCService(_ sender: Any) {
//        트레이 아이콘 비활성화로 인한 주석처리 230412 by hjh
//        viewController.run()
    }

    @IBAction func actionHomepage(_ sender: Any) {
        let url = URL(string: Constants.HOMEPAGE)!
        if NSWorkspace.shared.open(url) {
            print("default browser was successfully opened")

        }
    }

    @IBAction func actionServiceCheck(_ sender: Any) {
        os_log("actionServiceCheck")
    }

    @IBAction func actionAbout(_ sender: Any) {
        let window = NSWindow(contentViewController: aboutViewController)
        window.center()
        window.level = .statusBar
        let windowController = NSWindowController(window: window)
        windowController.showWindow(nil)
    }
    
    var window: NSWindow!
//        트레이 아이콘 비활성화로 인한 주석처리 230412 by hjh
//    var statusBar: StatusBarController?
//    var viewController: ViewController!
    var aboutViewController: AboutViewController!
    let popover = NSPopover()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        // Create the window and set the content view.
        window = NSApplication.shared.windows.first
        window.orderOut(self)

        //
//        트레이 아이콘 비활성화로 인한 주석처리 230412 by hjh
//        viewController = ViewController.freshController()
        aboutViewController = AboutViewController.freshController()
//        트레이 아이콘 비활성화로 인한 주석처리 230412 by hjh
//        statusBar = StatusBarController.init(menu)

        // auto run with start app
//        트레이 아이콘 비활성화로 인한 주석처리 230412 by hjh
//        viewController.run()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

