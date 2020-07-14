
public protocol ContainerProtocol {
	associatedtype Element

	var count: Int { get }
	var isEmpty: Bool { get }

	mutating func push(_ element: Self.Element)
	mutating func push<S>(contentsOf newElements: S) where S : Sequence, S.Element == Self.Element
	mutating func pop() -> Self.Element?
	mutating func removeAll(keepingCapacity keepCapacity: Bool)
}

public extension ContainerProtocol {
	mutating func push<S>(contentsOf newElements: S) where S : Sequence, S.Element == Self.Element {
		for element in newElements {
			self.push(element)
		}
	}

	mutating func removeAll(keepingCapacity keepCapacity: Bool) {
		while let _ = self.pop() {
		}
	}
}

