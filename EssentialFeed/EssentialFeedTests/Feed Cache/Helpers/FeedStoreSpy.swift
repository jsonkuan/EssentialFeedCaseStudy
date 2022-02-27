import EssentialFeed

final class FeedStoreSpy: FeedStore {
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert([LocalFeedImage], Date)
        case retrieve
    }

    private(set) var receivedMessages = [ReceivedMessage]()

    private var deletionCompletions = [ErrorCompletion]()
    private var insertionCompletions = [ErrorCompletion]()
    private var retrievalCompletions = [RetrievalCompletion]()

    // MARK: - Delete

    func deleteCachedFeed(_ completion: @escaping ErrorCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }

    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }

    func completeDeletionSuccessfully(at index: Int = 0) {
         deletionCompletions[index](nil)
    }

    // MARK: - Insert

    func insert(_ images: [LocalFeedImage], currentDate: Date, completion: @escaping ErrorCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(images, currentDate))
    }

    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](error)
    }

    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](nil)
    }

    // MARK: - Load

    func retrieve(_ completion: @escaping RetrievalCompletion) {
        retrievalCompletions.append(completion)
        receivedMessages.append(.retrieve)
    }

    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }

    func completeRetrievalSuccessfully(at index: Int = 0) {
        retrievalCompletions[index](.success([]))
    }
}
