#if canImport(Glibc)
import Glibc
#endif

#if canImport(Darwin)
import Darwin.libc
#endif

public struct SystemError: Error, Equatable {
	public static let argumentListTooLong                          = SystemError(errorCode: E2BIG)
	public static let permissionDenied                             = SystemError(errorCode: EACCES)
	public static let addressInUse                                 = SystemError(errorCode: EADDRINUSE)
	public static let addressNotAvailable                          = SystemError(errorCode: EADDRNOTAVAIL)
	public static let addressFamilyNotSupported                    = SystemError(errorCode: EAFNOSUPPORT)
	public static let resourceUnavailable                          = SystemError(errorCode: EAGAIN)
	public static let connectionAlreadyInProgress                  = SystemError(errorCode: EALREADY)
	public static let badFileDescriptor                            = SystemError(errorCode: EBADF)
	public static let badMessage                                   = SystemError(errorCode: EBADMSG)
	public static let deviceOrResourceBusy                         = SystemError(errorCode: EBUSY)
	public static let operationCanceled                            = SystemError(errorCode: ECANCELED)
	public static let noChildProcesses                             = SystemError(errorCode: ECHILD)
	public static let connectionAborted                            = SystemError(errorCode: ECONNABORTED)
	public static let connectionRefused                            = SystemError(errorCode: ECONNREFUSED)
	public static let connectionReset                              = SystemError(errorCode: ECONNRESET)
	public static let resourceDeadlockWouldOccur                   = SystemError(errorCode: EDEADLK)
	public static let destinationAddressRequired                   = SystemError(errorCode: EDESTADDRREQ)
	public static let mathematicsArgumentOutOfDomainOfFunction     = SystemError(errorCode: EDOM)
	//public static let reserved                                     = SystemError(errorCode: EDQUOT)
	public static let fileExists                                   = SystemError(errorCode: EEXIST)
	public static let badAddress                                   = SystemError(errorCode: EFAULT)
	public static let fileTooLarge                                 = SystemError(errorCode: EFBIG)
	public static let hostIsUnreachable                            = SystemError(errorCode: EHOSTUNREACH)
	public static let identifierRemoved                            = SystemError(errorCode: EIDRM)
	public static let illegalByteSequence                          = SystemError(errorCode: EILSEQ)
	public static let operationInProgress                          = SystemError(errorCode: EINPROGRESS)
	public static let interruptedFunction                          = SystemError(errorCode: EINTR)
	public static let invalidArgument                              = SystemError(errorCode: EINVAL)
	public static let IOError                                      = SystemError(errorCode: EIO)
	public static let socketIsConnected                            = SystemError(errorCode: EISCONN)
	public static let isADirectory                                 = SystemError(errorCode: EISDIR)
	public static let tooManyLevelsOfSymbolicLinks                 = SystemError(errorCode: ELOOP)
	public static let tooManyOpenFiles                             = SystemError(errorCode: EMFILE)
	public static let tooManyLinks                                 = SystemError(errorCode: EMLINK)
	public static let messageTooLarge                              = SystemError(errorCode: EMSGSIZE)
	//public static let reserved                                     = SystemError(errorCode: EMULTIHOP)
	public static let filenameTooLong                              = SystemError(errorCode: ENAMETOOLONG)
	public static let networkIsDown                                = SystemError(errorCode: ENETDOWN)
	public static let networkIsReset                               = SystemError(errorCode: ENETRESET)
	public static let connectionAbortedByNetwork                   = SystemError(errorCode: ENETUNREACH)
	public static let tooManyFilesOpenInSystem                     = SystemError(errorCode: ENFILE)
	public static let noBufferSpaceAvailable                       = SystemError(errorCode: ENOBUFS)
	public static let noMessageIsAvailableOnTheStreamHeadReadQueue = SystemError(errorCode: ENODATA)
	public static let noSuchDevice                                 = SystemError(errorCode: ENODEV)
	public static let noSuchFileOrDirectory                        = SystemError(errorCode: ENOENT)
	public static let executableFileFormatError                    = SystemError(errorCode: ENOEXEC)
	public static let noLocksAvailable                             = SystemError(errorCode: ENOLCK)
	//public static let reserved                                     = SystemError(errorCode: ENOLINK)
	public static let notEnoughSpace                               = SystemError(errorCode: ENOMEM)
	public static let noMessageOfTheDesiredType                    = SystemError(errorCode: ENOMSG)
	public static let protocolNotAvailable                         = SystemError(errorCode: ENOPROTOOPT)
	public static let noSpaceLeftOnDevice                          = SystemError(errorCode: ENOSPC)
	public static let noStreamResources                            = SystemError(errorCode: ENOSR)
	public static let notAStream                                   = SystemError(errorCode: ENOSTR)
	public static let functionNotSupported                         = SystemError(errorCode: ENOSYS)
	public static let theSocketIsNotConnected                      = SystemError(errorCode: ENOTCONN)
	public static let notADirectory                                = SystemError(errorCode: ENOTDIR)
	public static let directoryNotEmpty                            = SystemError(errorCode: ENOTEMPTY)
	public static let notASocket                                   = SystemError(errorCode: ENOTSOCK)
	public static let notSupported                                 = SystemError(errorCode: ENOTSUP)
	public static let inappropriateIOControlOperation              = SystemError(errorCode: ENOTTY)
	public static let noSuchDeviceOrAddress                        = SystemError(errorCode: ENXIO)
	public static let operationNotSupportedOnSocket                = SystemError(errorCode: EOPNOTSUPP)
	public static let valueTooLargeToBeStoredInDataType            = SystemError(errorCode: EOVERFLOW)
	public static let operationNotPermitted                        = SystemError(errorCode: EPERM)
	public static let brokenPipe                                   = SystemError(errorCode: EPIPE)
	public static let protocolError                                = SystemError(errorCode: EPROTO)
	public static let protocolNotSupported                         = SystemError(errorCode: EPROTONOSUPPORT)
	public static let protocolWrongTypeForSocket                   = SystemError(errorCode: EPROTOTYPE)
	public static let resultTooLarge                               = SystemError(errorCode: ERANGE)
	public static let readOnlyFileSystem                           = SystemError(errorCode: EROFS)
	public static let invalidSeek                                  = SystemError(errorCode: ESPIPE)
	public static let noSuchProcess                                = SystemError(errorCode: ESRCH)
	//public static let reserved                                     = SystemError(errorCode: ESTALE)
	public static let streamIoctlTimeout                           = SystemError(errorCode: ETIME)
	public static let connectionTimedOut                           = SystemError(errorCode: ETIMEDOUT)
	public static let textFileBusy                                 = SystemError(errorCode: ETXTBSY)
	public static let operationWouldBlock                          = SystemError(errorCode: EWOULDBLOCK)
	public static let crossDeviceLink                              = SystemError(errorCode: EXDEV)

	public let errorCode: Int32

	public init(errorCode: Int32 = errno) {
		self.errorCode = errorCode
	}

	public var localizedDescription: String {
		String(cString: strerror(self.errorCode))
	}

	public static func ==(lhs: SystemError, rhs: SystemError) -> Bool {
		lhs.errorCode == rhs.errorCode
	}
}

