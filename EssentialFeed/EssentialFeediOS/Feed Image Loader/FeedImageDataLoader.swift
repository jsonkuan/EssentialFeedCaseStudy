import Foundation

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>

    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataTask
}

public protocol FeedImageDataTask {
    func cancel()
}
