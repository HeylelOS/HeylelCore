
@propertyWrapper
public final class Box<Value> {
	public var wrappedValue: Value

	public init(wrappedValue: Value) {
		self.wrappedValue = wrappedValue
	}
}

@propertyWrapper
public struct CopyOnWrite<Value> {
	private var wrappedValueBox: Box<Value>

	public init(wrappedValue: Value) {
		self.wrappedValueBox = Box(wrappedValue: wrappedValue)
	}

	public var wrappedValue: Value {
		get { self.wrappedValueBox.wrappedValue }
		set {
			if !isKnownUniquelyReferenced(&self.wrappedValueBox) {
				self.wrappedValueBox = Box(wrappedValue: newValue)
			} else {
				self.wrappedValueBox.wrappedValue = newValue
			}
		}
	}
}

