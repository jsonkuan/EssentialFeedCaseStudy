import CoreData

final class CoreDataFeedStore: FeedStore {
    func deleteCachedFeed(_ completion: @escaping DeletionCompletion) {
    }

    func insert(_ feed: [LocalFeedImage], currentDate: Date, completion: @escaping InsertionCompletion) {
    }

    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
}

private class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
}

private class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache
}
