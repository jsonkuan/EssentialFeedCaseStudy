import UIKit

final class FeedImageCellController {
    let viewModel: FeedImageCellViewModel
    
    init(viewModel: FeedImageCellViewModel) {
        self.viewModel = viewModel
    }
    
    func preload() {
        viewModel.loadImageData()
    }

    func cancelLoad() {
        viewModel.cancelImageDataLoad()
    }
    
    func view() -> UITableViewCell {
        let cell = binded(FeedImageCell())
        viewModel.loadImageData()
        return cell
    }
     
    private func binded(_ cell: FeedImageCell) -> FeedImageCell {
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = viewModel.isLocationVisible
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.text = viewModel.description
        cell.onRetry = viewModel.loadImageData
        
        viewModel.onImageLoad = { [weak cell] image in
            cell?.feedImageView.image = image
        }
        
        viewModel.onImageLoadingStateChanged = { [weak cell] isLoading in
            cell?.feedImageContainer.isShimmering = isLoading
        }
        
        viewModel.onShouldRetryImageLoadStateChanged = { [weak cell] shouldRetry in
            cell?.feedImageRetryButton.isHidden = !shouldRetry
        }
         
        return cell
    }
}
