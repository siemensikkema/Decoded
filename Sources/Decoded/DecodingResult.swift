/// The result of decoding a value.
public enum DecodingResult<T> {
    /// Indicates that decoding was successful.
    case success(DecodingSuccess<T>)
    /// Indicates that decoding failed.
    case failure(DecodingFailure)
}

public extension DecodingResult {
    /// The decoding success, or `nil`.
    var success: DecodingSuccess<T>? {
        guard case .success(let success) = self else {
            return nil
        }
        return success
    }

    /// The decoding failure, or `nil`.
    var failure: DecodingFailure? {
        guard case .failure(let failure) = self else {
            return nil
        }
        return failure
    }
}

public extension DecodingResult {
    /// The successful value of the `DecodingResult` or `nil`.
    var value: T? {
        success?.value
    }
}

extension DecodingResult: Decodable where T: Decodable {
    /// See `Decodable`.
    public init(from decoder: Decoder) throws {
        do {
            self = try .success(DecodingSuccess<T>(from: decoder))
        } catch let error as DecodingError {
            self = try .failure(.init(decodingError: error))
        }
    }
}

extension DecodingResult: Equatable where T: Equatable {}
extension DecodingResult: Hashable where T: Hashable {}
