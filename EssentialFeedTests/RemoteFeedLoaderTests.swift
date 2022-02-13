import XCTest
import EssentialFeed

final class RemoteFeedLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedUrls.isEmpty)
    }

    func test_load_requestsDataFromUrl() {
        let url = URL(string: "www.test.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load { _ in }

        XCTAssertEqual(client.requestedUrls, [url])
    }

    func test_loadTwice_requestsDataFromUrlTwice() {
        let url = URL(string: "www.test.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load { _ in }
        sut.load { _ in }

        XCTAssertEqual(client.requestedUrls, [url, url])
    }

    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()

        var capturedError = [RemoteFeedLoader.Error?]()
        sut.load { capturedError.append($0) }

        let clientError = NSError(domain: "test", code: 0, userInfo: nil)
        client.complete(with: clientError, at: 0)

        XCTAssertEqual(capturedError, [.connectivity])
    }

    func test_load_deliversErrorOnNonHTTPResponse() {
        let (sut, client) = makeSUT()

        var capturedError = [RemoteFeedLoader.Error?]()
        sut.load { capturedError.append($0) }

        client.complete(statusCode: 400, at: 0)

        XCTAssertEqual(capturedError, [.invalidData])
    }

    // MARK: - Helpers

    private func makeSUT(
        url: URL = URL(string: "www.example.com")!,
        client: HTTPClientSpy = HTTPClientSpy()
    ) -> (RemoteFeedLoader, HTTPClientSpy) {
        return (RemoteFeedLoader(url: url, client: client), client)
    }

    private class HTTPClientSpy: HTTPClient {
        var messages = [(url: URL, completion: (Error?, HTTPURLResponse?) -> Void)]()
        var statusCode: Int?

        var requestedUrls: [URL] {
            messages.map { $0.url }
        }

        func get(from url: URL, _ completion: @escaping (Error?, HTTPURLResponse?) -> Void) {
            messages.append((url, completion))
        }

        func complete(with error: Error, at index: Int) {
            messages[index].completion(error, nil)
        }

        func complete(statusCode: Int, at index: Int) {
            let response = HTTPURLResponse(
                url: requestedUrls[index],
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil)

            messages[0].completion(nil, response)
        }
    }
}
