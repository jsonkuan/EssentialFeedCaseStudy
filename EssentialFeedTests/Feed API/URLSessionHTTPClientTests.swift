import XCTest
import EssentialFeed

final class URLSessionHTTPClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error)  )
            }
        }.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
    func test_getFromUrl_failsOnRequestError() {
        URLProtocolStub.startInterceptingRequests()

        let url = URL(string: "https://test.com")!
        let error = NSError(domain: "SomeError", code: 0)
        URLProtocolStub.stub(with: error)

        let sut = URLSessionHTTPClient()

        let exp = expectation(description: "Wait for completion")

        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertNotNil(receivedError)
            default:
                XCTFail("Expected failure with \(error), but got \(result) instead.")
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        URLProtocolStub.stopInterceptingRequests()
    }

    // MARK: - Stub

    private class URLProtocolStub: URLProtocol {
        private static var stubs = [Stub]()

        private struct Stub {
            let error: Error?
        }

        // MARK: - Helpers

        static func stub(with error: Error? = nil) {
            let stub = Stub(error: error)
            URLProtocolStub.stubs.append(stub)
        }

        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }

        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stubs.removeAll()
        }

        // MARK: - URL Protocol

        override class func canInit(with request: URLRequest) -> Bool {
            true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }

        override func startLoading() {
            if let error = URLProtocolStub.stubs[0].error {
                client?.urlProtocol(self, didFailWithError: error)
            }

            client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() {}
    }
}
