/// A type-erased coding key
public struct AnyCodingKey: CodingKey, Hashable {
    /// See `CodingKey`.
    public let stringValue: String

    /// See `CodingKey`.
    public let intValue: Int?

    /// See `CustomStringConvertible`.
    public var description: String { stringValue }

    init(codingKey: CodingKey) {
        self.stringValue = codingKey.stringValue
        self.intValue = codingKey.intValue
    }

    /// See `CodingKey`.
    public init(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    /// See `CodingKey`.
    public init(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
}

extension AnyCodingKey: ExpressibleByStringLiteral {
    /// See `ExpressibleByStringLiteral`.
    public init(stringLiteral value: String) {
        self.init(stringValue: value)
    }
}

extension AnyCodingKey: ExpressibleByIntegerLiteral {
    /// See `ExpressibleByIntegerLiteral`.
    public init(integerLiteral value: Int) {
        self.init(intValue: value)
    }
}
