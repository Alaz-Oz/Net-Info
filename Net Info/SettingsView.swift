//
//  SettingsView.swift
//  Net Info
//
//  Created by Afroz Alam on 06/04/25.
//
import SwiftUI
import SystemConfiguration

struct SettingsView: View {
    @State private var selectedInterface: String = NetworkMonitor.shared
        .getCurrentInterface()

    private func getFriendlyName(_ bsdName: String) -> String? {
        if let interfaces = SCNetworkInterfaceCopyAll() as? [SCNetworkInterface]
        {
            for interface in interfaces {
                let currentBSDName =
                    SCNetworkInterfaceGetBSDName(interface) as String?
                if currentBSDName == bsdName {
                    return SCNetworkInterfaceGetLocalizedDisplayName(interface)
                        as String?
                }
            }
        }
        return nil
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Select Network Interface")
                .font(.headline)

            Picker("Interface", selection: $selectedInterface) {
                ForEach(NetworkMonitor.shared.availableInterfaces, id: \.self) {
                    iface in
                    Text(
                        getFriendlyName(iface) ?? "Unidentified"
                    ).tag(iface)
                }
            }
            .onChange(of: selectedInterface) { newValue in
                NetworkMonitor.shared.setCurrentInterface(newValue)
            }
            .frame(width: 200)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    SettingsView()
}
