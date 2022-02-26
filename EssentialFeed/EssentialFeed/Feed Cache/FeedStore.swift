public protocol FeedStore {
    typealias ErrorCompletion = (Error?) -> Void
    
    func deleteCachedFeed(_ completion: @escaping ErrorCompletion)
    func insert(_ items: [LocalFeedItem], currentDate: Date, completion: @escaping ErrorCompletion)
}

public struct LocalFeedItem: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageUrl: URL

    public init(id: UUID, description: String?, location: String?, imageUrl: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageUrl = imageUrl
    }
}
