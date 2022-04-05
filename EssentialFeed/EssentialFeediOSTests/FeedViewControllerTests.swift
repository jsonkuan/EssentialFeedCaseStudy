import XCTest
import EssentialFeed
import EssentialFeediOS

final class FeedViewControllerTests: XCTestCase {
    func test_loadFeedActions_requestsFeedFromLoader() {
        let (loader, sut) = makeSUT()

        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading request before view is loaded")

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected load request once view loaded")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected load request when user initiates a feed reload")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 3, "Expected load request when use initiates a second reload")
    }

    func test_loadingIndicator_isVisibleWhenFeedIsLoading() {
        let (loader, sut) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator to be VISIBLE, when view is loading")

        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected loading indicator to be HIDDEN, when feed has loaded successfuly")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator to be VISIBLE, when user initiates a feed reload")

        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected loading indicator to be HIDDEN, when user initiated reload completes with failure")
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

    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = feedImage(description: "A description", location: "A location")
        let (loader, sut) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0], at: 0)
        assert(sut, isRendering: [image0])

        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assert(sut, isRendering: [image0])
    }

    func test_feedImageView_loadsImageUrlWhenVisible() {
        let image0 = feedImage(url: URL(string: "https://url-0.com")!)
        let image1 = feedImage(url: URL(string: "https://url-1.com")!)
        let (loader, sut) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1])

        XCTAssertEqual(loader.loadedImageURLs, [], "Expected urls to be empty before view is visible")

        sut.simulateImageFeedViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected first image URLRequest, once view is visibile")

        sut.simulateImageFeedViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected second image URLRequest, once second view is visibile")
    }

    func test_feedImageView_cancelsImageLoadingWhenNotVisibleAnymore() {
        let image0 = feedImage(url: URL(string: "https://url-0.com")!)
        let image1 = feedImage(url: URL(string: "https://url-1.com")!)
        let (loader, sut) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1])

        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image urls until image is no longer visible")

        sut.simulateImageFeedViewIsHidden(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected one cancelled image URLRequest, once first image is no longer visibile")

        sut.simulateImageFeedViewIsHidden(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url], "Expected two cancelled image URLRequest, once second image is no longer visibile")
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (LoaderSpy, FeedViewController) {
        let loader = LoaderSpy()
        let sut = FeedViewController(feedLoader: loader, imageLoader: loader)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(loader, file: file, line: line)

        return (loader, sut)
    }

    private func feedImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "https://a-url.com")!) -> FeedImage {
        FeedImage(id: UUID(), description: description, location: location, url: url)
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

    final class LoaderSpy: FeedLoader, FeedImageDataLoader {

        // MARK: - FeedLoader

        var loadFeedCallCount: Int {
            feedRequests.count
        }

        private var feedRequests = [(FeedLoader.Result) -> Void]()

        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            feedRequests.append(completion)
        }

        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            feedRequests[index](.success(feed))
        }

        func completeFeedLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "test", code: 0)
            feedRequests[index](.failure(error))
        }

        // MARK: - FeedImageDataLoader

        private(set) var loadedImageURLs = [URL]()
        private(set) var cancelledImageURLs = [URL]()

        private struct TaskSpy: FeedImageDataTask {
            let cancelCallBack: () -> Void

            func cancel() {
                cancelCallBack()
            }
        }

        func loadImageData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> FeedImageDataTask {
            loadedImageURLs.append(url)
            return TaskSpy { [weak self] in self?.cancelledImageURLs.append(url) }
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

    @discardableResult
    func simulateImageFeedViewVisible(at index: Int) -> FeedImageCell? {
        feedImageView(at: index) as? FeedImageCell
    }

    func simulateImageFeedViewIsHidden(at index: Int) {
        let view = feedImageView(at: index)

        let delegate = tableView.delegate
        let indexPath = IndexPath(row: index, section: 0)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: indexPath)
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
