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
    var loadingView: FeedLoadingView?
    var feedView: FeedView?

    func didStartLoadingFeed() {
        loadingView?.display(viewModel: FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView?.display(viewModel: FeedViewViewModel(feed: feed))
        loadingView?.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        loadingView?.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
}
