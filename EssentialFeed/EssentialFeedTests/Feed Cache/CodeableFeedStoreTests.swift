import XCTest
import EssentialFeed

final class CodeableFeedStore {
    private struct Cache: Codable {
        let feed: [LocalFeedImage]
        let timestamp: Date
    }
    
    let storeURL = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)
        .first!
        .appendingPathComponent("image-feed.store")
    
    func insert(_ feed: [LocalFeedImage], currentDate: Date, completion: @escaping FeedStore.ErrorCompletion) {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(Cache(feed: feed, timestamp: currentDate))

        try! data.write(to: storeURL)
        completion(nil)
    }
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }

        let cache = try! JSONDecoder().decode(Cache.self, from: data)
        completion(.found(feed: cache.feed, timestamp: cache.timestamp))
    }
}

final class CodeableFeedStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    override func tearDown() {
        super.tearDown()
        
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodeableFeedStore()
        
        let exp = XCTestExpectation(description: "Waiting for retrieval completion")
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty result, but got \(result) instead.")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCacheWhenRetrievingTwice() {
        let sut = CodeableFeedStore()
        
        let exp = XCTestExpectation(description: "Waiting for retrieval completion")
        
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                    
                default:
                    XCTFail("Expected retrieving twice from empty cache to delivers same empty result, got \(firstResult) & \(secondResult) instead.")
                }
                
                exp.fulfill()
            }
        }
            
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = CodeableFeedStore()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        let exp = XCTestExpectation(description: "Waiting for retrieval completion")
        
        sut.insert(feed, currentDate: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully.")
            
            sut.retrieve { result in
                switch result {
                case let .found(feed: retrievedFeed, timestamp: retrievedTimestamp):
                    XCTAssertEqual(retrievedFeed, feed)
                    XCTAssertEqual(retrievedTimestamp, timestamp)
                
                default:
                    XCTFail("Expected 'found' result when retrieving feed: \(feed) & \(timestamp), got \(result) instead.")
                }
                
                exp.fulfill()
            }
        }
            
        wait(for: [exp], timeout: 1.0)
    }
}
 
