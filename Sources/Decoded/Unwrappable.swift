/// Provides throwing access to an unwrapped value.
public protocol Unwrappable {
    associatedtype Unwrapped

    /// The unwrapped value. Can throw if the value cannot be unwrapped.
    var unwrapped: Unwrapped { get throws }
}

extension DecodingResult: Unwrappable {
    /// See `Unwrappable`.
    public var unwrapped: T {
        get throws {
            switch self {
            case .success(let success):
                return success.value
            case .failure(let failure):
                throw failure
            }
        }
    }
}

extension Decoded: Unwrappable {
    /// See `Unwrappable`.
    public var unwrapped: T {
        get throws {
            try result.unwrapped
        }
    }
}

extension Sequence where Element: Unwrappable {
    /// See `Unwrappable`.
    public var unwrapped: [Element.Unwrapped] {
        get throws {
            try map { try $0.unwrapped }
        }
    }
}

extension Dictionary: Unwrappable where Value: Unwrappable {
    /// See `Unwrappable`.
    public var unwrapped: [Key: Value.Unwrapped] {
        get throws {
            try mapValues { try $0.unwrapped }
        }
    }
}
