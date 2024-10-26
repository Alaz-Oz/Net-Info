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

    private var previousUpload: UInt64 = 0
    private var previousDownload: UInt64 = 0

    func startMonitoring(
        callback: @escaping (_ uploadSpeed: String, _ downloadSpeed: String) ->
            Void
    ) {
        // Initialize previous values
        (previousUpload, previousDownload) = getNetworkData()

        // Schedule timer to fetch network data every second
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            _ in
            let (upload, download) = self.getNetworkData()

            // Calculate upload and download speeds in bytes per second
            let uploadBytesPerSecond = upload - self.previousUpload
            let downloadBytesPerSecond = download - self.previousDownload

            // Update previous values for next calculation
            self.previousUpload = upload
            self.previousDownload = download

            // Format speeds with appropriate units
            let uploadSpeed = self.formatSpeed(uploadBytesPerSecond)
            let downloadSpeed = self.formatSpeed(downloadBytesPerSecond)

            // Pass formatted strings to the callback
            callback(uploadSpeed, downloadSpeed)
        }
    }

    func getNetworkData() -> (UInt64, UInt64) {
        var interfaceAddresses: UnsafeMutablePointer<ifaddrs>? = nil
        var upload: UInt64 = 0
        var download: UInt64 = 0

        // Get network interfaces
        if getifaddrs(&interfaceAddresses) == 0 {
            var pointer = interfaceAddresses
            while pointer != nil {
                defer { pointer = pointer?.pointee.ifa_next }

                let interface = pointer!.pointee
                let name = String(cString: interface.ifa_name)

                // Filter for active Wi-Fi (en0) interface
                if name == "en0", let ifaData = interface.ifa_data {
                    let data = ifaData.assumingMemoryBound(to: if_data.self)
                        .pointee
                    upload += UInt64(data.ifi_obytes)
                    download += UInt64(data.ifi_ibytes)
                }
            }
            freeifaddrs(interfaceAddresses)
        }

        return (upload, download)
    }
    // Helper function to format speed with units
    func formatSpeed(_ bytesPerSecond: UInt64) -> String {

        if bytesPerSecond > 1024 * 1024 {
            return String(format: "%3d MB/s", bytesPerSecond / 1024 * 1024)
        } else if bytesPerSecond > 1024 {
            return String(format: "%3d KB/s", bytesPerSecond / 1024)
        }
        return String(format: "%3d B/s", bytesPerSecond)

    }
}
