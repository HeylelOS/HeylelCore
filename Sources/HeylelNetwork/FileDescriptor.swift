import HeylelCore

#if canImport(Glibc)
import Glibc
#endif

public extension FileDescriptor {
	static func makeSocket(in netDomain: NetDomain,
		as netType: NetType, following netProtocol: NetProtocol) throws -> FileDescriptor {
		let fileDescriptor = socket(netDomain.rawValue, netType.rawValue, netProtocol)
	
		if fileDescriptor < 0 {
			throw SystemError()
		}
	
		return fileDescriptor
	}

	func acceptSocket(fromINet address: inout NetAddress) throws -> FileDescriptor {
		var addr_in = sockaddr_in()
		var addr_in_len = socklen_t(MemoryLayout<sockaddr_in>.stride)
		let fileDescriptor = withUnsafeMutablePointer(to: &addr_in) {
			accept(self,
				UnsafeMutableRawPointer($0).bindMemory(to: sockaddr.self, capacity: 1),
				&addr_in_len)
		}
	
		if fileDescriptor < 0 {
			throw SystemError()
		}
	
		address = .inet(addr_in)
	
		return fileDescriptor
	}

	func acceptSocket(fromINet6 address: inout NetAddress) throws -> FileDescriptor {
		var addr_in6 = sockaddr_in6()
		var addr_in6_len = socklen_t(MemoryLayout<sockaddr_in6>.stride)
		let fileDescriptor = withUnsafeMutablePointer(to: &addr_in6) {
			accept(self,
				UnsafeMutableRawPointer($0).bindMemory(to: sockaddr.self, capacity: 1),
				&addr_in6_len)
		}
	
		if fileDescriptor < 0 {
			throw SystemError()
		}
	
		address = .inet6(addr_in6)
	
		return fileDescriptor
	}

	func acceptSocket(fromUNIX address: inout NetAddress) throws -> FileDescriptor {
		var addr_un = sockaddr_un()
		var addr_un_len = socklen_t(MemoryLayout<sockaddr_un>.stride)
		let fileDescriptor = withUnsafeMutablePointer(to: &addr_un) {
			accept(self,
				UnsafeMutableRawPointer($0).bindMemory(to: sockaddr.self, capacity: 1),
				&addr_un_len)
		}
	
		if fileDescriptor < 0 {
			throw SystemError()
		}
	
		address = .unix(addr_un)
	
		return fileDescriptor
	}

	func bindSocket(at address: NetAddress) throws {
		let retval: Int32

		switch address {
		case .inet(var addr):
			retval = withUnsafePointer(to: &addr) {
				bind(self,
					UnsafeRawPointer($0).bindMemory(to: sockaddr.self, capacity: 1),
					socklen_t(MemoryLayout<sockaddr_in>.stride))
			}
		case .inet6(var addr):
			retval = withUnsafePointer(to: &addr) {
				bind(self,
					UnsafeRawPointer($0).bindMemory(to: sockaddr.self, capacity: 1),
					socklen_t(MemoryLayout<sockaddr_in6>.stride))
			}
		case .unix(var addr):
			retval = withUnsafePointer(to: &addr) {
				bind(self,
					UnsafeRawPointer($0).bindMemory(to: sockaddr.self, capacity: 1),
					socklen_t(MemoryLayout<sockaddr_un>.stride))
			}
		case .unknown:
			throw SystemError.addressFamilyNotSupported
		}

		if retval != 0 {
			throw SystemError()
		}
	}

	func connectSocket(to address: NetAddress) throws {
		let retval: Int32

		switch address {
		case .inet(var addr):
			retval = withUnsafePointer(to: &addr) {
				connect(self,
					UnsafeRawPointer($0).bindMemory(to: sockaddr.self, capacity: 1),
					socklen_t(MemoryLayout<sockaddr_in>.stride))
			}
		case .inet6(var addr):
			retval = withUnsafePointer(to: &addr) {
				connect(self,
					UnsafeRawPointer($0).bindMemory(to: sockaddr.self, capacity: 1),
					socklen_t(MemoryLayout<sockaddr_in6>.stride))
			}
		case .unix(var addr):
			retval = withUnsafePointer(to: &addr) {
				connect(self,
					UnsafeRawPointer($0).bindMemory(to: sockaddr.self, capacity: 1),
					socklen_t(MemoryLayout<sockaddr_un>.stride))
			}
		case .unknown:
			throw SystemError.addressFamilyNotSupported
		}

		if retval != 0 {
			throw SystemError()
		}
	}

	func listenSocket(backlog: Int = Int(SOMAXCONN)) throws {
		if listen(self, Int32(backlog)) != 0 {
			throw SystemError()
		}
	}

	func shutdownSocketForReading() throws {
		if shutdown(self, Int32(SHUT_RD)) != 0 {
			throw SystemError()
		}
	}

	func shutdownSocketForWriting() throws {
		if shutdown(self, Int32(SHUT_WR)) != 0 {
			throw SystemError()
		}
	}

	func shutdownSocket() throws {
		if shutdown(self, Int32(SHUT_RDWR)) != 0 {
			throw SystemError()
		}
	}
}

