import XCTest
import EssentialFeed

final class URLSessionHTTPClient {
    private let session: URLSession

    init(session: URLSession) {
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
    func test_getFromUrl_resumesDataTaskWithURL() {
        let url = URL(string: "https://test.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataSpy()
        session.stub(url, with: task)
        let sut = URLSessionHTTPClient(session: session)

        sut.get(from: url) { _ in }

        XCTAssertEqual(task.resumeCount, 1)
    }

    func test_getFromUrl_failsOnRequestError() {
        let url = URL(string: "https://test.com")!
        let session = URLSessionSpy()
        let error = NSError(domain: "0", code: 0)
        session.stub(url, error: error)
        let sut = URLSessionHTTPClient(session: session)

        let exp = expectation(description: "Wait for completion")

        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
            default:
                XCTFail("Expected failure with \(error), but got \(result) instead.")
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    // MARK: - Helpers

    private  class URLSessionSpy: URLSession {
        private var stubs = [URL: Stub]()

        private struct Stub {
            let task: URLSessionDataTask
            let error: Error?
        }

        func stub(_ url: URL, with task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
            let value = Stub(task: task, error: error)
            stubs.updateValue(value, forKey: url)
        }

        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            guard let stub = stubs[url] else {
                fatalError("Coulnt find stub for \(url)")
            }
            completionHandler(nil, nil, stub.error)
            return stub.task
        }

    }

    private class FakeURLSessionDataTask: URLSessionDataTask {}

    private class URLSessionDataSpy: URLSessionDataTask {
        var resumeCount = 0

        override func resume() {
            resumeCount += 1
        }
    }
}
