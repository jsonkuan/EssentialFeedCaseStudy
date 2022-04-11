import UIKit
import EssentialFeed

final class FeedImageCellViewModel {
    typealias Observer<T> = (T) -> Void
    
    private let loader: FeedImageDataLoader
    private let model: FeedImage
    private var task: FeedImageDataTask?
    
    var onImageLoad: Observer<UIImage>?
    var onImageLoadingStateChanged: Observer<Bool>?
    var onShouldRetryImageLoadStateChanged: Observer<Bool>?
    
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
    
    func loadImageData() {
        onImageLoadingStateChanged?(true)
        onShouldRetryImageLoadStateChanged?(false)
        
        task = loader.loadImageData(from: url) { [weak self] result in
            self?.handle(result)
        }
    }
    
    func cancelImageDataLoad() {
        task?.cancel()
        task = nil
    }
    
    private func handle(_ result: FeedImageDataLoader.Result) {
        
        if let image = (try? result.get()).flatMap(UIImage.init) {
            onImageLoad?(image)
        } else {
            onShouldRetryImageLoadStateChanged?(true)
        }
        onImageLoadingStateChanged?(false)
    }
}
