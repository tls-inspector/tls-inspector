import Foundation

/// An atomic integer is an integer object that can be mutated across multiple threads
class AtomicInt {
    private let queue: DispatchQueue!
    private var value: Int!

    /// Initalize a new atomic integer with the given default value
    /// - Parameter defaultValue: The default value for the integer
    init(defaultValue: Int) {
        self.queue = DispatchQueue(label: "io.ecn.tlsinspector.atomicint" + UUID().uuidString)
        self.value = defaultValue
    }

    /// Increment the value by one
    public func increment() {
        self.queue.sync {
            self.value += 1
        }
    }

    /// Increment the value by one and return the new value
    public func incrementAndGet() -> Int {
        self.queue.sync {
            self.value += 1
            return self.value
        }
    }

    /// Decrement the value by one
    public func decrement() {
        self.queue.sync {
            self.value -= 1
        }
    }

    /// Decrement the value by one and return the new value
    public func decrementAndGet() -> Int {
        self.queue.sync {
            self.value -= 1
            return self.value
        }
    }

    /// Update the value of the integer
    /// - Parameter value: The new value
    public func set(_ value: Int) {
        self.queue.sync {
            self.value = value
        }
    }

    /// Returns the current value
    public func get() -> Int {
        self.queue.sync {
            return self.value
        }
    }
}
