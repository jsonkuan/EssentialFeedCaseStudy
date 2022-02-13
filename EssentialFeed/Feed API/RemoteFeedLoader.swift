import Foundation

public protocol HTTPClient {
    func get(from url: URL, _ completion: @escaping (Error?, HTTPURLResponse?) -> Void)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public func load(_ completion: @escaping (Error) -> Void) {
        client.get(from: url) { _, response in
            if response == nil {
                completion(.connectivity)
            } else {
                completion(.invalidData)
            }
        }
    }
}
