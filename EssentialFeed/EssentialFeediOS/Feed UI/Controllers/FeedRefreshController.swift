import UIKit
import EssentialFeed

final class FeedRefreshController: NSObject {
    private (set) lazy var view: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)

        return refreshControl
    }()

    private let loader: FeedLoader

    var onRefresh: ( ([FeedImage]) -> Void)?

    init(loader: FeedLoader) {
        self.loader = loader
    }

    @objc
    func refresh() {
        view.beginRefreshing()

        loader.load() { [weak self] result in
            if let feed = try? result.get() {
                self?.onRefresh?(feed)
            }

            self?.view.endRefreshing()
        }
    }
}
