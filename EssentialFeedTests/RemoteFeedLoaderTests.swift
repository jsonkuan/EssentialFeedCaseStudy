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

    // MARK: - Helpers

    private func makeSUT(
        url: URL = URL(string: "www.example.com")!,
        client: HTTPClientSpy = HTTPClientSpy()
    ) -> (RemoteFeedLoader, HTTPClientSpy) {
        return (RemoteFeedLoader(url: url, client: client), client)
    }

    private class HTTPClientSpy: HTTPClient {
        var requestedUrls = [URL]()

        func get(from url: URL) {
            requestedUrls.append(url)
        }
    }
}
