/// A wrapper around `DecodingError`.
public struct DecodingFailure: Error {
    /// The type of errors that can be captured.
    public enum DecodingErrorType: Equatable, Hashable {
        /// Corrupted or invalid data.
        case dataCorrupted
        /// The decoding container did not contain the expected key.
        case keyNotFound
        /// The encoded data could not be decoded into the expected type.
        case typeMismatch
        /// A `null` value was found whereas a non-optional value was expected.
        case valueNotFound
    }

    /// The underlying `DecodingError`.
    public let decodingError: DecodingError

    init(decodingError: DecodingError) throws {
        switch decodingError {
        case .dataCorrupted, .keyNotFound, .typeMismatch, .valueNotFound:
            self.decodingError = decodingError
        @unknown default:
            throw decodingError
        }
    }
}

public extension DecodingFailure {
    /// The captured error type.
    var errorType: DecodingErrorType {
        switch decodingError {
        case .dataCorrupted:
            return .dataCorrupted
        case .keyNotFound:
            return .keyNotFound
        case .typeMismatch:
            return .typeMismatch
        case .valueNotFound:
            return .valueNotFound
        @unknown default:
            // Guaranteed not to happen due to the check in the initializer.
            fatalError()
        }
    }
}

extension DecodingFailure: Equatable {
    /// See `Equatable`.
    /// Note: only the `errorType` and `debugDescription` are considered.
    public static func == (lhs: DecodingFailure, rhs: DecodingFailure) -> Bool {
        lhs.errorType == rhs.errorType && lhs.debugDescription == rhs.debugDescription
    }
}

extension DecodingFailure: Hashable {
    /// See `Hashable`.
    /// Note: only the `errorType` and `debugDescription` are considered.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(errorType)
        hasher.combine(debugDescription)
    }
}

extension DecodingFailure: CustomDebugStringConvertible {
    /// See `CustomDebugStringConvertible`.
    public var debugDescription: String {
        context.debugDescription
    }

    private var context: DecodingError.Context {
        switch decodingError {
        case .typeMismatch(_, let context):
            return context
        case .valueNotFound(_, let context):
            return context
        case .keyNotFound(_, let context):
            return context
        case .dataCorrupted(let context):
            return context
        @unknown default:
            // Guaranteed not to happen due to the check in the initializer.
            fatalError()
        }
    }
}
