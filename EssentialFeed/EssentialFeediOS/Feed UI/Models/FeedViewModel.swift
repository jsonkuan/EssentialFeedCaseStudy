import EssentialFeed

final class FeedViewModel {
    private let loader: FeedLoader

    var onChange: ((FeedViewModel) -> Void)?
    var onFeedLoad: (([FeedImage]) -> Void)?

    init(loader: FeedLoader) {
        self.loader = loader
    }

    private(set) var isLoading: Bool = false {
        didSet {
            onChange?(self)
        }
    }

    func loadFeed() {
        isLoading = true

        loader.load() { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }

            self?.isLoading = false
        }
    }
}
