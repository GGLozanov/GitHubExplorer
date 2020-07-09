//
//  EndpointMock.swift
//  GitHubExplorerTests
//
//  Created by ts38 on 9.07.20.
//  Copyright © 2020 example. All rights reserved.
//

@testable import GitHubExplorer
import Foundation

protocol EndpointMockProtocol {
    associatedtype Model: Decodable
}

extension EndpointMockProtocol{
    var request: URLRequest {
        return URLRequest(url: URL(string: "https://github.com")!)
    }
}

struct EndpointMock: EndpointMockProtocol{
    typealias Model = User
}
