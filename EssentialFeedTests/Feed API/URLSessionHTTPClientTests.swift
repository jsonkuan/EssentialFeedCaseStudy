import XCTest

final class URLSessionHTTPClient {
    private let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func get(from url: URL) {
        session.dataTask(with: url) { _, _, _ in }
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
    func test_getFromUrl_createsDataTaskWithURL() {
        let url = URL(string: "https://test.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)

        sut.get(from: url)

        XCTAssertEqual(session.receivedUrls, [url])
    }
}

final class URLSessionSpy: URLSession {
    var receivedUrls = [URL]()

    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        receivedUrls.append(url)

        return FakeURLSessionDataTask()
    }
}

final class FakeURLSessionDataTask: URLSessionDataTask {}
