import XCTest
@testable import HeylelCore
@testable import HeylelCollections

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

final class HeylelCoreTests: XCTestCase {

	func testHelloWorld1() {
		let runLoop = RunLoop()

		runLoop.monitorOutput(for: 1,
			with: BufferOutputHandler(bytes: "Hello, World!\n".data(using: .utf8)!))

		runLoop.run()
	}

	func testHelloWorld2() {
		let runLoop = RunLoop()

		runLoop.schedule(HelloWorld2(seconds: 1))

		runLoop.run()
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

		("testDirectory", testDirectory),
		("testFilePath", testFilePath),

		("testPropertyWrappers", testPropertyWrappers),
		("testQueue", testQueue),
	]
}
