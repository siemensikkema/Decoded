public protocol Unwrappable {
    associatedtype Unwrapped

    var unwrapped: Unwrapped { get throws }
}

extension DecodingResult: Unwrappable {
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
    public var unwrapped: T {
        get throws {
            try result.unwrapped
        }
    }
}

extension Sequence where Element: Unwrappable {
    public var unwrapped: [Element.Unwrapped] {
        get throws {
            try map { try $0.unwrapped }
        }
    }
}

extension Dictionary: Unwrappable where Value: Unwrappable {
    public var unwrapped: [Key: Value.Unwrapped] {
        get throws {
            try mapValues { try $0.unwrapped }
        }
    }
}
