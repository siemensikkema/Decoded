/// Represents a successful decoding attempt.
public enum DecodingSuccess<T> {
    /// No value is present. Only possible if `T` is an `Optional` type.
    case absent
    /// A `nil` value is present. Only possible if `T` is an `Optional` type.
    case `nil`
    /// A value was decoded.
    case value(T)
}

public extension DecodingSuccess {
    /// The decoded value.
    /// In case of either `absent` or `nil` (and therefore an `T` == `Optional<...>`) the value is returned as `Optional<...>.none`.
    var value: T {
        switch self {
        case .absent, .nil:
            return _valueAsNil!
        case .value(let value):
            return value
        }
    }

    private var _valueAsNil: T? {
        (T.self as? ExpressibleByNilLiteral.Type)?.init(nilLiteral: ()) as? T
    }
}

extension DecodingSuccess: Decodable where T: Decodable {
    /// See `Decodable`.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil(), T.self is ExpressibleByNilLiteral.Type {
            self = .nil
        } else {
            self = .value(try container.decode(T.self))
        }
    }
}

extension DecodingSuccess: Equatable where T: Equatable {}
extension DecodingSuccess: Hashable where T: Hashable {}
