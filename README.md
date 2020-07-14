# HeylelCore

Heylel Core library. Contains structures and classes to create simple **RunLoop**s and manage a file descriptor-based program lifetime.

## HeylelCollections

First Module, contains a few Collections with copy on write semantics, not in the Swift Standard Library:
- PriorityQueue
- Queue (FIFO)
- Stack (Wrapper around a ContiguousArray)

And some useful property wrappers:
- Box (Reference to a struct or another type)
- CopyOnWrite (Reference only updated after first mutation)

## HeylelCore

Contains a RunLoop, and protocols for classes interacting with it.
- RunLoop: Class representing a program runloop, it interacts with **Timer**s, **InputHandler**s and **OutputHandler**s
- InputHandler/OutputHandler: Object protocols to define interation for a file descriptor inside a **RunLoop**
- Timer: Object protocol to define a time-based interaction with a **RunLoop**.
- FileProtocol: Object Protocol representing a file, could be used in addition to an **InputHandler** to create a **RunLoopPlugIn**.
- SystemError: Equatable Error structure used to represent system errors.
- FilePath: Enumration used as a namespace to access usual system paths such as tu user home directory.

## HeylelNetwork

Facilities to create sockets through **FileDescriptor**s.

