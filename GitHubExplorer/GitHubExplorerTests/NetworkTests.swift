//
//  GitHubExplorerTests.swift
//  GitHubExplorerTests
//
//  Created by ts51 on 1.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import XCTest
import UIKit
@testable import GitHubExplorer

class NetworkTest: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCallSuccess() {
        let session = NetworkProviderMock(data: "Success".data(using: .utf8), response: HTTPURLResponse(), error: nil)
        
        let network: Network = Network(session: session)

        network.call(request: URLRequest(url: URL(string: "https://github.com")!)) { result in
            switch result {
            case .success(let (data, response)):
                XCTAssertEqual(data, session.data, "Data equals initial data")
                XCTAssertEqual(response, session.response, "Response equals initial response")
            case .failure:
                XCTFail()
            }
        }
        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testCallCocoaError() {
        let session = NetworkProviderMock(data: "Fail".data(using: .utf8), response: nil, error: Network.NetworkError.cocoaNetworking(Network.NetworkError.noResponse as NSError))
          
          let network: Network = Network(session: session)
          
          network.call(request: URLRequest(url: URL(string: "https://github.com")!)) { result in
              switch result {
              case .success:
                  XCTFail()
              case .failure(let error):
                // FIXME: Assert types of session.error! and error
                XCTAssert(error is Network.NetworkError && session.error! is Network.NetworkError)
              }
          }
    }

    func testCallNoResponse() {
        let session = NetworkProviderMock(data: "Fail".data(using: .utf8), response: nil, error: nil)
        
        let network: Network = Network(session: session)
        
        network.call(request: URLRequest(url: URL(string: "https://github.com")!)) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, Network.NetworkError.noResponse, "Errors are equal")
            }
        }
    }
    
    func testCallBadStatusCode() {
        let session = NetworkProviderMock(data: nil, response: HTTPURLResponse(url: URL(string: "https://github.com")!, statusCode: 832, httpVersion: nil, headerFields: nil), error: nil)
            // invalid response
              
        let network: Network = Network(session: session)
        
        network.call(request: URLRequest(url: URL(string: "https://github.com")!)) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, Network.NetworkError.badStatusCode(832), "Errors are equal")
            }
        }
    }
    
    func testCallNoData() {
        let session = NetworkProviderMock(data: nil, response: HTTPURLResponse(), error: nil)
              
        let network: Network = Network(session: session)
        
        network.call(request: URLRequest(url: URL(string: "https://github.com")!)) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, Network.NetworkError.noData, "Errors are equal")
            }
        }
    }

}
