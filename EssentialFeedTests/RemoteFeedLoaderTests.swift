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

        expect(sut: sut, toCompleteWithError: .connectivity) {
            let clientError = NSError(domain: "test", code: 0, userInfo: nil)
            client.complete(with: clientError, at: 0)
        }
    }

    func test_load_deliversErrorOnNonHTTPResponse() {
        let (sut, client) = makeSUT()

        let samples = [199, 201, 400, 500]
        samples.enumerated().forEach { index, code in
            expect(sut: sut, toCompleteWithError: .invalidData) {
                client.complete(statusCode: code, at: index)
            }
        }
    }

    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()

        expect(sut: sut, toCompleteWithError: .invalidData) {
            let invalidJSON = Data("Invalid json".utf8)
            client.complete(statusCode: 200, data: invalidJSON)
        }
    }

    func test_load_delieversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()

        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load { capturedResults.append($0) }

        let emptyJson = Data(" {\"items\": []}".utf8)
        client.complete(statusCode: 200, data: emptyJson)

        XCTAssertEqual(capturedResults, [.success([])])
    }

    // MARK: - Helpers

    private func makeSUT(
        url: URL = URL(string: "www.example.com")!,
        client: HTTPClientSpy = HTTPClientSpy()
    ) -> (RemoteFeedLoader, HTTPClientSpy) {
        return (RemoteFeedLoader(url: url, client: client), client)
    }

    private func expect(sut: RemoteFeedLoader,
                        toCompleteWithError error: RemoteFeedLoader.Error,
                        when action: () -> Void,
                        file: StaticString = #filePath, line: UInt = #line) {

        var capturedErrors = [RemoteFeedLoader.Result]()
        sut.load { capturedErrors.append($0) }

        action()

        XCTAssertEqual(capturedErrors, [.failure(error)], file: file, line: line)
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

    func complete(statusCode: Int, data: Data = Data(), at index: Int = 0 ) {
        let response = HTTPURLResponse(
            url: requestedUrls[index],
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil)!

        messages[index].completion(.success(data, response))
    }
}
