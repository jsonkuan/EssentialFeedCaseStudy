public protocol FeedStore {
    typealias ErrorCompletion = (Error?) -> Void
    
    func deleteCachedFeed(_ completion: @escaping ErrorCompletion)
    func insert(_ items: [LocalFeedItem], currentDate: Date, completion: @escaping ErrorCompletion)
}
