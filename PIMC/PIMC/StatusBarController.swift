//
//  StatusBarController.swift
//  PIMC
//
//  Created by gontai Kim on 2022/08/26.
//

import Foundation
import AppKit

class StatusBarController {
    private var statusBar: NSStatusBar
    var statusItem: NSStatusItem

    private var popover: NSPopover

    init(_ popover: NSPopover) {
        self.popover = popover
        statusBar = NSStatusBar.init()

        // 메뉴바 길이 고정
        statusItem = statusBar.statusItem(withLength: 30.0)

        if let statusBarButton = statusItem.button {
            statusBarButton.image = #imageLiteral(resourceName: "logo gray")
            statusBarButton.image?.size = NSSize(width: 18.0, height: 18.0)
            statusBarButton.image?.isTemplate = false

            statusBarButton.action = #selector(togglePopover(sender:))
            statusBarButton.target = self
        }
    }

    @objc func togglePopover(sender: AnyObject) {
        if (popover.isShown) {
            hidePopover(sender)
        }
        else {
            showPopover(sender)
        }
    }

    func showPopover(_ sender: AnyObject) {
        if let statusBarButton = statusItem.button {
            popover.show(relativeTo: statusBarButton.bounds, of: statusBarButton, preferredEdge: NSRectEdge.maxY)
        }
    }

    func hidePopover(_ sender: AnyObject) {
        popover.performClose(sender)
    }
}
