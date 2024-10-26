//
//  VisualizerWindow.swift
//  Net Info
//
//  Created by Afroz Alam on 25/10/24.
//

import SwiftUI

class MyWindowController: NSWindowController {

    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 100),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "My Window"
        
        self.init(window: window)
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Create and configure the label
        let label = NSTextField(labelWithString: "Hello, World!")
        label.font = NSFont.systemFont(ofSize: 18)
        label.alignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Add label to the window's content view
        if let contentView = window?.contentView {
            contentView.addSubview(label)
            
            // Center the label horizontally and vertically
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
        }
    }
}
