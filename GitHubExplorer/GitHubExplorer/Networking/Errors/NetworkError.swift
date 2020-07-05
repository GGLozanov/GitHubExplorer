//
//  NetworkError.swift
//  GitHubExplorer
//
//  Created by ts51 on 4.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case cocoaNetworking(NSError)
    case noResponse
    case noData
    case badStatusCode(Int)
}
