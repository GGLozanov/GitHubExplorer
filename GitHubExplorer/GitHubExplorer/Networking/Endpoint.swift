//
//  Endpoint.swift
//  GitHubExplorer
//
//  Created by Dilchovski on 7.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import Foundation
import KeychainAccess

protocol Endpoint {
    associatedtype ModelType: Decodable
    
    var parameters: [String : Any] { get }
    var headers: [String : String] { get }
    var url: URL { get }
    var verb: Network.RequestVerb { get }
}

extension Endpoint {
    var request: URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = verb.rawValue
        request.allHTTPHeaderFields = headers
        
        switch verb {
        case .GET:
            var requestURLComponents = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!
            requestURLComponents.queryItems = parameters.map { (dictPair) in

                let (key, value) = dictPair // can't deconstruct, smh
                return URLQueryItem(name: key, value: (value as! String))
                    // Might crash for different params
                    // never give query params different types than string
            }

            request.url = requestURLComponents.url!;
        case .POST, .DELETE:
            request.httpBody = dictionaryToJsonString(parameters).data(using: .utf8)
        }

        return request
    }
}

struct Empty: Decodable {}

struct GithubEndpoints {
    struct UserEndpoint {
        struct GetUser: Endpoint {
            private let accessToken: String
            
            typealias ModelType = User
            var parameters: [String : Any] = GithubEndpoints.defaultParams
            var url: URL = GithubEndpoints.apiURL.appendingPathComponent("/user")
            var headers: [String : String]  {
                GithubEndpoints.authHeaders(token: accessToken).merging(GithubEndpoints.defaultHeaders) { current, _ in current }
            }
            var verb: Network.RequestVerb = .GET
            
            init() throws {
                guard let accessToken = GithubEndpoints.accessToken else {
                    throw GithubAPI.APIError.authentication
                }
                self.accessToken = accessToken
            }
        }
    }
    
    struct AccessTokenEndpoint {
        struct GetToken: Endpoint {
            let code: String
            
            typealias ModelType = AuthorizationResponse
            var parameters: [String : Any]  {
                return [
                    "code" : code,
                ].merging(GithubEndpoints.defaultParams) { (current, _) in current }
                .merging(GithubEndpoints.secretParams) { (current, _) in current }
            }
            var headers = GithubEndpoints.defaultHeaders
            var url = GithubEndpoints.oauthURL.appendingPathComponent("/access_token")
            var verb: Network.RequestVerb = .POST
            
            
        }
    }
    
    struct ApplicationsEndpoint {
        struct InvalidateAuthentications: Endpoint {
            private let accessToken: String
            
            typealias ModelType = Empty
            var parameters: [String : Any] { return [ "access_token" : accessToken ] }
            var headers: [String : String] {
                let username = GithubEndpoints.defaultParams["client_id"] ?? ""
                let password = GithubEndpoints.secretParams["client_secret"] ?? ""
                let base64Encoded = GithubEndpoints.basicAuthToken(username: username, password: password)
                return GithubEndpoints.defaultHeaders.merging(["Authorization" : "Basic \(base64Encoded)"]) { current, _ in current }
            }
            var url = GithubEndpoints.apiURL.appendingPathComponent("/applications/\(GithubEndpoints.defaultParams["client_id"]!)/grant")
            var verb: Network.RequestVerb = .DELETE
            
            init() throws {
                guard let accessToken = GithubEndpoints.accessToken else {
                    throw GithubAPI.APIError.authentication
                }
                self.accessToken = accessToken
            }
        }
    }
}

extension GithubEndpoints {
    private static let accessToken = Keychain(service: "com.example.GitHubExplorer")["accessToken"]
    private static let apiURL = URL(string: "https://api.github.com")!
    private static let oauthURL = URL(string: "https://github.com/login/oauth")!
    
    private static let secretParams = [
        "client_secret" : Secrets.clientSecret
    ]
    
    private static let defaultParams = [
        "client_id" : Secrets.clientId
    ]
    
    private static let defaultHeaders = [
        "Content-Type" : "application/json",
        "Accept" : "application/json",
        "User-Agent" : "GHExplorer"
    ]
    
    private static func authHeaders(token: String = "") -> [String : String] {
        return [
            "Authorization" : "token \(token)" // TODO: replace placeholder var and save token in secure local storage
        ]
    }
    
    private static func basicAuthToken(username: String, password: String) -> String {
        let unencoded = "\(username):\(password)"
        return unencoded.data(using: .utf8)!.base64EncodedString()
    }
}
