public protocol HTTPClient {
    func get(from url: URL, _ completion: @escaping (HTTPClientResult) -> Void)
}

public typealias HTTPClientResult = Result<(Data, HTTPURLResponse), Error>
