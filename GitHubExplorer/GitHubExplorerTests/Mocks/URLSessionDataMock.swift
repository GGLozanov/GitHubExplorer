//
//  URLSessionDataMock.swift
//  GitHubExplorerTests
//
//  Created by ts51 on 9.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import UIKit

public class URLSessionDataMock: URLSessionDataTask {
    private let closure: () -> Void

    public init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    
    override public func resume() {
        self.closure()
    }
}
