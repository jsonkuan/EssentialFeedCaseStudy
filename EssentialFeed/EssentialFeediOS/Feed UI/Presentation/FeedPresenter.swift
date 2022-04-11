import EssentialFeed

struct FeedLoadingViewModel {
    let isLoading: Bool
}
protocol FeedLoadingView {
    func display(viewModel: FeedLoadingViewModel)
}

struct FeedViewViewModel {
    let feed: [FeedImage]
}

protocol FeedView {
    func display(viewModel: FeedViewViewModel)
}

final class FeedPresenter {
    typealias Observer<T> = (T) -> Void

    private let loader: FeedLoader

    var loadingView: FeedLoadingView?
    var feedView: FeedView?

    init(loader: FeedLoader) {
        self.loader = loader
    }

    func loadFeed() {
        loadingView?.display(viewModel: FeedLoadingViewModel(isLoading: true))

        loader.load() { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(viewModel: FeedViewViewModel(feed: feed))
            }

            self?.loadingView?.display(viewModel: FeedLoadingViewModel(isLoading: false))
        }
    }
}
