import EssentialFeed

public enum FeedUIComposer {
    public static func composeFeedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let viewModel = FeedViewModel(loader: feedLoader)
        let refreshController = FeedRefreshController(viewModel: viewModel)
        let feedController = FeedViewController(refreshController: refreshController)
        viewModel.onFeedLoad = adaptFeedToCellControllers(forwardingTo: feedController, loader: imageLoader)

        return feedController
    }

    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                let viewModel = FeedImageCellViewModel(model: model, loader: loader)
                return FeedImageCellController(viewModel: viewModel)
            }
        }
    }
}
