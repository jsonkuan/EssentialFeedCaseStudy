import UIKit
import EssentialFeed

final class FeedImageCellViewModel {
    let loader: FeedImageDataLoader
    private let model: FeedImage
    var task: FeedImageDataTask?
    
    init(model: FeedImage, loader: FeedImageDataLoader) {
        self.model = model
        self.loader = loader
    }
    
    var isLocationVisible: Bool {
        (model.location == nil)
    }
    
    var location: String? {
        model.location
    }
    
    var description: String? {
        model.description
    }
    
    var url: URL {
        model.url
    }
}
