import Foundation

final class CoreDataFeedStore: FeedStore {
    func deleteCachedFeed(_ completion: @escaping DeletionCompletion) {
    }

    func insert(_ feed: [LocalFeedImage], currentDate: Date, completion: @escaping InsertionCompletion) {
    }

    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
}
