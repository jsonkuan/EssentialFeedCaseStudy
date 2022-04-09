import UIKit
import EssentialFeed

final class FeedImageCellController {
    let viewModel: FeedImageCellViewModel
    
    init(viewModel: FeedImageCellViewModel) {
        self.viewModel = viewModel
    }
    
    func view() -> UITableViewCell {
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = viewModel.isLocationVisible
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.text = viewModel.description
        cell.feedImageView.image = nil
        cell.feedImageRetryButton.isHidden = true
        cell.feedImageContainer.startShimmering()

        let loadImage = { [weak self, weak cell] in
            guard let self = self else { return }

            self.viewModel.task = self.viewModel.loader.loadImageData(from: self.viewModel.url) { [weak cell] result in
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
        viewModel.task = viewModel.loader.loadImageData(from: viewModel.url, completion: { _ in })
    }

    func cancelLoad() {
        viewModel.task?.cancel()
    }
}
