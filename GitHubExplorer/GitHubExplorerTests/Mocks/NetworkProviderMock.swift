//
//  URLSessionMock.swift
//  GitHubExplorerTests
//
//  Created by ts51 on 9.07.20.
//  Copyright © 2020 example. All rights reserved.
//

@testable import GitHubExplorer
import UIKit

public class NetworkProviderMock: NetworkProvider {
    let data: Data?
    let response: HTTPURLResponse?
    let error: Network.NetworkError?
    
    public init(data: Data?, response: HTTPURLResponse?, error: Network.NetworkError?) {
        self.data = data
        self.response = response
        self.error = error
    }
    
    public func dataTask(with url: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return URLSessionDataMock {
            completionHandler(self.data, self.response, self.error)
        } // empty response to satisfy protocol
    }
    
}

