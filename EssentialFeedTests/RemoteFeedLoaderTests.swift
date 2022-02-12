import XCTest
@testable import EssentialFeed

final class RemoteFeedLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let (_, sut) = makeSUT()

        XCTAssertNil(sut.client.requestedUrl)
    }

    func test_load_requestsDataFromUrl() {
        let (client, sut) = makeSUT()
        XCTAssertNil(client.requestedUrl)

        sut.load()

        XCTAssertEqual(sut.url, client.requestedUrl)
    }

    // MARK: - Helpers

    private func makeSUT(
        url: URL = URL(string: "www.example.com")!,
        client: HTTPClient = HTTPClientSpy()
    ) -> (HTTPClient, RemoteFeedLoader) {
        return (client, RemoteFeedLoader(url: url, client: client))
    }

    private class HTTPClientSpy: HTTPClient {
        var requestedUrl: URL?

        func get(from url: URL) {
            requestedUrl = url
        }
    }
}
