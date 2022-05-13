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
    private let view: View

    init(view: View) {
        self.view = view
    }

    func didStartLoadingImageData(for model: FeedImage) {
        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: true,
            shouldRetry: false))
    }
}

final class FeedImagePresenterTests: XCTestCase {
    func test_init_doesNotSendMessagesToView() {
        let view = ViewSpy()
        _ = FeedImagePresenter(view: view)
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoadingImageData_displaysLoadingViewModel() {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)
        let feedImage = uniqueFeedImage()
        
        sut.didStartLoadingImageData(for: feedImage)
        
        XCTAssertEqual(view.messages, [.display(.loadingViewModel(feedImage: feedImage))])
    }
    
    // MARK: -  Helpers

    private class ViewSpy: FeedImageView {
        typealias Image = FeedImage
        
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
}
