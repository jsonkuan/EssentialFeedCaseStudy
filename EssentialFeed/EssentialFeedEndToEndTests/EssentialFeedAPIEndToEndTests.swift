import XCTest
import EssentialFeed

final class EssentialFeedAPIEndToEndTests: XCTestCase {
    func test_EndtoEndTestServerGETFeedResult_matchesFixedTestAccountdata() {
        switch getFeedResult() {
        case let .success(images)?:
            XCTAssertEqual(images.count, 8, "Expected 8 feed images in the test account feed")
            XCTAssertEqual(images[0], expectedFeedImage(at: 0))
            XCTAssertEqual(images[1], expectedFeedImage(at: 1))
            XCTAssertEqual(images[2], expectedFeedImage(at: 2))
            XCTAssertEqual(images[2], expectedFeedImage(at: 2))
            XCTAssertEqual(images[3], expectedFeedImage(at: 3))
            XCTAssertEqual(images[4], expectedFeedImage(at: 4))
            XCTAssertEqual(images[5], expectedFeedImage(at: 5))
            XCTAssertEqual(images[6], expectedFeedImage(at: 6))
            XCTAssertEqual(images[7], expectedFeedImage(at: 7))

        case let .failure(error)?:
            XCTFail("Expected to succeed, but failed with \(error)")
        default:
            XCTFail("Expected to succeed, but failed")
        }
    }
    
    func test_endToEndTestServerGETFeedImageDataResult_matchesFixedTestAccountData() {
        switch getFeedImageDataResult() {
        case let .success(data)?:
            XCTAssertFalse(data.isEmpty, "Expected non-empty image data")
            
        case let .failure(error)?:
            XCTFail("Expected successful image data result, got \(error) instead")
            
        default:
            XCTFail("Expected successful image data result, got no result instead")
        }
    }

    private func getFeedResult(file: StaticString = #filePath, line: UInt = #line) -> FeedLoader.Result? {
        let testServerURL = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let client = URLSessionHTTPClient(session: URLSession.init(configuration: .ephemeral))
        let loader = RemoteFeedLoader(url: testServerURL, client: client)

        trackForMemoryLeak(client, file: file, line: line)
        trackForMemoryLeak(loader, file: file, line: line)

        let exp = XCTestExpectation(description: "Wait for completion")
        var receivedResult: FeedLoader.Result?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }

        wait(for: [exp], timeout: 5.0)
        return receivedResult
    }

    private func getFeedImageDataResult(file: StaticString = #file, line: UInt = #line) -> FeedImageDataLoader.Result? {
        let testServerURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let loader = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeak(client, file: file, line: line)
        trackForMemoryLeak(loader, file: file, line: line)
        
        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult: FeedImageDataLoader.Result?
        _ = loader.loadImageData(from: testServerURL) { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
        
        return receivedResult
    }

    // MARK: - Helpers

    private func expectedFeedImage(at index: Int) -> FeedImage {
        return FeedImage(
            id: id(at: index),
            description: description(at: index),
            location: location(at: index),
            url: imageURL(at: index)
        )
    }

    private func id(at index: Int) -> UUID {
        return UUID(uuidString: [
            "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6",
            "BA298A85-6275-48D3-8315-9C8F7C1CD109",
            "5A0D45B3-8E26-4385-8C5D-213E160A5E3C",
            "FF0ECFE2-2879-403F-8DBE-A83B4010B340",
            "DC97EF5E-2CC9-4905-A8AD-3C351C311001",
            "557D87F1-25D3-4D77-82E9-364B2ED9CB30",
            "A83284EF-C2DF-415D-AB73-2A9B8B04950B",
            "F79BD7F8-063F-46E2-8147-A67635C3BB01"
        ][index])!
    }

    private func description(at index: Int) -> String? {
        return [
            "Description 1",
            nil,
            "Description 3",
            nil,
            "Description 5",
            "Description 6",
            "Description 7",
            "Description 8"
        ][index]
    }

    private func location(at index: Int) -> String? {
        return [
            "Location 1",
            "Location 2",
            nil,
            nil,
            "Location 5",
            "Location 6",
            "Location 7",
            "Location 8"
        ][index]
    }

    private func imageURL(at index: Int) -> URL {
        return URL(string: "https://url-\(index+1).com")!
    }
}
