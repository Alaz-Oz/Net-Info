//
//  NetInfoApp.swift
//  Net Info
//
//  Created by Afroz Alam on 24/10/24.
//

import SwiftUI

@main
struct NetInfoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            Text("Created by AlazOz (asteroidalaz@gmail.com)")
        }

    }
}

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var statusItem: NSStatusItem!
    var visualizeWindow: NSWindow?
    var settingsWindow: NSWindow?

    var prevBPS: (UInt32, UInt32) = (0, 0)

    @objc func quitApp() {
        NSApplication.shared.terminate(self)
    }

    @objc func openVisualization() {
        if let existingWindow = visualizeWindow {
            existingWindow.close()
        }

        visualizeWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 200),
            styleMask: [.closable, .titled, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        visualizeWindow?.center()
        visualizeWindow?.setFrameAutosaveName("Visuals")
        visualizeWindow?.contentView = NSHostingView(rootView: VisualizerView())
        visualizeWindow?.title = "Visualizer"
        visualizeWindow?.isReleasedWhenClosed = false
        visualizeWindow?.delegate = self

        // Show the window
        visualizeWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

    }

    @objc func openSettings() {
        if let existingWindow = settingsWindow {
            existingWindow.close()
        }

        settingsWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 300),
            styleMask: [.closable, .titled],
            backing: .buffered,
            defer: false
        )
        settingsWindow?.center()
        settingsWindow?.title = "Settings"
        settingsWindow?.contentView = NSHostingView(rootView: SettingsView())
        settingsWindow?.isReleasedWhenClosed = false
        settingsWindow?.delegate = self

        // Show the window
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the status bar item
        statusItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength
        )

        let menu = NSMenu()
        menu.addItem(
            NSMenuItem(
                title: "Visualize",
                action: #selector(openVisualization),
                keyEquivalent: ""
            )
        )
        menu.addItem(NSMenuItem.separator())
        menu.addItem(
            NSMenuItem(
                title: "Settings",
                action: #selector(openSettings),
                keyEquivalent: ","
            )
        )
        menu.addItem(
            NSMenuItem(
                title: "Quit",
                action: #selector(quitApp),
                keyEquivalent: ""
            )
        )
        statusItem?.menu = menu

        if let button = statusItem?.button {
            // Initial speed visuals
            button.attributedTitle =
                self.createAttributedString(
                    upload: NetworkMonitor.formatSpeed(0),
                    download: NetworkMonitor.formatSpeed(0)
                )
        }

        // Start monitoring the network speed
        NetworkMonitor.shared.startMonitoring {
            uploadBytesPerSec,
            downloadBytesPerSec in

            if self.prevBPS.0 != uploadBytesPerSec
                || self.prevBPS.1 != downloadBytesPerSec
            {
                // Update needed
                let uploadSpeed = NetworkMonitor.formatSpeed(
                    uploadBytesPerSec
                )
                let downloadSpeed = NetworkMonitor.formatSpeed(
                    downloadBytesPerSec
                )
                DispatchQueue.main.async {
                    self.statusItem.button?.attributedTitle =
                        self.createAttributedString(
                            upload: uploadSpeed,
                            download: downloadSpeed
                        )
                }
                self.prevBPS = (uploadBytesPerSec, downloadBytesPerSec)
            }
        }
    }

    let uploadAttributes: [NSAttributedString.Key: Any]
    let downloadAttributes: [NSAttributedString.Key: Any]

    override init() {
        let style = NSMutableParagraphStyle()
        style.alignment = .right
        style.lineHeightMultiple = 0.7

        uploadAttributes = [
            .font: NSFont.systemFont(ofSize: 9),
            .foregroundColor: NSColor.labelColor,
            .paragraphStyle: style,
        ]
        var download = uploadAttributes
        download[.baselineOffset] = -5
        downloadAttributes = download

        super.init()
    }

    // Create an attributed string with two lines for upload and download
    func createAttributedString(upload: String, download: String)
        -> NSAttributedString
    {
        let combinedString = NSMutableAttributedString()

        combinedString.append(
            NSAttributedString(
                string: "\(upload) ↑\n",
                attributes: uploadAttributes
            )
        )
        combinedString.append(
            NSAttributedString(
                string: "\(download) ↓",
                attributes: downloadAttributes
            )
        )

        return combinedString
    }

    func windowWillClose(_ notification: Notification) {
        if let closedWindow = notification.object as? NSWindow {
            if closedWindow == visualizeWindow {
                visualizeWindow = nil
            } else if closedWindow == settingsWindow {
                settingsWindow = nil
            }
        }
    }

}
