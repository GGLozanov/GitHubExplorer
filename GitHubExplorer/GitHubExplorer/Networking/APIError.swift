//
//  APIError.swift
//  GitHubExplorer
//
//  Created by Dilchovski on 3.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import Foundation

enum APIError: Error { 
    case network
    case github
    case authentication
    
    // FIXME: Be more granular 
    static func error(from error: NetworkError) -> APIError {
        switch error {
        case .noData, .noResponse:
            return .network
        case .cocoaNetworking:
            return .network
        case .badStatusCode(let code):
            switch code {
            case 200..<400:
                fatalError("This was supposed to be handled in Network")
            case 401, 403:
                return .authentication
            case 404:
                return .network
            case 500...Int.max:
                return .github
            default:
                return .network
            }
        }
    }
}
