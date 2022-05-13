import XCTest

final class FeedPresenter {
    init(view: Any) {
    }
}

final class FeedPresenterTests: XCTestCase {
    func test_init_doesNotSendMessageToView() {
        let view = ViewSpy()
        
        _ = FeedPresenter(view: view)
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    private class ViewSpy {
        let messages = [Any]()
    }
}
