public protocol FeedStore {
    typealias ErrorCompletion = (Error?) -> Void

    func deleteCachedFeed(_ completion: @escaping ErrorCompletion)
    func insert(_ feed: [LocalFeedImage], currentDate: Date, completion: @escaping ErrorCompletion)
    func retrieve(_ completion: @escaping ErrorCompletion)
}
