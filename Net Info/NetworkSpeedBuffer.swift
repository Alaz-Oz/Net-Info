//
//  NetworkSpeedBuffer.swift
//  Net Info
//
//  Created by Afroz Alam on 29/10/24.
//
import Combine

class NetworkSpeedBuffer: Sequence, ObservableObject {

    let maxSize: Int
    private var buffer: [(UInt32, UInt32)]

    @Published private var currentIndex: Int = -1  // points to freshly inserted value
    private var pastIndex: Int = 0

    init(size: Int) {
        self.maxSize = size
        self.buffer = Array(repeating: (0, 0), count: size)  // Initialize with zeros

    }

    func toArray() -> [(UInt32, UInt32)] {
        return Array(
            buffer[currentIndex + 1..<maxSize] + buffer[0..<currentIndex + 1]
        ).reversed()
    }

    func enumerated() -> [(Int, (UInt32, UInt32))] {
        return Array(toArray().enumerated())
    }

    func push(_ upload: UInt32, _ download: UInt32) {
        pastIndex = currentIndex
        currentIndex = (currentIndex + 1) % maxSize
        buffer[currentIndex] = (upload, download)
    }

    // Conforming to Sequence protocol
    func makeIterator() -> BufferIterator {
        return BufferIterator(buffer: self)
    }

    // Nested iterator struct
    struct BufferIterator: IteratorProtocol {
        private let buffer: NetworkSpeedBuffer
        private var index: Int
        private let count: Int
        private let termination: Int

        init(buffer: NetworkSpeedBuffer) {
            self.buffer = buffer
            self.index = buffer.currentIndex
            self.count = buffer.maxSize
            self.termination = self.index
        }

        mutating func next() -> (UInt32, UInt32)? {
            guard count > 0 else { return nil }
            let value = buffer.buffer[index]
            index = (index - 1 + count) % count

            if index == termination {
                return nil
            }
            return value
        }
    }
}
