import XCTest
import EssentialFeed

final class CodeableFeedStoreTests: XCTestCase, FailableFeedStoreSpec {
    override func setUp() {
        super.setUp()

        setupEmptyStoreState()
    }

    override func tearDown() {
        super.tearDown()

        undoStoreSideEffects()
    }

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()

        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()

        expect(sut, toRetrieveTwice: .empty)
    }
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()

        insert((feed, timestamp), to: sut)

        expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
    }

    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()

        insert((feed, timestamp), to: sut)

        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }

    func test_retrieve_deliversFailureWithInvalidJSON() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(url: storeURL)

        try! "Invalid json".write(to: storeURL, atomically: false, encoding: .utf8)

        expect(sut, toRetrieve: .failure(anyNSError()))
    }

    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(url: storeURL)

        try! "Invalid json".write(to: storeURL, atomically: false, encoding: .utf8)

        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }

    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        insert((uniqueImageFeed().local, Date()), to: sut)

        let latestFeed = uniqueImageFeed().local
        let lastestTimestamp = Date()
        insert((latestFeed, lastestTimestamp), to: sut)

        expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: lastestTimestamp))
    }

    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(url: invalidStoreURL)

        let insertionError = insert((feed: uniqueImageFeed().local, timestamp: Date()), to: sut)

        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
    }

    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(url: invalidStoreURL)

        insert((feed: uniqueImageFeed().local, timestamp: Date()), to: sut)

        expect(sut, toRetrieve: .empty)
    }

    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()

        deleteCache(from: sut)

        expect(sut, toRetrieve: .empty)
    }

    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        insert((feed: uniqueImageFeed().local, timestamp: Date()), to: sut)

        deleteCache(from: sut)

        expect(sut, toRetrieve: .empty)
    }

    func test_delete_deliversErrorOnDeletionError() {
//        let noDeletePermissionsUrl = cachesDirectory()
//        let sut = makeSUT(url: noDeletePermissionsUrl)
//
//        let deletionError = deleteCache(from: sut)
//
//        XCTAssertNotNil(deletionError, "Expected cache deletion to fail with an error")
    }

    func test_delete_hasNoSideEffectsOnDeletionError() {
//        let noDeletePermissionsUrl = cachesDirectory()
//        let sut = makeSUT(url: noDeletePermissionsUrl)
//
//        deleteCache(from: sut)
//
//        expect(sut, toRetrieve: .empty)
    }

    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        var completedOperationsInOrder = [XCTestExpectation]()

        let op1 = expectation(description: "Operation 1")
        sut.insert(uniqueImageFeed().local, currentDate: Date()) { _ in
            completedOperationsInOrder.append(op1)
            op1.fulfill()
        }

        let op2 = expectation(description: "Operation 2")
        sut.deleteCachedFeed { _ in
            completedOperationsInOrder.append(op2)
            op2.fulfill()
        }

        let op3 = expectation(description: "Operation 3")
        sut.insert(uniqueImageFeed().local, currentDate: Date()) { _ in
            completedOperationsInOrder.append(op3)
            op3.fulfill()
        }

        wait(for: [op1, op2, op3], timeout: 1.0)
        XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected side-effects to run serially but operations finished in wrong order.")
    }

    // MARK: - Helpers

    private func makeSUT(url: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let store = CodeableFeedStore(storeURL: url ?? testSpecificStoreURL())
        trackForMemoryLeak(store, file: file, line: line)

        return store
    }

    private func testSpecificStoreURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }

    private func cachesDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }

    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }

    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }

    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
