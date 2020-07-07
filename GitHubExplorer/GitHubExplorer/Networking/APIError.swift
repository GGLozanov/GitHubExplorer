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
        
        func alert(onAuthenticationError: (() -> ())? = nil,
                   onNetworkError: (() -> ())? = nil,
                   onGithubError: (() -> ())? = nil) -> UIAlertController {
            let title: String
            let message: String
            let handler: (() -> ())?
            
            switch self {
            case .authentication:
                title = "Authentication failed"
                message = "Please login again"
                handler = onAuthenticationError
                
            case .network:
                title = "Network error"
                message = "Please check your network connection"
                handler = onNetworkError
                
            case .github:
                title = "Github error"
                message = "Please try again in a few moments"
                handler = onGithubError
            }
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { _ in handler?() }
            alert.addAction(action)
            
            return alert
        }
    }
}
