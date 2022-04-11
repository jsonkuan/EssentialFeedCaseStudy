import UIKit

final class FeedRefreshController: NSObject {
    private let viewModel: FeedViewModel

    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }

    private(set) lazy var view = bind(UIRefreshControl())

    @objc
    func refresh() {
        viewModel.loadFeed()
    }

    private func bind(_ view: UIRefreshControl) -> UIRefreshControl {
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            if isLoading {
                self?.view.beginRefreshing()
            } else {
                self?.view.endRefreshing()
            }
        }

        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}