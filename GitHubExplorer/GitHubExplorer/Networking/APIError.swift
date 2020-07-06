//
//  APIError.swift
//  GitHubExplorer
//
//  Created by Dilchovski on 3.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import Foundation
import UIKit.UIAlertController

extension GithubAPI {
    enum APIError: Error {
        case network
        case github
        case authentication
        
        static func error(from error: Network.NetworkError) -> APIError {
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
        
        var alert: UIAlertController {
            let title: String
            let message: String
            switch self {
            case .authentication:
                title = "Authentication failed"
                message = "Please login again"
                
            case .network:
                title = "Network error"
                message = "Please check your network connection"
                
            case .github:
                title = "Github error"
                message = "Please try again in a few moments"
            }
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            return alert
        }
    }
}
