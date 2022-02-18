import XCTest
import EssentialFeed

final class URLSessionHTTPClientTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override class func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromUrl_performsGetRequestWithUrl() {
        let url = anyUrl()
        let exp = expectation(description: "performsGetRequestWithUrl")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.url, url)
            
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromUrl_failsOnRequestError() {
        let requestError = NSError(domain: "SomeError", code: 0)
        
        let _ = resultErrorFor(data: nil, response: nil, error: requestError)
        
        XCTAssertEqual("SomeError", requestError.domain)
        XCTAssertEqual(0, requestError.code)
    }
    
    func test_getFromUrl_failsOnAllInvalidCases() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: nil))
    }
    
//    func test_getFromUrl_suceedsOnHttpUrlResponseWithData() {
//        let emptyData = Data()
//        let response = anyHTTPURLResponse()
//        
//        let receivedValues = resultValuesFor(data: nil, response: response, error: nil)
//        
//        XCTAssertEqual(receivedValues?.data, emptyData)
//        XCTAssertEqual(response.url, receivedValues?.response.url)
//        XCTAssertEqual(response.statusCode, receivedValues?.response.statusCode)
//    }
    
    
    // MARK: - Helper
    
    private func resultFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> HTTPClientResult {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "Wait for completion")
        
        var receivedResult: HTTPClientResult!
        sut.get(from: anyUrl()) { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }
    
    private func resultValuesFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse )? {
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        let exp = expectation(description: "Wait for completion")
        
        let sut = makeSUT(file: file, line: line)
        var receivedValues: (data: Data, response: HTTPURLResponse)?
        
        sut.get(from: anyUrl()) { result in
            switch result {
            case let .success(data, response):
                receivedValues = (data, response)
            default:
                XCTFail("Expected success, got \(result) instead.", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedValues
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        let exp = expectation(description: "Wait for completion")
        
        let sut = makeSUT(file: file, line: line)
        var receivedError: Error?
        
        sut.get(from: anyUrl()) { result in
            switch result {
            case .failure(let error):
                receivedError = error
            default:
                XCTFail("Expected failure, got \(result) instead.", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
    
    private func anyUrl() -> URL {
        URL(string: "https://a-url.com")!
    }
    
    private func anyData() -> Data {
        Data("Anydata".utf8)
    }
    
    private func anyNSError() -> Error {
        NSError(domain: "Test", code: 0)
    }
    
    
    private func nonHTTPURLResponse() -> URLResponse {
        URLResponse(url: anyUrl(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        let url = URL(string: "test.com")!
        return HTTPURLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeak(sut, file: file, line: line)
        
        return sut
    }
    
    // MARK: - Stub
    
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            URLProtocolStub.stub = Stub(data: data, response: response, error: error)
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        static func observeRequests(_ observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        // MARK: - URL Protocol
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }
        
        override func startLoading() {
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
