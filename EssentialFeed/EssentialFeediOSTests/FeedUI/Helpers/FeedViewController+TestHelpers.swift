import UIKit
import EssentialFeediOS

extension FeedViewController {
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
        let indexPath = IndexPath(row: index, section: feedImagesSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: indexPath)
    }

    func simulateFeedImageViewNearVisible(at row: Int) {
        let datasource = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        datasource?.tableView(tableView, prefetchRowsAt: [index])
    }

    func simulateFeedImageViewNotNearVisible(at row: Int) {
        simulateImageFeedViewVisible(at: row)

        let datasource = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        datasource?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
}
