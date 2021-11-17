@dynamicMemberLookup
public struct Decoded<T> {
    public let codingPath: CodingPath
    public let result: DecodingResult<T>
}

extension Decoded: Decodable where T: Decodable {
    public init(from decoder: Decoder) throws {
        codingPath = .init(decoder.codingPath)
        result = try .init(from: decoder)
    }
}

extension Decoded: Hashable where T: Hashable {}
extension Decoded: Equatable where T: Equatable {}

public extension KeyedDecodingContainer {
    func decode<T: Decodable>(
        _ type: Decoded<T>.Type,
        forKey key: Key
    ) throws -> Decoded<T> {
        let codingPath = codingPath + [key]
        let result: DecodingResult<T>

        do {
            result = try decode(DecodingResult<T>.self, forKey: key)
        } catch let error as DecodingError {
            switch (error, T.self is ExpressibleByNilLiteral.Type) {
            case (.valueNotFound, false), (.keyNotFound, false):
                result = try .failure(.init(decodingError: error))
            case (.valueNotFound, true):
                result = .success(.nil)
            case (.keyNotFound, true):
                result = .success(.absent)
            default:
                throw error
            }
        }

        return .init(codingPath: .init(codingPath), result: result)
    }
}

public extension Decoded {
    func flatMap<U>(_ keyPath: KeyPath<T, Decoded<U>>) -> Decoded<U> {
        switch result {
        case .failure(let failure):
            return .init(codingPath: codingPath, result: .failure(failure))
        case .success(let success):
            return success.value[keyPath: keyPath]
        }
    }

    func map<U>(_ keyPath: KeyPath<T, U>) -> Decoded<U> {
        switch result {
        case .failure(let failure):
            return .init(codingPath: codingPath, result: .failure(failure))
        case .success(let success):
            return .init(codingPath: codingPath, result: .success(.value(success.value[keyPath: keyPath])))
        }
    }
}

public extension Decoded {
    subscript<U>(dynamicMember keyPath: KeyPath<T, Decoded<U>>) -> Decoded<U> {
        flatMap(keyPath)
    }

    subscript<U>(dynamicMember keyPath: KeyPath<T, U>) -> Decoded<U> {
        map(keyPath)
    }
}

public extension Decoded {
    var failure: DecodingFailure? {
        result.failure
    }

    var success: DecodingSuccess<T>? {
        result.success
    }

    var value: T? {
        result.value
    }
}
