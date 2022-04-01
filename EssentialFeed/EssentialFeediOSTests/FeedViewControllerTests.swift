import XCTest

class FeedViewController {

    convenience init(loader: FeedViewControllerTests.LoaderSpy) {
        self.init()
    }
}

final class FeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)

        XCTAssertEqual(loader.loadCallCount, 0)
    }

    // MARK: - Helpers

    struct LoaderSpy {
        private (set) var loadCallCount = 0

    }
}
