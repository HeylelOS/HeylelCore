#if canImport(Glibc)
import Glibc
#endif

public typealias NetProtocol = Int32

public typealias NetPort = UInt16

public enum NetDomain {
	case local
	case unix
	case inet
	case route
	case key
	case inet6
#if !os(Linux)
	case system
	case ndrv
#endif

	var rawValue: Int32 {
		switch(self) {
		case .local:  return PF_LOCAL
		case .unix:   return PF_UNIX
		case .inet:   return PF_INET
		case .route:  return PF_ROUTE
		case .key:    return PF_KEY
		case .inet6:  return PF_INET6
#if !os(Linux)
		case .system: return PF_SYSTEM
		case .ndrv:   return PF_NDRV
#endif
		}
	}
}

public enum NetType {
	case stream
	case datagram
	case raw

	var rawValue: Int32 {
		switch(self) {
#if os(Linux)
		case .stream:   return Int32(SOCK_STREAM.rawValue)
		case .datagram: return Int32(SOCK_DGRAM.rawValue)
		case .raw:      return Int32(SOCK_RAW.rawValue)
#else
		case .stream:   return SOCK_STREAM
		case .datagram: return SOCK_DGRAM
		case .raw:      return SOCK_RAW
#endif
		}
	}
}

public enum NetAddress {
	case inet(sockaddr_in)
	case inet6(sockaddr_in6)
	case unix(sockaddr_un)
	case unknown

	public init?(ipv4: String, port: NetPort) {
		var addr = sockaddr_in()
		addr.sin_family = sa_family_t(AF_INET)
		addr.sin_port = port.bigEndian
		guard inet_pton(AF_INET, ipv4, &addr.sin_addr) == 1 else {
			return nil
		}

		self = .inet(addr)
	}

	public init?(ipv6: String, port: NetPort) {
		var addr = sockaddr_in6()
		addr.sin6_family = sa_family_t(AF_INET6)
		addr.sin6_port = port.bigEndian
		guard inet_pton(AF_INET6, ipv6, &addr.sin6_addr) == 1 else {
			return nil
		}

		self = .inet6(addr)
	}

	public init?(path: String) {
		var addr = sockaddr_un()
		let capacity = MemoryLayout.stride(ofValue: addr.sun_path)

		guard path.utf8.count <= capacity else {
			return nil
		}

		withUnsafeMutablePointer(to: &addr.sun_path) {
			$0.withMemoryRebound(to: Int8.self, capacity: capacity) {
				bcopy(path, $0, path.utf8.count)
			}
		}

		addr.sun_family = sa_family_t(AF_UNIX)
#if canImport(Darwin)
		addr.sun_len = path.utf8.count
#endif

		self = .unix(addr)
	}

	public init() {
		self = .unknown
	}

	init(addr: sockaddr, length: socklen_t) {
		var copy = addr
		switch addr.sa_family {
		case sa_family_t(AF_INET):
			self = withUnsafePointer(to: &copy) {
				$0.withMemoryRebound(to: sockaddr_in.self, capacity: 1) {
					.inet($0.pointee)
				}
			}
		case sa_family_t(AF_INET6):
			self = withUnsafePointer(to: &copy) {
				$0.withMemoryRebound(to: sockaddr_in6.self, capacity: 1) {
					.inet6($0.pointee)
				}
			}
		case sa_family_t(AF_UNIX):
			self = withUnsafePointer(to: &copy) {
				$0.withMemoryRebound(to: sockaddr_un.self, capacity: 1) {
					.unix($0.pointee)
				}
			}
		default:
			self = .unknown
		}
	}
}

public extension NetProtocol {
	static func named(_ name: String) -> NetProtocol? {
		defer { endprotoent() }
		return getprotobyname(name)?.pointee.p_proto
	}
}

