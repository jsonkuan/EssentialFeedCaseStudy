import XCTest
@testable import EssentialFeed

final class RemoteFeedLoaderTests: XCTestCase {
    func test_init_doesNotRequestUrl() {
        let sut = RemoteFeedLoader()
    
        XCTAssertNil(sut.client.requestedUrl)
    }
}

final class RemoteFeedLoader {
    let client: HTTPClient
    
    init(client: HTTPClient = HTTPClient()) {
        self.client = client
    }
}

struct HTTPClient {
    var requestedUrl: URL?
}
