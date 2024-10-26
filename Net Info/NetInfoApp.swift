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




class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
//    var windowController: MyWindowController?

    @objc func quitApp() {
        NSApplication.shared.terminate(self)
    }
    @objc func showVisualGraph() {
//        if windowcontroller == nil {
//            windowController = MyWindowController
//        }
        
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
}
