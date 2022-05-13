public protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

public protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

public protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

public struct FeedViewModel {
    public let feed: [FeedImage]
}

public struct FeedLoadingViewModel {
    public let isLoading: Bool
}

public struct FeedErrorViewModel {
    public let message: String?
    
    static var noError: Self {
        FeedErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> Self {
        FeedErrorViewModel(message: message)
    }
}

public final class FeedPresenter {
    private let feedView: FeedView
    private let errorView: FeedErrorView
    private let loadingView: FeedLoadingView

    public init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    public static var title: String {
        NSLocalizedString(
            "FEED_TITLE_KEY",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Title for navigation"
        )
    }
    
    private var feedLoadError: String {
        NSLocalizedString(
            "FEED_VIEW_CONNECTION_ERROR",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Error message displayed when we can't load the image feed from server")
    }
    
    public func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with error: Error) {
        errorView.display(.error(message: feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
