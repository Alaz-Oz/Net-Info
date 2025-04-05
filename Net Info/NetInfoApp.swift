//
//  Net_InfoApp.swift
//  Net Info
//
//  Created by Afroz Alam on 24/10/24.
//

import SwiftUI

@main
struct NetInfoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        //                WindowGroup {
        //                    ContentView()
        //                }
        Settings {
            Text("Created by AlazOz (asteroidalaz@gmail.com)")
        }

    }
}




class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var statusItem: NSStatusItem!
    var visualizeWindow: NSWindow?

    @objc func quitApp() {
        NSApplication.shared.terminate(self)
    }

    @objc func showVisualGraph() {
        if visualizeWindow == nil {
            // Making a new window
            visualizeWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 300, height: 200),
                styleMask: [.closable, .titled, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            visualizeWindow?.center()
            visualizeWindow?.setFrameAutosaveName("Visuals")
            visualizeWindow?.contentView = NSHostingView(rootView: ContentView())
            visualizeWindow?.title = "Visualizer"
            visualizeWindow?.delegate = self
            visualizeWindow?.isReleasedWhenClosed = false
        }
        
        // Show the window
        visualizeWindow?.makeKeyAndOrderFront(nil)
        if #available(macOS 14.0, *) {
            NSApp.activate()
        } else {
            NSApp.activate(ignoringOtherApps: true)
        }
        
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.alignment = .right
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Visualze", action: #selector(showVisualGraph), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: ""))
        statusItem?.menu = menu
        
        
        // Start monitoring the network speed
        NetworkMonitor.shared.startMonitoring {
            uploadSpeed, downloadSpeed in
            DispatchQueue.main.async {
                self.statusItem.button?.attributedTitle =
                    self.createAttributedString(upload: uploadSpeed, download: downloadSpeed)
            }
        }
    }

    // Create an attributed string with two lines for upload and download
    func createAttributedString(upload: String, download: String)
        -> NSAttributedString
    {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right
        paragraphStyle.lineHeightMultiple = 0.7

        let uploadAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 9),
            .foregroundColor: NSColor.labelColor,
            .paragraphStyle: paragraphStyle,
        ]

        let downloadAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 9),
            .foregroundColor: NSColor.labelColor,
            .paragraphStyle: paragraphStyle,
            .baselineOffset: -5,
        ]

        let uploadString = NSAttributedString(
            string: upload + " ↑\n", attributes: uploadAttributes)
        let downloadString = NSAttributedString(
            string: download + " ↓", attributes: downloadAttributes)

        let combinedString = NSMutableAttributedString()

        combinedString.append(uploadString)
        combinedString.append(downloadString)

        return combinedString
    }


    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow, window == visualizeWindow {
            visualizeWindow = nil
        }
    }

}

// MARK: - NSWindowDelegate
