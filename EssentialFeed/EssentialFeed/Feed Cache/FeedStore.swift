public typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
    typealias InsertionResult = (Error?) -> Void
    typealias InsertionCompletion = (InsertionResult) -> Void

    typealias DeletionResult = (Error?) -> Void
    typealias DeletionCompletion = (DeletionResult) -> Void

    typealias RetrievalResult = Result<CachedFeed?, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void

    func deleteCachedFeed(_ completion: @escaping DeletionCompletion)
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
