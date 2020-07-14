#if canImport(Glibc)
import Glibc
#endif

public typealias FileDescriptor = Int32

public protocol FileProtocol: AnyObject {
	init(fileDescriptor: FileDescriptor)

	var fileDescriptor: FileDescriptor { get }
}

public enum FilePath {
	public static var currentWorkingDirectory: String {
		var cwdBuffer = UnsafeMutableBufferPointer<CChar>.allocate(capacity: 128)
		defer { cwdBuffer.deallocate() }

		while getcwd(cwdBuffer.baseAddress, cwdBuffer.count) == nil {
			let capacity = cwdBuffer.count * 2
			cwdBuffer.deallocate()
			cwdBuffer = UnsafeMutableBufferPointer<CChar>.allocate(capacity: capacity)
		}

		return String(cString: cwdBuffer.baseAddress!)
	}

	public static var homeDirectory: String {
		guard let home = getenv("HOME"), strlen(home) != 0 else {
			return "/"
		}

		return String(cString: home)
	}

	public static var userDataDirectory: String {
		guard let userData = getenv("XDG_DATA_HOME"), strlen(userData) != 0 else {
			guard let home = getenv("HOME"), strlen(home) != 0 else {
				return "/.local/share"
			}

			return "\(home)/.local/share"
		}

		return String(cString: userData)
	}

	public static var userConfigDirectory: String {
		guard let userConfig = getenv("XDG_CONFIG_HOME"), strlen(userConfig) != 0 else {
			guard let home = getenv("HOME"), strlen(home) != 0 else {
				return "/.config"
			}

			return "\(home)/.config"
		}

		return String(cString: userConfig)
	}

	public static var userCacheDirectory: String {
		guard let userCache = getenv("XDG_CACHE_HOME"), strlen(userCache) != 0 else {
			guard let home = getenv("HOME"), strlen(home) != 0 else {
				return "/.cache"
			}

			return "\(home)/.cache"
		}

		return String(cString: userCache)
	}

	public static var userRuntimeDirectory: String {
		guard let userRuntime = getenv("XDG_RUNTIME_DIR"), strlen(userRuntime) != 0 else {
			// Here, we drop compliance with the XDG Base Directory Specification
			return "/tmp"
		}

		return String(cString: userRuntime)
	}

	public static var dataDirectories: String {
		guard let data = getenv("XDG_DATA_DIRS"), strlen(data) != 0 else {
			return "/usr/local/share/:/usr/share/"
		}

		return String(cString: data)
	}

	public static var configDirectories: String {
		guard let data = getenv("XDG_CONFIG_DIRS"), strlen(data) != 0 else {
			return "/etc/xdg"
		}

		return String(cString: data)
	}

	public static func homeDirectory(forUser user: String) -> String? {
		defer { endpwent() }

		guard let passwd = getpwnam(user) else {
			return nil
		}

		return String(cString: passwd.pointee.pw_dir)
	}
}

public final class Directory: FileProtocol, Sequence, IteratorProtocol {
	private let dirp: OpaquePointer

	public required init(fileDescriptor: FileDescriptor) {
		guard let dirp = fdopendir(fileDescriptor) else {
			fatalError("fdopendir")
		}

		self.dirp = dirp
	}

	public convenience init(inDirectory fileDescriptor: FileDescriptor = AT_FDCWD, atPath path: String = ".") throws {
		let dirfd = openat(fileDescriptor, path, O_RDONLY, 0)

		guard dirfd >= 0 else {
			defer { close(dirfd) }
			throw SystemError()
		}

		self.init(fileDescriptor: dirfd)
	}

	deinit {
		closedir(self.dirp)
	}

	public var fileDescriptor: FileDescriptor {
		dirfd(self.dirp)
	}

	public func next() -> String? {
		guard let dirent = readdir(self.dirp) else {
			return nil
		}

		return withUnsafePointer(to: &dirent.pointee.d_name.0) { String(cString: UnsafePointer($0)) }
	}
}

infix operator +/: AdditionPrecedence
infix operator +/=: AssignmentPrecedence

public extension String {
	static func +/=(lhs: inout String, rhs: String) {
		if !lhs.isEmpty && lhs.last != "/" {
			lhs.append("/")
		}

		lhs.append(contentsOf: rhs.drop(while: { $0 == "/" }))
	}

	static func +/(lhs: String, rhs: String) -> String {
		var path = lhs

		path +/= rhs

		return path
	}
}

