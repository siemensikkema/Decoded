/// The result of a decoding with its coding path.
///
/// This is the main point of interaction with this library. It is intended to be used in the context of decoding by wrapping around `Decodable` values in order to capture more information from the decoding process and collect any decoding errors along the way.
///
/// `Decoded` can be used on both decodable primitives and (the properties of) decodable structs or classes.
///
/// Using it with primitives can be done as follows:
///
/// ```swift
/// let int = try JSONDecoder().decode(Decoded<Int>.self, from: "1".data(using: .utf8)!)
/// print(int.value) // Optional(1)
/// print(try int.unwrapped) // 1
/// ```
///
/// If we were to pass it an incompatible value like a string, `value` would be `nil` and we could retrieve the decoding error as follows.
///
/// ```swift
/// print(decoded.result.failure?.decodingError) // Optional(Decoded.DecodingFailure(decodingError: ...
/// ```
///
/// Applying `Decoded` to a struct looks like this:
///
/// ```swift
/// struct Box: Decodable {
///     let contents: Decoded<String>
/// }
/// let box: try JSONDecoder().decode(Decoded<Box>.self, from #"{"contents": "🎁"}"#.data(using: .utf8)!)
/// print(try box.contents.unwrapped) // 🎁
/// print(box.contents.codingPath) // CodingPath(elements: [contents])
/// ```
///
/// Note how we can directly access `contents` even though `box` is of type `Decoded<Box>`.
///
/// Another thing to highlight about `Decoded` is its ability to distinguish between a value being absent or explicitly set to `null`.
///
/// ```swift
/// struct Optionals: Decodable {
///     let a: Decoded<Int?>
///     let b: Decoded<Int?>
///     let c: Decoded<Int?>
/// }
///
/// let optionals = try JSONDecoder().decode(Decoded<Optionals>.self, from: #"{"a": 1, "b": null}"#.data(using: .utf8)!)
/// print(optionals.a.unwrapped)        // Optional(1)
/// print(optionals.a.result.success)   // Optional(value: Optional(1))
/// print(optionals.b.unwrapped)        // nil
/// print(optionals.b.result.success)   // Optional(nil)
/// print(optionals.c.unwrapped)        // nil
/// print(optionals.c.result.success)   // Optional(absent)
/// ```
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
    /// The successful value of the `DecodingResult` or `nil`.
    var value: T? {
        result.value
    }
}
