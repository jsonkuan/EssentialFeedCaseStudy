internal class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }

    internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == 200,
                let root = try? JSONDecoder().decode(Root.self, from: data) else {
                     throw RemoteFeedLoader.Error.invalidData
        }

        return root.items
    }
}

internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}
