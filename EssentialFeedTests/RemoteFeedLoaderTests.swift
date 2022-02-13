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

        sut.load()

        XCTAssertEqual(client.requestedUrls, [url])
    }

    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()

        var capturedError = [RemoteFeedLoader.Error?]()
        sut.load { capturedError.append($0) }

        let clientError = NSError(domain: "test", code: 0, userInfo: nil)
        client.completions[0](clientError)

        XCTAssertEqual(capturedError, [.connectivity])
    }

    // MARK: - Helpers

    private func makeSUT(
        url: URL = URL(string: "www.example.com")!,
        client: HTTPClientSpy = HTTPClientSpy()
    ) -> (RemoteFeedLoader, HTTPClientSpy) {
        return (RemoteFeedLoader(url: url, client: client), client)
    }

    private class HTTPClientSpy: HTTPClient {
        var requestedUrls = [URL]()
        var completions = [(Error) -> Void]()

        func get(from url: URL, _ completion: @escaping (Error) -> Void) {
            completions.append(completion)
            requestedUrls.append(url)
        }
    }
}
