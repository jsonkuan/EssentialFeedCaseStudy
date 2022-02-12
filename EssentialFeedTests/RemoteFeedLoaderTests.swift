import XCTest
@testable import EssentialFeed

final class RemoteFeedLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let url = URL(string: "https://example.com")!
        let sut = RemoteFeedLoader(url: url, client: HTTPClientSpy())

        XCTAssertNil(sut.client.requestedUrl)
    }

    func test_load_requestsDataFromUrl() {
        let url = URL(string: "https://example.com")!
        let sut = RemoteFeedLoader(url: url, client: HTTPClientSpy())

        sut.load()

        XCTAssertEqual(url, sut.client.requestedUrl)
    }
}

final class RemoteFeedLoader {
    let url: URL
    let client: HTTPClient

    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    func load() {
        client.get(from: url)
    }
}

protocol HTTPClient {
    var requestedUrl: URL? { get set }

    func get(from url: URL)
}

final class HTTPClientSpy: HTTPClient {
    var requestedUrl: URL?

    func get(from url: URL) {
        requestedUrl = url
    }
}
