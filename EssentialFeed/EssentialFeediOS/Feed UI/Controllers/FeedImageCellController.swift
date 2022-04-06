import UIKit
import EssentialFeed

final class FeedImageCellController {
    private let loader: FeedImageDataLoader
    private let model: FeedImage
    private var task: FeedImageDataTask?

    init(model: FeedImage, loader: FeedImageDataLoader) {
        self.model = model
        self.loader = loader
    }

    func view() -> UITableViewCell {
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = (model.location == nil)
        cell.locationLabel.text = model.location
        cell.descriptionLabel.text = model.description
        cell.feedImageView.image = nil
        cell.feedImageRetryButton.isHidden = true
        cell.feedImageContainer.startShimmering()

        let loadImage = { [weak self, weak cell] in
            guard let self = self else { return }

            self.task = self.loader.loadImageData(from: self.model.url) { [weak cell] result in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.feedImageView.image = image
                cell?.feedImageRetryButton.isHidden = (image != nil)
                cell?.feedImageContainer.stopShimmering()
            }
        }

        cell.onRetry = loadImage
        loadImage()

        return cell
    }

    func preload() {
        task = loader.loadImageData(from: model.url, completion: { _ in })
    }

    func cancelLoad() {
        task?.cancel()
    }
}
