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

        expect(sut: sut, toCompleteWithResult: .failure(RemoteFeedLoader.Error.connectivity)) {
            let clientError = NSError(domain: "test", code: 0, userInfo: nil)
            client.complete(with: clientError, at: 0)
        }
    }

    func test_load_deliversErrorOnNonHTTPResponse() {
        let (sut, client) = makeSUT()

        let samples = [199, 201, 400, 500]
        samples.enumerated().forEach { index, code in
            expect(sut: sut, toCompleteWithResult: .failure(RemoteFeedLoader.Error.invalidData)) {
                let json = makeItemsJSON([] )
                client.complete(statusCode: code, data: json, at: index)
            }
        }
    }

    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()

        expect(sut: sut, toCompleteWithResult: .failure(RemoteFeedLoader.Error.invalidData)) {
            let invalidJSON = Data("Invalid json".utf8)
            client.complete(statusCode: 200, data: invalidJSON)
        }
    }

    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()

        expect(sut: sut, toCompleteWithResult: .success([])) {
            let emptyJson = Data(" {\"items\": []}".utf8)
            client.complete(statusCode: 200, data: emptyJson)
        }
    }

    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "https://test.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)

        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load { capturedResults.append($0 )}

        sut = nil
        client.complete(statusCode: 200, data: makeItemsJSON([]))

        XCTAssertTrue(capturedResults.isEmpty)
    }

    func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()

        let item1 = makeItem(id: UUID(), image: URL(string: "test.com")!)
        let item2 = makeItem(id: UUID(), description: "abc", location: "123", image: URL(string: "https://url.com")!)

        let items = [item1.model, item2.model]

        expect(sut: sut, toCompleteWithResult: .success(items)) {
            let json = makeItemsJSON([item1.json, item2.json])
            client.complete(statusCode: 200, data: json)
        }
    }

    // MARK: - Helpers

    private func makeSUT(url: URL = URL(string: "www.example.com")!,
                         client: HTTPClientSpy = HTTPClientSpy(),
                         file: StaticString = #filePath, line: UInt = #line
    ) -> (RemoteFeedLoader, HTTPClientSpy) {
        let sut = RemoteFeedLoader(url: url, client: client)
        trackForMemoryLeak(sut)
        trackForMemoryLeak(client)

        return (sut, client)
    }

    private func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Potential memory leak.", file: file, line: line)
        }
    }

    private func makeItem(id: UUID,
                          description: String? = nil,
                          location: String? = nil,
                          image: URL) -> (model: FeedItem, json: [String: Any]) {
        let item = FeedItem(id: id, description: description, location: location, imageUrl: image)
        let json = [
            "id": item.id.uuidString,
            "description": item.description,
            "location": item.location,
            "image": item.imageUrl.absoluteString
        ].reduce(into: [String: Any]()) { (acc, e) in
            if let value = e.value { acc[e.key] = value }
        }

        return (item, json)
    }

    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }

    private func expect(sut: RemoteFeedLoader,
                        toCompleteWithResult expectedResult: RemoteFeedLoader.Result,
                        when action: () -> Void,
                        file: StaticString = #filePath, line: UInt = #line) {

        let exp = expectation(description: "Wait for load completion")

        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult), but received \(receivedResult)", file: file, line: line)
            }

            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 1.0)
    }
}

// MARK: - Spy

private class HTTPClientSpy: HTTPClient {
    var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()

    var requestedUrls: [URL] {
        messages.map { $0.url }
    }

    func get(from url: URL, _ completion: @escaping (HTTPClientResult) -> Void) {
        messages.append((url, completion))
    }

    func complete(with error: Error, at index: Int) {
        messages[index].completion(.failure(error))
    }

    func complete(statusCode: Int, data: Data, at index: Int = 0 ) {
        let response = HTTPURLResponse(
            url: requestedUrls[index],
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil)!

        messages[index].completion(.success(data, response))
    }
}
