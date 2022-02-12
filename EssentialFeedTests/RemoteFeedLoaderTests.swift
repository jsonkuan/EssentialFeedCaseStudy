import XCTest
@testable import EssentialFeed

final class RemoteFeedLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let sut = RemoteFeedLoader(client: HTTPClientSpy())

        XCTAssertNil(sut.client.requestedUrl)
    }

    func test_load_requestsDataFromUrl() {
        let sut = RemoteFeedLoader(client: HTTPClientSpy())

        sut.load()

        XCTAssertEqual(URL(string: "https://example.com")!, sut.client.requestedUrl)
    }
}

final class RemoteFeedLoader {
    let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    func load() {
        client.get(from: URL(string: "https://example.com")!)
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
