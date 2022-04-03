import XCTest
import EssentialFeed

final class FeedViewController: UITableViewController {
    private var loader: FeedLoader?

    convenience init(loader: FeedLoader) {
        self.init()

        self.loader = loader
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)

        load()
    }

    @objc
    private func load() {
        refreshControl?.beginRefreshing()

        loader?.load() { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}

final class FeedViewControllerTests: XCTestCase {
    func test_init_doesNotLoadFeed() {
        let (loader, _) = makeSUT()

        XCTAssertEqual(loader.loadCallCount, 0)
    }

    func test_viewDidLoad_loadsFeed() {
        let (loader, sut) = makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertEqual(loader.loadCallCount, 1)
    }

    func test_userInitiatedFeedReload_reloadsFeed() {
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2)

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3)
    }

    func test_viewDidLoad_showsLoadingIndicator() {
        let (_, sut) = makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.isShowingLoadingIndicator, true)
    }

    func test_viewDidLoad_hidesLoadingIndicatorOnLoadCompletion() {
        let (loader, sut) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading()

        XCTAssertEqual(sut.isShowingLoadingIndicator, false)
    }

    func test_userInitiatedFeedReload_showsLoadingIndicator() {
        let (_, sut) = makeSUT()
        sut.loadViewIfNeeded()

        sut.simulateUserInitiatedFeedReload()

        XCTAssertEqual(sut.isShowingLoadingIndicator, true)
    }

    func test_userInitiatedFeedReload_hidesLoadingIndicatorOnLoadCompletion() {
        let (loader, sut) = makeSUT()

        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading()

        XCTAssertEqual(sut.isShowingLoadingIndicator, false)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (LoaderSpy, FeedViewController) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(loader, file: file, line: line)

        return (loader, sut)
    }

    final class LoaderSpy: FeedLoader {
        var loadCallCount: Int {
            completions.count
        }

        private var completions = [(FeedLoader.Result) -> Void]()

        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }

        func completeFeedLoading() {
            completions[0](.success([]))
        }
    }
}

private extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing ?? false
    }
}

extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
