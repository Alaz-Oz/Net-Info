//
//  ContentView.swift
//  Net Info
//
//  Created by Afroz Alam on 24/10/24.
//

import SwiftUI
import Charts

struct ContentView: View {
    let buffer = NetworkMonitor.shared.buffer
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Network Speed")
                    .font(.headline)
                    .padding()
            }

            ChartView(data: NetworkMonitor.shared.buffer)
            Spacer()
        }
        .padding()
    }
}

struct ChartView: View {
    @ObservedObject var data: NetworkSpeedBuffer

    var body: some View {
        Chart {
            ForEach(Array(data.enumerated()), id: \.offset) { index, speed in
                LineMark(
                    x: .value("Second", index),
                    y: .value("Speed", speed.0)
                )
                .foregroundStyle(.red)
                .symbol(by: .value("Type", "Upload"))
                .symbolSize(0)

                LineMark(
                    x: .value("Second", index),
                    y: .value("Speed", speed.1)
                )
                .foregroundStyle(.blue)
                .symbol(by: .value("Type", "Download"))
                .symbolSize(0)
            }
        }
        .chartXScale(domain: [59, 0])
        .chartForegroundStyleScale([
            "Upload": .red,
            "Download": .blue
        ])
        .frame(width: 600, height: 200)
    }
}

#Preview {
    ContentView()
}
