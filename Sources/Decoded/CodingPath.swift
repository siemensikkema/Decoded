/// The path of type-erased coding keys taken to get to a point in decoding.
///
/// The use of `[AnyCodingKey]` allows this type to be used as a dictionary key (ie. it can conform to `Hashable`) where `[CodingKey]` cannot.
public struct CodingPath: Hashable {
    /// The elements of the `CodingPath` as type-erased coding keys.
    public let elements: [AnyCodingKey]

    init(_ codingPath: [CodingKey]) {
        self.elements = codingPath.map(AnyCodingKey.init)
    }
}

extension CodingPath: ExpressibleByArrayLiteral {
    /// See `ExpressibleByArrayLiteral`.
    public init(arrayLiteral elements: AnyCodingKey...) {
        self.elements = elements
    }
}

public extension CodingPath {
    /// A representation of the `CodingPath` as the path elements separated by `.`.
    var dotPath: String {
        elements.map(\.description).joined(separator: ".")
    }
}
