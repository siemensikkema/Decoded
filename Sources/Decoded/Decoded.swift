/// The result of a decoding with its coding path.
@dynamicMemberLookup
public struct Decoded<T> {
    /// The path of type-erased coding keys taken to get to this point in decoding.
    public let codingPath: CodingPath
    /// The result of the decoding.
    public let result: DecodingResult<T>
}

extension Decoded: Decodable where T: Decodable {
    /// See `Decodable`.
    public init(from decoder: Decoder) throws {
        codingPath = .init(decoder.codingPath)
        result = try .init(from: decoder)
    }
}

extension Decoded: Hashable where T: Hashable {}
extension Decoded: Equatable where T: Equatable {}

public extension KeyedDecodingContainer {
    /// Enables decoding of `Decoded` properties.
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
    /// Returns a new `Decoded`, either mapping from the successfully decoded value and unwrapping the result, or reiterating the failure.
    /// - Returns: A new `Decoded` value of the nested type.
    func flatMap<U>(_ keyPath: KeyPath<T, Decoded<U>>) -> Decoded<U> {
        switch result {
        case .failure(let failure):
            return .init(codingPath: codingPath, result: .failure(failure))
        case .success(let success):
            return success.value[keyPath: keyPath]
        }
    }

    /// Returns a new `Decoded`, either mapping from the successfully decoded value and repackaging the result, or reiterating the failure.
    /// - Returns: A new `Decoded` value of the nested type.
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
    /// The successful value of the `DecodingResult`, or `nil`.
    var value: T? {
        result.value
    }
}
