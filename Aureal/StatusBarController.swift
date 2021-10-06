//
//  StatusBarController.swift
//  Aureal
//
//  Copyright © 2021 Aluveitie All rights reserved.
//

import Foundation
import AppKit
import Cocoa
import SwiftUI

class StatusBarController {
    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem
    
    private var popover: NSPopover
    
    init() {
        statusBar = NSStatusBar.init()
        statusItem = statusBar.statusItem(withLength: 28.0)
        
        popover = NSPopover.init()
        let popupView = PopupView(popover: popover)
        popover.contentSize = NSSize(width: 120, height: 32)
        popover.contentViewController = NSHostingController(rootView: popupView)
        
        if let statusBarButton = statusItem.button {
            statusBarButton.image = #imageLiteral(resourceName: "status")
            statusBarButton.image?.size = NSSize(width: 18.0, height: 18.0)
            statusBarButton.action = #selector(togglePopover(sender:))
            statusBarButton.target = self
        }
    }
    
    @objc func togglePopover(sender: AnyObject) {
        if (popover.isShown) {
            popover.performClose(sender)
        } else {
            if let statusBarButton = statusItem.button {
                popover.show(relativeTo: statusBarButton.bounds, of: statusBarButton, preferredEdge: NSRectEdge.maxY)
            }
        }
    }
}

struct PopupView: View {
    var popover: NSPopover
    
    var body: some View {
        Button(action: { toggleWindow(); popover.close(); }) {
            Text("Open").frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        Button(action: { exit(0) }) {
            Text("Exit").frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    func toggleWindow() {
        let mainWindow = NSApplication.shared.windows.first!
        if (mainWindow.isVisible) {
            mainWindow.close()
        } else {
            mainWindow.makeKeyAndOrderFront(nil)
            NSApplication.shared.activate(ignoringOtherApps: true)
        }
    }
}
