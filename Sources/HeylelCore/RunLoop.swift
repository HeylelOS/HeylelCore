import HeylelCollections

#if canImport(Glibc)
import Glibc

fileprivate extension fd_set {
	private static let masks = MemoryLayout<Self>.stride / MemoryLayout<__fd_mask>.stride
	private static let nfdBits = 8 * Int32(MemoryLayout<__fd_mask>.stride)

	mutating func contains(_ fileDescriptor: FileDescriptor) -> Bool {
		withUnsafePointer(to: &self.__fds_bits) { fdsBitsPointer in
			fdsBitsPointer.withMemoryRebound(to: __fd_mask.self, capacity: Self.masks) {
				($0[Int(fileDescriptor / Self.nfdBits)] & (1 << __fd_mask(fileDescriptor % Self.nfdBits))) != 0
			}
		}
	}

	mutating func insert(_ fileDescriptor: FileDescriptor) {
		withUnsafeMutablePointer(to: &self.__fds_bits) { fdsBitsPointer in
			fdsBitsPointer.withMemoryRebound(to: __fd_mask.self, capacity: Self.masks) {
				$0[Int(fileDescriptor / Self.nfdBits)] |= 1 << __fd_mask(fileDescriptor % Self.nfdBits)
			}
		}
	}

	mutating func remove(_ fileDescriptor: FileDescriptor) {
		withUnsafeMutablePointer(to: &self.__fds_bits) { fdsBitsPointer in
			fdsBitsPointer.withMemoryRebound(to: __fd_mask.self, capacity: Self.masks) {
				$0[Int(fileDescriptor / Self.nfdBits)] &= ~__fd_mask(fileDescriptor % Self.nfdBits)
			}
		}
	}

	mutating func withSelectPointer<T>(isEmpty: Bool, _ body: @escaping (UnsafeMutablePointer<Self>?) -> T) -> T {
		isEmpty ? body(nil) : body(&self)
	}
}
#endif

public typealias RunLoopPlugIn = FileProtocol & InputHandler

public class RunLoop {
	private struct HandlerSet<Handler> {
		private var handlers = [FileDescriptor : Handler]()
		private(set) var highest: Int32 = 0
		private(set) var fdSet = fd_set()

		var isEmpty: Bool {
			self.handlers.isEmpty
		}

		mutating func updateValue(_ handler: Handler, fileDescriptor: FileDescriptor) -> Handler? {
			self.fdSet.insert(fileDescriptor)

			if fileDescriptor >= self.highest {
				self.highest = fileDescriptor + 1
			}

			return self.handlers.updateValue(handler, forKey: fileDescriptor)
		}

		@discardableResult
		mutating func ready(atMost: Int, readySet: inout fd_set, _ keep: @escaping (Handler, FileDescriptor) -> Bool) -> Int {
			var fileDescriptor: FileDescriptor = 0
			var handled = 0

			while fileDescriptor < self.highest, handled < atMost {
				if readySet.contains(fileDescriptor) {
					if let handler = self.handlers[fileDescriptor], !keep(handler, fileDescriptor) {
						self.fdSet.remove(fileDescriptor)
						self.handlers.removeValue(forKey: fileDescriptor)
					}

					handled += 1
				}
				fileDescriptor += 1
			}

			return handled
		}
	}

	private var inputHandlers = HandlerSet<InputHandler>()
	private var outputHandlers = HandlerSet<OutputHandler>()
	private var timers = PriorityQueue<Timer>({ $0.maturity < $1.maturity })

	public var isEmpty: Bool {
		self.inputHandlers.isEmpty && self.outputHandlers.isEmpty && self.timers.isEmpty
	}

	@discardableResult
	public func monitorInput(for fileDescriptor: FileDescriptor, with handler: InputHandler) -> InputHandler? {
		self.inputHandlers.updateValue(handler, fileDescriptor: fileDescriptor)
	}

	@discardableResult
	public func monitorOutput(for fileDescriptor: FileDescriptor, with handler: OutputHandler) -> OutputHandler? {
		self.outputHandlers.updateValue(handler, fileDescriptor: fileDescriptor)
	}

	public func schedule(_ timer: Timer) {
		self.timers.push(timer)
	}

	public func loop() {
		var readFdSet = self.inputHandlers.fdSet
		var writeFdSet = self.outputHandlers.fdSet
		var timeout = timespec()

		let ready = timeout.withSelectPointer(nextMaturity: self.timers.next?.maturity) { timeoutPointer in
			readFdSet.withSelectPointer(isEmpty: self.inputHandlers.isEmpty) { readFdSetPointer in
				writeFdSet.withSelectPointer(isEmpty: self.outputHandlers.isEmpty) { writeFdSetPointer in
					Int(pselect(max(self.inputHandlers.highest, self.outputHandlers.highest),
						readFdSetPointer, writeFdSetPointer, nil,
						timeoutPointer, nil))
				}
			}
		}

		if ready != -1 {
			let inputs = self.inputHandlers.ready(atMost: ready, readySet: &readFdSet) { $0.inputReady(for: $1, runLoop: self) }
			self.outputHandlers.ready(atMost: ready - inputs, readySet: &writeFdSet) { $0.outputReady(for: $1, runLoop: self) }

			while let nextMaturity = self.timers.next?.maturity, nextMaturity <= TimeSlice.now(),
				let popped = self.timers.pop() {
				if popped.trigger(runLoop: self) {
					self.timers.push(popped)
				}
			}
		}
	}

	public func run() {
		while !self.isEmpty {
			self.loop()
		}
	}
}

fileprivate extension timespec {
	mutating func withSelectPointer<T>(nextMaturity: Double?, _ body: @escaping (UnsafeMutablePointer<Self>?) -> T) -> T {
		if let maturity = nextMaturity {
			let timeout = max(maturity - TimeSlice.now(), 0)

			self.tv_sec = Int(timeout)
			self.tv_nsec = Int(timeout.truncatingRemainder(dividingBy: 1) * 1000000000)

			return body(&self)
		}

		return body(nil)
	}
}

public extension RunLoop {
	@discardableResult
	func monitorIO(for fileDescriptor: FileDescriptor, with handler: IOHandler) -> (InputHandler?, OutputHandler?) {
		(self.monitorInput(for: fileDescriptor, with: handler), self.monitorOutput(for: fileDescriptor, with: handler))
	}

	func plugIn(_ plugIn: RunLoopPlugIn) {
		self.monitorInput(for: plugIn.fileDescriptor, with: plugIn)
	}
}

