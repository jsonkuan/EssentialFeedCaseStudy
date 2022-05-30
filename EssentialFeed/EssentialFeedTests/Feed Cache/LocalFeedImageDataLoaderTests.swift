import XCTest
import EssentialFeed

final class LocalFeedImageDataLoader {
    init(store: Any) {
    }
}

final class LocalFeedImageDataLoaderTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, loader) = makeSUT()
        
        XCTAssertTrue(loader.messages.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (LocalFeedImageDataLoader, FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        
        trackForMemoryLeak(sut)
        trackForMemoryLeak(store)
        
        return (sut, store)
    }
    
    private class FeedStoreSpy {
        let messages = [Any]()
    }
}

