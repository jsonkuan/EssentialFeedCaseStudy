import EssentialFeed

final class FeedViewModel {
    typealias Observer<T> = (T) -> Void

    private let loader: FeedLoader

    var onLoadingStateChanged: Observer<Bool>?
    var onFeedLoad: Observer<[FeedImage]>?

    init(loader: FeedLoader) {
        self.loader = loader
    }

    func loadFeed() {
        onLoadingStateChanged?(true)

        loader.load() { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }

            self?.onLoadingStateChanged?(false)
        }
    }
}
