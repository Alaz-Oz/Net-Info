//
//  ContentView.swift
//  Net Info
//
//  Created by Afroz Alam on 24/10/24.
//

import SwiftUI

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
            // Refresh the LineChartView per second
            LineChartView(data: NetworkMonitor.shared.buffer)
                .frame(height: 200)
                .padding()
                .refreshable {

                }
            Spacer()
        }
        .padding()
    }
}

struct LineChartView: View {
    @ObservedObject var data: NetworkSpeedBuffer
    var body: some View {
        Canvas { context, size in
            
            var uploadPath = Path()
            var downloadPath = Path()

            let width: CGFloat = 600
            let count = 60 // no. of element in that
            let spacing: CGFloat = width / CGFloat(count - 1)
            let height: CGFloat = 200
            var maxDataValue: CGFloat = 7 * 1024  // initial assumption: 7KB
            for (_, (upload, download)) in data.enumerated() {
                let value = CGFloat(max(upload, download))
                if value > maxDataValue {
                    maxDataValue = value
                }
            }
            maxDataValue *= 1.2 // 20% increase
            
            for (index, (upload, download)) in data.enumerated() {
                
                // Download speed
                let xDownPos = width - CGFloat(index) * spacing
                let yDownPos =
                    height - (CGFloat(download) / maxDataValue) * height

                if index == 0 {
                    downloadPath.move(to: CGPoint(x: xDownPos, y: yDownPos))
                } else {
                    downloadPath.addLine(to: CGPoint(x: xDownPos, y: yDownPos))
                }
                
                // Upload speed
                let xUpPos = width - CGFloat(index) * spacing
                let yUpPos =
                    height - (CGFloat(upload) / maxDataValue) * height

                if index == 0 {
                    uploadPath.move(to: CGPoint(x: xUpPos, y: yUpPos))
                } else {
                    uploadPath.addLine(to: CGPoint(x: xUpPos, y: yUpPos))
                }
                
            }

            context.stroke(downloadPath, with: .color(.blue), lineWidth: 2)
            context.stroke(uploadPath, with: .color(.red), lineWidth: 2)
        }
        .frame(width: 600, height: 200)
        .background(Color.clear)
    }
}

#Preview {
    ContentView()
}
