internal class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [Item]

        var feed: [FeedItem] {
            return items.map { $0.item }
        }
    }

    private struct Item: Decodable {
        public let id: UUID
        public let description: String?
        public let location: String?
        public let image: URL

        var item: FeedItem {
            FeedItem(id: id, description: description, location: location, imageUrl: image)
        }
    }

    internal static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == 200,
                let root = try? JSONDecoder().decode(Root.self, from: data) else {
                    return .failure(RemoteFeedLoader.Error.invalidData)
        }

        return .success(root.feed)
    }
}
