#if canImport(Glibc)
import Glibc
#endif

public typealias IOHandler = InputHandler & OutputHandler

public protocol InputHandler: AnyObject {
	func inputReady(for fileDescriptor: FileDescriptor, runLoop: RunLoop) -> Bool
}

public protocol OutputHandler: AnyObject {
	func outputReady(for fileDescriptor: FileDescriptor, runLoop: RunLoop) -> Bool
}

#if canImport(Foundation)
import Foundation // ContiguousBytes

public final class BufferOutputHandler<B> : OutputHandler where B : ContiguousBytes {
	private let bytes : B
	private var written = 0

	public init(bytes: B) {
		self.bytes = bytes
	}

	public func outputReady(for fileDescriptor: FileDescriptor, runLoop: RunLoop) -> Bool {
		return self.bytes.withUnsafeBytes { bytes in
			guard let address = bytes.baseAddress else {
				return false
			}

			let writeval = write(fileDescriptor, address + self.written, bytes.count - self.written)

			if writeval > 0 {
				self.written += writeval

				return self.written != bytes.count
			} else {
				return false
			}
		}
	}
}
#endif
