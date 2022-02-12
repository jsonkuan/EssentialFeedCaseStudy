import Foundation

struct FeedItem: Equatable {
    let id: String
    let description: String? = nil
    let location: String? = nil
    let imageUrl: URL
}
