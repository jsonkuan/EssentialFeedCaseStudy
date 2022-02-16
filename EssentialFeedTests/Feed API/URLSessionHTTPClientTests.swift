import XCTest

final class URLSessionHTTPClient {
    private let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func get(from url: URL) {
        session.dataTask(with: url) { _, _, _ in }.resume()
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

    func test_getFromUrl_resumesDataTaskWithURL() {
        let url = URL(string: "https://test.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataSpy()
        session.stub(url, with: task)
        let sut = URLSessionHTTPClient(session: session)

        sut.get(from: url)

        XCTAssertEqual(task.resumeCount, 1)
    }
}

final class URLSessionSpy: URLSession {
    var receivedUrls = [URL]()
    var stubs = [URL: URLSessionDataTask]()

    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        receivedUrls.append(url)

        return stubs[url] ?? FakeURLSessionDataTask()
    }

    func stub(_ url: URL, with task: URLSessionDataTask) {
        stubs.updateValue(task, forKey: url)
    }
}

final class FakeURLSessionDataTask: URLSessionDataTask {}

final class URLSessionDataSpy: URLSessionDataTask {
    var resumeCount = 0

    override func resume() {
        resumeCount += 1
    }
}
