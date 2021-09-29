import Decoded
import XCTest

final class TopLevelValueDecodingTests: XCTestCase {
    func test_value() throws {
        let decoded: Decoded<Int> = try decode("1")
        XCTAssertEqual(decoded.codingPath, [])
        XCTAssertEqual(decoded.result, .success(.value(1)))
        XCTAssertEqual(decoded.value, 1)
    }

    func test_expected_nil() throws {
        let decoded: Decoded<Int?> = try decode("null")
        XCTAssertEqual(decoded.codingPath, [])
        XCTAssertEqual(decoded.result, .success(.nil))
        XCTAssertNil(try decoded.unwrapped)
    }

    func test_unexpected_nil() throws {
        let decoded: Decoded<Int> = try decode("null")
        XCTAssertEqual(decoded.codingPath, [])

        guard case .failure(let failure) = decoded.result else {
            XCTFail("")
            return
        }
        XCTAssertEqual(failure.errorType, .valueNotFound)
        XCTAssertEqual(failure.debugDescription, "Expected Int but found null value instead.")
        XCTAssertThrowsError(try decoded.unwrapped)
    }
}
