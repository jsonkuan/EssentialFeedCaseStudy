import XCTest
import EssentialFeed

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool

    var hasLocation: Bool {
        return location != nil
    }
}

extension FeedImageViewModel: Equatable {
    static func == (lhs: FeedImageViewModel<Image>, rhs: FeedImageViewModel<Image>) -> Bool {
        lhs.description == rhs.description &&
        lhs.location == rhs.location &&
        lhs.isLoading == rhs.isLoading &&
        lhs.shouldRetry == rhs.shouldRetry
    }
}

protocol FeedImageView {
    associatedtype Image

    func display(_ model: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private struct InvalidImageDataError: Error {}
    private let view: View
    private let imageTransformer: (Data) -> Image?

    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }

    func didStartLoadingImageData(for model: FeedImage) {
        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: true,
            shouldRetry: false))
    }
    
    func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: false,
            shouldRetry: true))
    }
    
    func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        guard let image = imageTransformer(data) else {
            return didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
        }

        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: image,
            isLoading: false,
            shouldRetry: false))
    }
}

final class FeedImagePresenterTests: XCTestCase {
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoadingImageData_displaysLoadingViewModel() {
        let (sut, view) = makeSUT()
        let feedImage = uniqueFeedImage()
        
        sut.didStartLoadingImageData(for: feedImage)
        
        XCTAssertEqual(view.messages, [.display(.loadingViewModel(feedImage: feedImage))])
    }
    
    func test_didFinishLoadingImageDataWithError_displaysErrorViewModel() {
        let (sut, view) = makeSUT()
        let error = anyNSError()
        let image = uniqueFeedImage()
        
        sut.didFinishLoadingImageData(with: error, for: image)
        
        XCTAssertEqual(view.messages, [.display(.errorViewModel(feedImage: image))])
    }
    
    func test_didFinishLoadingImageData_displaysErrorViewModelWithFailedImageTransformation() {
        let (sut, view) = makeSUT()
        let image = uniqueFeedImage()
        let imageStub = NSImage.make()
        let data = imageStub.tiffRepresentation!
    
        sut.didFinishLoadingImageData(with: data, for: image)
        
        XCTAssertEqual(view.messages, [
            .display(.errorViewModel(feedImage: image))
        ])
    }
    
    // MARK: -  Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (FeedImagePresenter<ViewSpy, NSImage>, ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(
            view: view,
            imageTransformer: NSImage.init(data:)
        )
        
        trackForMemoryLeak(view)
        trackForMemoryLeak(sut)
        
        return (sut, view)
    }
    
    private class ViewSpy: FeedImageView {
        typealias Image = NSImage
        
        enum Messages: Equatable {
            case display(_ viewModel: FeedImageViewModel<Image>)
        }
        
        private(set) var messages = [Messages]()
        
        func display(_ model: FeedImageViewModel<Image>) {
            messages.append(.display(model))
        }
    }
}

private extension FeedImageViewModel {
    static func loadingViewModel(feedImage: FeedImage) -> FeedImageViewModel {
        FeedImageViewModel(
            description: feedImage.description,
            location: feedImage.location,
            image: nil,
            isLoading: true,
            shouldRetry: false
        )
    }
    
    static func errorViewModel(feedImage: FeedImage) -> FeedImageViewModel {
        FeedImageViewModel(
            description: feedImage.description,
            location: feedImage.location,
            image: nil,
            isLoading: false,
            shouldRetry: true
        )
    }
    
    static func successViewModel(data: Data, feedImage: FeedImage) -> FeedImageViewModel {
        FeedImageViewModel(
            description: feedImage.description,
            location: feedImage.location,
            image: NSImage.init(data: data) as? Image,
            isLoading: false,
            shouldRetry: false
        )
    }
}

extension NSImage {
    static func make() -> NSImage {
        NSImage(size: NSSize(width: 1, height: 1))
    }
}
