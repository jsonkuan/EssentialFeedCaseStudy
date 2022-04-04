import XCTest
import EssentialFeed
import EssentialFeediOS

final class FeedViewControllerTests: XCTestCase {
    func test_loadFeedActions_requestsFeedFromLoader() {
        let (loader, sut) = makeSUT()

        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading request before view is loaded")

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected load request once view loaded")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected load request when user initiates a feed reload")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected load request when use initiates a second reload")
    }

    func test_loadingIndicator_isVisibleWhenFeedIsLoading() {
        let (loader, sut) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator to be VISIBLE, when view is loading")

        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected loading indicator to be HIDDEN, when feed has loaded")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator to be VISIBLE, when user initiates a feed reload")

        loader.completeFeedLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected loading indicator to be HIDDEN, when reload completes")
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = feedImage(description: "A description", location: "A location")
        let image1 = feedImage(description: nil, location: "A location")
        let image2 = feedImage(description: "A description", location: nil)
        let image3 = feedImage(description: nil, location: nil)
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        assert(sut, isRendering: [])
        
        loader.completeFeedLoading(with: [image0])
        assert(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: [image0, image1, image2, image3])
        assert(sut, isRendering: [image0, image1, image2, image3])
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (LoaderSpy, FeedViewController) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(loader, file: file, line: line)

        return (loader, sut)
    }
    
    private func feedImage(description: String?, location: String?) -> FeedImage {
        FeedImage(id: UUID(), description: description, location: location, url: URL(string: "https://a-url.com")!)
    }
    
    private func assert(_ sut: FeedViewController, hasConfiguredView image: FeedImage, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.feedImageView(at: index)
        
        guard let cell = view as? FeedImageCell else {
            return XCTFail("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        let shouldBeVisible = image.location != nil
        XCTAssertEqual(cell.isShowingLocation, shouldBeVisible, file: file, line: line)
        XCTAssertEqual(cell.locationText, image.location, file: file, line: line)
        XCTAssertEqual(cell.descriptionText, image.description, file: file, line: line)
    }
    
    private func assert(_ sut: FeedViewController, isRendering imageFeed: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        guard sut.numberOfRenderedFeedImageViews() == imageFeed.count else {
            return XCTFail("Expected \(imageFeed.count) image, got \(sut.numberOfRenderedFeedImageViews()) instead", file: file, line: line)
        }
        
        imageFeed.enumerated().forEach { index, image in
            assert(sut, hasConfiguredView: image, at: index, file: file, line: line)
        }
    }

    final class LoaderSpy: FeedLoader {
        var loadCallCount: Int {
            completions.count
        }

        private var completions = [(FeedLoader.Result) -> Void]()

        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }

        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            completions[index](.success(feed))
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
    
    func numberOfRenderedFeedImageViews() -> Int {
        tableView(self.tableView, numberOfRowsInSection: feedImagesSection)
    }
    
    var feedImagesSection: Int { 0  }
    
    func feedImageView(at index: Int) -> UITableViewCell? {
        let dataSource = tableView.dataSource
        let indexPath = IndexPath(row: index, section: 0)
        return dataSource?.tableView(tableView, cellForRowAt: indexPath)
    }
}

private extension FeedImageCell {
    var isShowingLocation: Bool {
        !locationContainer.isHidden
    }
    
    var descriptionText: String? {
        descriptionLabel.text
    }
    
    var locationText: String? {
        locationLabel.text
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
