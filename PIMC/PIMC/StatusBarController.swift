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

    private var menu: NSMenu
    private let statusItem = NSStatusBar.system.statusItem(withLength: 18.0)

    init(_ menu: NSMenu) {
        self.menu = menu
        statusBar = NSStatusBar.init()

        if let statusBarButton = statusItem.button {
            statusBarButton.image = #imageLiteral(resourceName: "logo gray")
            statusBarButton.image?.size = NSSize(width: 18.0, height: 18.0)
            statusBarButton.image?.isTemplate = false
        }

        statusItem.menu = menu
    }

    func changeIcon(image: NSImage) {
        if let statusBarButton = statusItem.button {
            statusBarButton.image = image
            statusBarButton.image?.size = NSSize(width: 18.0, height: 18.0)
            statusBarButton.image?.isTemplate = false
        }
    }
}
