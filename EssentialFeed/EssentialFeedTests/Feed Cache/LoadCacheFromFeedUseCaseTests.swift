import XCTest
import EssentialFeed

final class LoadCacheFromFeedUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()

        sut.load { _ in }

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let exp = XCTestExpectation(description: "Wait for load completion")
        let expectedError = anyNSError()

        var receivedError: Error?
        sut.load { result in
            switch result {
            case let .success(images):
                XCTFail("Expected failure but succeeded with images: \(images)")
            case let .failure(error):
                receivedError = error
            }
            exp.fulfill()
        }
        store.completeRetrieval(with: expectedError)

        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, expectedError)
    }

    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut, store) = makeSUT()
        let exp = XCTestExpectation(description: "Wait for load completion")

        var receivedImages: [FeedImage]?
        sut.load { result in
            switch result {
            case let .success(images):
                receivedImages = images
            case let .failure(error):
                XCTFail("Expected success but failed with error: \(error)")
            }
            exp.fulfill()
        }
        store.completeRetrievalSuccessfully()

        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedImages, [])
    }

    // MARK: - Helpers

    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (LocalFeedLoader, FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)

        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(store, file: file, line: line)

        return (sut, store)
    }

    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
}
