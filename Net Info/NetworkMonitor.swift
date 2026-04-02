//
//  NetworkMonitor.swift
//  Net Info
//
//  Created by Afroz Alam on 25/10/24.
//

import SwiftUI

class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    private var timer: Timer?
    private var reload = true

    private var previousUpload: UInt32 = 0
    private var previousDownload: UInt32 = 0

    @AppStorage("SelectedInterface") var currentInterface = "en0"
    @AppStorage("SelectedInterfaces") var selectedInterfaces: Set<String> = ["en0"]
    let buffer = NetworkSpeedBuffer(size: 60)

    var ipAddr: String = "Loading ..."
    
    func startMonitoring(
        callback:
            @escaping (
                _ uploadBytesPerSecond: UInt32, _ downloadBytesPerSecond: UInt32
            ) ->
            Void
    ) {

        // Schedule timer to fetch network data every second
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            _ in
            if self.reload {
                // Initialize previous values
                (self.previousUpload, self.previousDownload) =
                    self.getNetworkData(for: self.selectedInterfaces)
                self.buffer.reset()
                self.reload = false
            }
            let (upload, download) = self.getNetworkData(
                for: self.selectedInterfaces
            )

            // Calculate upload and download speeds in bytes per second
            let uploadBytesPerSecond = self.getGap(
                curr: upload,
                pre: self.previousUpload
            )
            let downloadBytesPerSecond = self.getGap(
                curr: download,
                pre: self.previousDownload
            )
            self.buffer.push(
                uploadBytesPerSecond,
                downloadBytesPerSecond
            )
            // Update previous values for next calculation
            self.previousUpload = upload
            self.previousDownload = download

            // Pass formatted strings to the callback
            callback(
                uploadBytesPerSecond,
                downloadBytesPerSecond
            )
        }
    }

    func getGap(curr: UInt32, pre: UInt32) -> UInt32 {
        if curr < pre {
            return UINT32_MAX - pre + curr
        }
        return curr - pre
    }

    func getIpAddress(for interfaceName: String) -> String? {
        var interfaceAddresses: UnsafeMutablePointer<ifaddrs>? = nil

        guard getifaddrs(&interfaceAddresses) == 0 else { return nil }
        defer { freeifaddrs(interfaceAddresses) }

        var pointer = interfaceAddresses

        while let interface = pointer?.pointee {
            defer { pointer = interface.ifa_next }
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))

            if strcmp(interface.ifa_name, interfaceName) == 0,
                let addr = interface.ifa_addr,
                addr.pointee.sa_family == sa_family_t(AF_INET),
                getnameinfo(
                    addr,
                    socklen_t(addr.pointee.sa_len),
                    &hostname,
                    socklen_t(hostname.count),
                    nil,
                    0,
                    NI_NUMERICHOST
                ) == 0
            {
                return String(cString: hostname)
            }

        }

        return nil
    }
    func getAvailableInterfaces() -> [String] {
        var interfaceAddresses: UnsafeMutablePointer<ifaddrs>? = nil

        guard getifaddrs(&interfaceAddresses) == 0 else { return [] }
        defer { freeifaddrs(interfaceAddresses) }

        var availableInterfaces = Set<String>()
        var pointer = interfaceAddresses

        while let interface = pointer?.pointee {
            defer { pointer = interface.ifa_next }

            let name = String(cString: interface.ifa_name)

            if name.hasPrefix("en") {
                availableInterfaces.insert(name)
            }
        }
        return Array(availableInterfaces).sorted()
    }

    func getNetworkData(for interfaceName: Set<String>) -> (UInt32, UInt32) {
        var interfaceAddresses: UnsafeMutablePointer<ifaddrs>? = nil
        guard getifaddrs(&interfaceAddresses) == 0 else { return (0, 0) }
        defer { freeifaddrs(interfaceAddresses) }

        var upload: UInt32 = 0
        var download: UInt32 = 0

        var pointer = interfaceAddresses
        while let interface = pointer?.pointee {
            defer { pointer = interface.ifa_next }

            if interfaceName.contains(String(cString: interface.ifa_name)),
                let ifaData = interface.ifa_data
            {
                let data = ifaData.assumingMemoryBound(to: if_data.self)
                    .pointee
                upload += data.ifi_obytes
                download += data.ifi_ibytes
            }
        }

        return (upload, download)
    }

        func getCurrentInterface() -> String {
            return currentInterface
        }
    
        func setCurrentInterface(_ name: String) {
            currentInterface = name
            ipAddr = getIpAddress(for: name) ?? "Unknown"
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
