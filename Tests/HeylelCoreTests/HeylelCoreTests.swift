import XCTest
@testable import HeylelCore
@testable import HeylelCollections

#if canImport(Glibc)
import Glibc
#endif

#if canImport(Darwin)
import Darwin.libc
#endif

final class HelloWorld2: HeylelCore.Timer {
	let maturity: TimeSlice

	init(seconds: Double) {
		self.maturity = TimeSlice.now() + seconds
	}

	func trigger(runLoop: HeylelCore.RunLoop) -> Bool {

		runLoop.monitorOutput(for: 1,
			with: BufferOutputHandler(bytes: "Hello, World!\n".data(using: .utf8)!))

		return false
	}
}

final class TestInputOutputInputHandler: InputHandler {
	private var buffer: UnsafeMutableBufferPointer<UInt8>
	private(set) var data = Data()

	init(capacity: Int) {
		self.buffer = UnsafeMutableBufferPointer.allocate(capacity: capacity)
	}

	deinit {
		self.buffer.deallocate()
	}

	func inputReady(for fileDescriptor: FileDescriptor, runLoop: HeylelCore.RunLoop) -> Bool {
		guard let address = self.buffer.baseAddress else {
			return false
		}

		let readval = read(fileDescriptor, address, self.buffer.count)

		if readval > 0 {
			self.data.append(address, count: readval)
			return true
		} else {
			close(fileDescriptor)
			return false
		}
	}
}

final class TestInputOutputOutputHandler: OutputHandler {
	private let handler: BufferOutputHandler<Data>

	init(data: Data) {
		self.handler = BufferOutputHandler(bytes: data)
	}

	public func outputReady(for fileDescriptor: FileDescriptor, runLoop: HeylelCore.RunLoop) -> Bool {
		let stay = handler.outputReady(for: fileDescriptor, runLoop: runLoop)

		if !stay {
			close(fileDescriptor)
		}

		return stay
	}
}

final class HeylelCoreTests: XCTestCase {

	func testHelloWorld1() {
		let runLoop = HeylelCore.RunLoop()

		runLoop.monitorOutput(for: 1,
			with: BufferOutputHandler(bytes: "Hello, World!\n".data(using: .utf8)!))

		runLoop.run()
	}

	func testHelloWorld2() {
		let runLoop = HeylelCore.RunLoop()

		runLoop.schedule(HelloWorld2(seconds: 1))

		runLoop.run()
	}

	func testInputOutput() {
		let text = "Hello, World!"
		let inputHandler = TestInputOutputInputHandler(capacity: 64)
		let outputHandler = TestInputOutputOutputHandler(data: text.data(using: .utf8)!)
		let runLoop = HeylelCore.RunLoop()
		let filedes = UnsafeMutableBufferPointer<Int32>.allocate(capacity: 2)

		XCTAssertTrue(pipe(filedes.baseAddress) == 0)

		runLoop.monitorOutput(for: filedes[1], with: outputHandler)
		runLoop.monitorInput(for: filedes[0], with: inputHandler)

		runLoop.run()

		guard let generated = String(data: inputHandler.data, encoding: .utf8) else {
			XCTFail("Invalid coding for text")
			return
		}

		XCTAssertTrue(text == generated)

		filedes.deallocate()
	}

	func testDirectory() {
		guard let directory = try? Directory() else {
			XCTFail("Unable to open directory")
			return
		}

		for entry in directory where entry.first != "." {
			XCTAssertTrue(entry.firstIndex(of: "/") == nil)
		}
	}

	func testFilePath() {
		let cwd = FilePath.currentWorkingDirectory
		XCTAssertFalse(cwd.isEmpty)
		XCTAssertTrue(cwd.first == "/")

		let home = FilePath.homeDirectory
		XCTAssertFalse(home.isEmpty)
		XCTAssertTrue(home.first == "/")

		XCTAssertEqual("/" +/ "bin", "/bin")
		XCTAssertEqual("" +/ "/bin", "bin")
		XCTAssertEqual("/bin" +/ "ls", "/bin/ls")
		XCTAssertEqual("/bin" +/ "/ls", "/bin/ls")
	}

	func testPropertyWrappers() {
		let one = CopyOnWrite<Int>(wrappedValue: 1)
		var two = one
		two.wrappedValue = 2

		XCTAssertEqual(1, one.wrappedValue)
		XCTAssertEqual(2, two.wrappedValue)
	}

	func testQueue() {
		var fifo = Queue<String>()
		let abcd = ["a", "b", "c", "d"]

		fifo.push(contentsOf: abcd)

		var fifo2 = fifo
		fifo2.push("e")

		XCTAssertEqual(Array(fifo), abcd)
		XCTAssertEqual(Array(fifo2), ["a", "b", "c", "d", "e"])
	}

	static var allTests = [
		("testHelloWorld1", testHelloWorld1),
		("testHelloWorld2", testHelloWorld2),
		("testInputOutput", testInputOutput),

		("testDirectory", testDirectory),
		("testFilePath", testFilePath),

		("testPropertyWrappers", testPropertyWrappers),
		("testQueue", testQueue),
	]
}
