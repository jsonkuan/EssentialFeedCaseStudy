import EssentialFeed

final class FeedImageCellViewModel<Image> {
    typealias Observer<T> = (T) -> Void
    typealias ImageTransformer = (Data) -> Image?
    
    private let loader: FeedImageDataLoader
    private let model: FeedImage
    private var task: FeedImageDataTask?
    private let imageTransformer: ImageTransformer
    
    var onImageLoad: Observer<Image>?
    var onImageLoadingStateChanged: Observer<Bool>?
    var onShouldRetryImageLoadStateChanged: Observer<Bool>?
    
    init(model: FeedImage, loader: FeedImageDataLoader, imageTransformer: @escaping ImageTransformer) {
        self.model = model
        self.loader = loader
        self.imageTransformer = imageTransformer
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
        
        if let image = (try? result.get()).flatMap(imageTransformer) {
            onImageLoad?(image)
        } else {
            onShouldRetryImageLoadStateChanged?(true)
        }
        onImageLoadingStateChanged?(false)
    }
}
