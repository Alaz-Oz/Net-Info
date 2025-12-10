//
//  NetworkSpeedBuffer.swift
//  Net Info
//
//  Created by Afroz Alam on 29/10/24.
//
import Combine

class NetworkSpeedBuffer: Sequence, ObservableObject {

    private var buffer: [(UInt32, UInt32)]

    @Published private var currentIndex: Int = 0

    init(size: Int) {
        self.buffer = Array(repeating: (0, 0), count: size)  // Initialize with zeros
    }

    func reset() {
        buffer.withUnsafeMutableBufferPointer {
            $0.initialize(repeating: (0, 0))
        }
    }

    func push(_ upload: UInt32, _ download: UInt32) {
        currentIndex = (currentIndex + 1) % buffer.count
        buffer[currentIndex] = (upload, download)
    }

    // Conforming to Sequence protocol
    func makeIterator() -> BufferIterator {
        return BufferIterator(buffer: self)
    }

    // Nested iterator struct
    struct BufferIterator: IteratorProtocol {
        private let buffer: [(UInt32, UInt32)]
        private var index: Int
        private let count: Int
        private let termination: Int

        init(buffer: NetworkSpeedBuffer) {
            self.buffer = buffer.buffer
            self.index = buffer.currentIndex
            self.count = buffer.buffer.count  // The buffer should be > 1
            self.termination = self.index
        }

        mutating func next() -> (UInt32, UInt32)? {
            guard count > 0 else { return nil }

            let value = buffer[index]
            index = (index - 1 + count) % count

            if index == termination {
                return nil
            }
            return value
        }
    }
}
