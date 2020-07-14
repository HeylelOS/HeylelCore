#if canImport(Glibc)
import Glibc
#endif

public typealias TimeSlice = Double

public protocol Timer: AnyObject {
	var maturity: TimeSlice { get }
	func trigger(runLoop: RunLoop) -> Bool
}

public extension TimeSlice {
	static func now() -> Self {
		var now = timespec()
		clock_gettime(CLOCK_REALTIME, &now)
		return TimeSlice(now.tv_sec) + TimeSlice(now.tv_nsec) / 1000000000
	}
}

