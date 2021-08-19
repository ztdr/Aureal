//
//  StatusBarController.swift
//  Aureal
//
//  Copyright © 2021 Aluveitie All rights reserved.
//

import Foundation
import AppKit

class StatusBarController {
    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem
    
    init() {
        statusBar = NSStatusBar.init()
        statusItem = statusBar.statusItem(withLength: 28.0)
        
        if let statusBarButton = statusItem.button {
            statusBarButton.image = #imageLiteral(resourceName: "status")
            statusBarButton.image?.size = NSSize(width: 18.0, height: 18.0)
            statusBarButton.action = #selector(toggleWindow(sender:))
            statusBarButton.target = self
        }
    }
    
    @objc func toggleWindow(sender: AnyObject) {
        let mainWindow = NSApplication.shared.windows.first!
        if (mainWindow.isVisible) {
            mainWindow.close()
        } else {
            mainWindow.makeKeyAndOrderFront(nil)
            NSApplication.shared.activate(ignoringOtherApps: true)
        }
    }
}
