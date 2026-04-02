//
//  SettingsView.swift
//  Net Info
//
//  Created by Afroz Alam on 06/04/25.
//
import SwiftUI
import SystemConfiguration

struct SettingsView: View {

    @ObservedObject var monitor = NetworkMonitor.shared
    @State private var selectedInterface: String = NetworkMonitor.shared
        .getCurrentInterface()
    @State var availableIfaces: [String]?
    @State var friendlyNames: [String: String]?

    var body: some View {
        VStack(alignment: .leading) {
            Text("Select Network Interface:")
                .font(.headline)
            
            if let interfaces = availableIfaces,
                let names = friendlyNames
            {
                Picker(
                    "Interfacer for IP address",
                    selection: $selectedInterface
                ) {
                    ForEach(
                        interfaces,
                        id: \.self
                    ) {
                        iface in

                        Text(names[iface] ?? "Unidentified").tag(iface)
                    }
                }.onChange(of: selectedInterface) { newValue in
                    monitor.setCurrentInterface(newValue)
                }
            }
            
            List {
                if let interfaces = availableIfaces,
                    let names = friendlyNames
                {

                    ForEach(
                        interfaces,
                        id: \.self
                    ) {
                        iface in

                        let isSelected = Binding<Bool>(
                            get: { monitor.selectedInterfaces.contains(iface) },
                            set: {
                                isSelected in
                                if isSelected {
                                    monitor.selectedInterfaces.insert(iface)
                                } else {
                                    monitor.selectedInterfaces.remove(iface)
                                }

                            }
                        )
                        Toggle(isOn: isSelected) {
                            Text(names[iface] ?? "Unidentified")
                        }

                    }
                } else {
                    Text("Loading interfaces...")
                        .padding(.horizontal)
                        .padding(.top)
                }

                

            }
            Spacer()
        }
        .padding()
        .onAppear {
            loadInterfacesWithFriendlyNames()
        }
    }
    func loadInterfacesWithFriendlyNames() {
        let availableInterfaces = monitor.getAvailableInterfaces()
        var names: [String: String] = [:]

        if let interfaces = SCNetworkInterfaceCopyAll() as? [SCNetworkInterface]
        {
            for interface in interfaces {
                if let interfaceName =
                    SCNetworkInterfaceGetBSDName(interface) as String?,
                    availableInterfaces.contains(interfaceName),
                    let friendlyName =
                        SCNetworkInterfaceGetLocalizedDisplayName(interface)
                        as String?
                {
                    names.updateValue(friendlyName, forKey: interfaceName)

                }
            }
        }
        availableIfaces = availableInterfaces
        friendlyNames = names
    }

}

#Preview {
    SettingsView()
}
