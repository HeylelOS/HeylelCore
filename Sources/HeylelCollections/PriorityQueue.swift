
public protocol PriorityQueueProtocol: ContainerProtocol {
	var next: Element? { get }
}

public struct PriorityQueue<Element>: PriorityQueueProtocol {
	public typealias Element = Element

	private let comparator: (Element, Element) -> Bool
	private var heap = ContiguousArray<Element>()

	public init(_ comparator: @escaping (Element, Element) -> Bool) {
		self.comparator = comparator
	}

	public var count: Int { self.heap.count }

	public var isEmpty: Bool { self.heap.isEmpty }

	public var next: Element? { self.heap.first }

	public mutating func push(_ element: Element) {
		self.heap.append(element)
		self.siftUp(self.count - 1)
	}

	public mutating func pop() -> Element? {
		guard self.count > 0 else {
			return nil
		}
		self.heap.swapAt(0, self.count - 1)
		defer { self.siftDown(0) }
		return self.heap.popLast()
	}

	public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
		self.heap.removeAll(keepingCapacity: keepCapacity)
	}

	private mutating func siftUp(_ index: Int) {
		var index = index
		var parent = self.heapIndexParent(index)

		while index != 0 && self.comparator(self.heap[index], self.heap[parent]) {
			self.heap.swapAt(parent, index)
			index = parent
			parent = self.heapIndexParent(index)
		}
	}

	private mutating func siftDown(_ index: Int) {
		var index = index
		var child = self.heapIndexLeftChild(index)

		while child < self.count {
			if child < self.count - 1 && self.comparator(self.heap[child + 1], self.heap[child]) {
				child += 1
			}

			if self.comparator(self.heap[child], self.heap[index]) {
				self.heap.swapAt(child, index)
				index = child
				child = self.heapIndexLeftChild(index)
			} else {
				break
			}
		}
	}

	private func heapIndexParent(_ index: Int) -> Int { (index - 1) / 2 }

	private func heapIndexLeftChild(_ index: Int) -> Int { 2 * index + 1 }

	private func heapIndexRightChild(_ index: Int) -> Int { 2 * index + 2 }
}

public extension PriorityQueue where Element : Comparable {
	init() {
		self.init(<)
	}
}

