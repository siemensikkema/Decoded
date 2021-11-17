public struct CodingPath: Hashable {
    init(_ codingPath: [CodingKey]) {
        self.elements = codingPath.map(AnyCodingKey.init)
    }
    let elements: [AnyCodingKey]

    public subscript(_ index: Array.Index) -> AnyCodingKey {
        elements[index]
    }
}

extension CodingPath: ExpressibleByArrayLiteral {
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
