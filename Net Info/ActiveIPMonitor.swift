//
//  ActiveIPMonitor.swift
//  Net Info
//
//  Created by Afroz Alam on 07/04/26.
//

import Foundation
import Network

class ActiveIPMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "IPMonitor")
    private var activeInterfaceName: String?

    @Published var ipAddr: String = "Unknown"

    init() {
        startMonitoring()
    }

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            // The first interface is the default route
            if let primaryInterface = path.availableInterfaces.first {
                self?.activeInterfaceName = primaryInterface.name

                let ipAddr = self?.getActiveIpAddress() ?? "Unknown"

                DispatchQueue.main.async {
                    self?.ipAddr = ipAddr
                }
            } else {
                self?.activeInterfaceName = nil
            }
        }
        monitor.start(queue: monitorQueue)
    }

    private func getActiveIpAddress() -> String? {
        guard let interfaceName = activeInterfaceName else { return nil }

        var interfaceAddresses: UnsafeMutablePointer<ifaddrs>? = nil

        guard getifaddrs(&interfaceAddresses) == 0 else { return nil }
        defer { freeifaddrs(interfaceAddresses) }

        var pointer = interfaceAddresses

        while let interface = pointer?.pointee {
            defer { pointer = interface.ifa_next }

            // IPv4 only, just because I like it
            guard let addr = interface.ifa_addr,
                addr.pointee.sa_family == sa_family_t(AF_INET),
                strcmp(interface.ifa_name, interfaceName) == 0
            else { continue }

            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))

            if getnameinfo(
                addr,
                socklen_t(addr.pointee.sa_len),
                &hostname,
                socklen_t(hostname.count),
                nil,
                0,
                NI_NUMERICHOST
            ) == 0 {
                return String(cString: hostname)
            }
        }

        return nil
    }
    deinit {
        monitor.cancel()
    }
}
