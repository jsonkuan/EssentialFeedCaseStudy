import Foundation

public struct FeedItem: Equatable {
    public let id: String
    public let description: String? = nil
    public let location: String? = nil
    public let imageUrl: URL
}
