
public protocol StackProtocol: ContainerProtocol {
	var peak: Element? { get }
}

public struct Stack<Element>: StackProtocol {
	public typealias Element = Element

	private var stack: ContiguousArray<Element>

	public init() {
		self.stack = ContiguousArray<Element>()
	}

	public var count: Int { self.stack.count }

	public var isEmpty: Bool { self.stack.isEmpty }

	public var peak: Element? { self.stack.last }

	public mutating func push(_ element: Element) {
		self.stack.append(element)
	}

	public mutating func push<S>(contentsOf newElements: S) where S : Sequence, S.Element == Element {
		self.stack.append(contentsOf: newElements)
	}

	public mutating func pop() -> Element? {
		self.stack.popLast()
	}

	public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
		self.stack.removeAll(keepingCapacity: keepCapacity)
	}
}

