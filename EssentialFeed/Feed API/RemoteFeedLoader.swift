import Foundation

protocol HTTPClient {
    func get(from url: URL)
}

final class RemoteFeedLoader {
    let url: URL
    let client: HTTPClient

    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    func load() {
        client.get(from: url)
    }
}
