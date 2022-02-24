import XCTest
import EssentialFeed

final class FeedStore {
    var deleteCacheFeedCallCount = 0
}

final class LocalFeedLoader {
    let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCacheFeedCallCount += 1
    }
}

final class FeedCacheTests: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let sut = makeSUT()
        
        XCTAssertEqual(sut.store.deleteCacheFeedCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let sut = makeSUT()
        
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        
        XCTAssertEqual(sut.store.deleteCacheFeedCallCount, 1)
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> LocalFeedLoader {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        
        return sut
    }
    
    private func uniqueItem() -> FeedItem {
        FeedItem(id: UUID(), description: nil, location: nil, imageUrl: URL(string: "https://any-url.com")!)
    }
}
