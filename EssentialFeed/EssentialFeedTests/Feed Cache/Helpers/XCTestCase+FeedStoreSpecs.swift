import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: .empty, file: file, line: line)
    }
    
    @discardableResult
    func deleteCache(from sut: FeedStore) -> Error? {
        let exp = XCTestExpectation(description: "Waiting for deletion completion")
        
        var deletionError: Error?
        sut.deleteCachedFeed { receivedDeletionError in
            deletionError = receivedDeletionError
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
    
    @discardableResult
    func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
        let exp = XCTestExpectation(description: "Waiting for insertion completion")
        
        var insertionError: Error?
        sut.insert(cache.feed, currentDate: cache.timestamp) { receivedInsertionError in
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        return insertionError
    }
    
    func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCacheFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = XCTestExpectation(description: "Waiting for completion")
        
        sut.retrieve { retrievedResult in
            switch (retrievedResult, expectedResult) {
            case (.empty, .empty), (.failure, .failure):
                break
                
            case let (.found(expectedFeed, expectedTimestamp), .found(retrievedFeed, retrievedTimestamp)):
                XCTAssertEqual(retrievedFeed, expectedFeed, file: file, line: line)
                XCTAssertEqual(retrievedTimestamp, expectedTimestamp, file: file, line: line)
                
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead.", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCacheFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
}
