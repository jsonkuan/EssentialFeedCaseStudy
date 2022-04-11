import EssentialFeed

protocol FeedLoadingView {
    func display(isLoading: Bool)
}

protocol FeedView {
    func display(feed: [FeedImage])
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
        loadingView?.display(isLoading: true)

        loader.load() { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(feed: feed)
            }

            self?.loadingView?.display(isLoading: false)
        }
    }
}
