import XCTest
import EssentialFeed

final class CodeableFeedStore {
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        completion(.empty)
    }
}

final class CodeableFeedStoreTests: XCTestCase {
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
}
 

