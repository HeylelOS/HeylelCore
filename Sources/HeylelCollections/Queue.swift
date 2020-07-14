
public protocol QueueProtocol: ContainerProtocol, Sequence {
	var first: Element? { get }
	var last: Element? { get }
}

public struct Queue<Element>: QueueProtocol {
	public typealias Element = Element

	public struct Iterator: IteratorProtocol {
		fileprivate weak var node: Node?

		public mutating func next() -> Element? {
			guard let node = node else {
				return nil
			}

			self.node = node.next
			return node.element
		}
	}

	fileprivate final class Node {
		fileprivate var element: Element
		fileprivate var next: Node?

		fileprivate init(_ element: Element, next: Node? = nil) {
			self.element = element
			self.next = next
		}
	}

	private var end: Node?
	private var begin: Node?

	public private(set) var count: Int

	public init() {
		self.end = nil
		self.begin = nil
		self.count = 0
	}

	public var isEmpty: Bool { self.count == 0 }

	public var first: Element? { self.begin?.element }

	public var last: Element? { self.end?.element }

	public mutating func push(_ element: Element) {
		let node = Node(element)

		if isKnownUniquelyReferenced(&self.begin) {
			/* Only self owns the list of nodes */
			self.end!.next = node
		} else if var copied = self.begin {
			/**
			 * Either self.begin === self.end (count == 1) or
			 * we must do a copy of the whole list for COW purposes.
			 * when count == 1, the overhead is negligible.
			 **/
			var current = Node(copied.element, next: node)

			self.begin = current

			while let next = copied.next {
				let copy = Node(next.element, next: node)

				current.next = copy

				current = copy
				copied = next
			}
		} else {
			/* count == 0, self.begin === self.end == nil */
			self.begin = node
		}

		self.end = node

		self.count += 1
	}

	public mutating func pop() -> Element? {
		if let begin = begin {
			self.begin = begin.next

			self.count -= 1

			if self.count == 0 {
				self.end = nil
			}

			return begin.element
		} else {
			return nil
		}
	}

	public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
		self.end = nil
		self.begin = nil
		self.count = 0
	}

	public func makeIterator() -> Iterator {
		Iterator(node: self.begin)
	}
}

