//
//  NetworkMonitor.swift
//  Net Info
//
//  Created by Afroz Alam on 25/10/24.
//

import SwiftUI

class NetworkMonitor {
    static let shared = NetworkMonitor()
    private var timer: Timer?
    private var reload = true

    private var previousUpload: UInt32 = 0
    private var previousDownload: UInt32 = 0

    @AppStorage("SelectedInterface") private var currentInterface = "en0"
    let buffer = NetworkSpeedBuffer(size: 60)

    var availableInterfaces: [String] = []

    func startMonitoring(
        callback: @escaping (_ uploadBytesPerSecond: UInt32, _ downloadBytesPerSecond: UInt32) ->
            Void
    ) {

        // Schedule timer to fetch network data every second
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            _ in
            if self.reload {
                // Initialize previous values
                (self.previousUpload, self.previousDownload) =
                    self.getNetworkData()
                self.buffer.reset()
                self.reload = false
            }
            let (upload, download) = self.getNetworkData()

            // Calculate upload and download speeds in bytes per second
            let uploadBytesPerSecond = self.getGap(
                curr: upload,
                pre: self.previousUpload
            )
            let downloadBytesPerSecond = self.getGap(
                curr: download,
                pre: self.previousDownload
            )
            self.buffer.push(uploadBytesPerSecond, downloadBytesPerSecond)
            // Update previous values for next calculation
            self.previousUpload = upload
            self.previousDownload = download


            // Pass formatted strings to the callback
            callback(uploadBytesPerSecond, downloadBytesPerSecond)
        }
    }

    func getGap(curr: UInt32, pre: UInt32) -> UInt32 {
        if curr < pre {
            return UINT32_MAX - pre + curr
        }
        return curr - pre
    }

    func getNetworkData() -> (UInt32, UInt32) {
        var interfaceAddresses: UnsafeMutablePointer<ifaddrs>? = nil
        var upload: UInt32 = 0
        var download: UInt32 = 0

        // Get network interfaces
        if getifaddrs(&interfaceAddresses) == 0 {
            var pointer = interfaceAddresses
            while pointer != nil {
                defer { pointer = pointer?.pointee.ifa_next }

                let interface = pointer!.pointee
                let name = String(cString: interface.ifa_name)

                if name.hasPrefix("en"), !availableInterfaces.contains(name) {
                    availableInterfaces.append(name)
                }

                // Filter for current interface
                if name == currentInterface, let ifaData = interface.ifa_data {
                    let data = ifaData.assumingMemoryBound(to: if_data.self)
                        .pointee
                    upload += data.ifi_obytes
                    download += data.ifi_ibytes
                }
            }
            freeifaddrs(interfaceAddresses)
        }

        return (upload, download)
    }
    func getCurrentInterface() -> String {
        return currentInterface
    }
    func setCurrentInterface(_ name: String) {
        currentInterface = name
        reload = true
    }

    // Helper function to format speed with units
    static func formatSpeed(_ bytesPerSecond: UInt32) -> String {

        if bytesPerSecond > 1024 * 1024 {
            return String(
                format: "%.2f MB/s",
                Float(bytesPerSecond) / (1024 * 1024)
            )
        } else if bytesPerSecond > 1024 {
            return String(format: "%3d KB/s", bytesPerSecond / 1024)
        }
        return String(format: "%3d B/s", bytesPerSecond)

    }
}
