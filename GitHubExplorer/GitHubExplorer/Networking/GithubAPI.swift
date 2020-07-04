//
//  GithubAPI.swift
//  GitHubExplorer
//
//  Created by Dilchovski on 3.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import Foundation

class GithubAPI {
    enum GHEndpoint {
        case accessToken(code: String)
        case user(accessToken: String)
    }
    
    private let network: Network
    private let baseURL: URL
    private let oauthBaseURL: URL
    
    init(network: Network = Network(),
         baseURL: URL = URL(string: "https://api.github.com")!,
         oauthBaseURL: URL = URL(string: "https://github.com/login/oauth")!) {
        self.network = network
        self.baseURL = baseURL
        self.oauthBaseURL = oauthBaseURL
    }
    
    func getAccessToken(code: String, completion: @escaping (Result<String, APIError>) -> ()) {
        let endpoint = GHEndpoint.accessToken(code: code)
        let request = initRequest(for: endpoint, requestURL: oauthBaseURL)
        
        network.call(request: request) { result in
            switch result {
            case let .success(data, _):
                guard let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String : Any] else {
                    print("[GithubAPI] Could not parse response in access_token call")
                    completion(.failure(.github))
                    return
                }
                guard let token = json["access_token"] as? String else {
                    print("[GithubAPI] access_token not found in access_token call")
                    completion(.failure(.github))
                    return
                }
                
                completion(.success(token))
                
            case let .failure(error):
                completion(.failure(APIError.error(from: error)))
            }
        }
    }
    
    func getUser(accessToken: String, completion: @escaping (Result<User, APIError>) -> ()) {
        let endpoint = GHEndpoint.user(accessToken: accessToken)
        let request = initRequest(for: endpoint, requestURL: baseURL)
        
        network.call(request: request) { result in
            switch result {
            case let .success(data, _): // destruct tuple. . .
                guard let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String : Any] else {
                    print("[GithubAPI] Could not parse response in get_user call")
                    completion(.failure(.github))
                    return
                }
                
                completion(.success(User(
                    // fill with deserialized json props here for constructor args. . .
                )))
            case let .failure(error):
                completion(.failure(APIError.error(from: error)))
            }
        }
    }
    
    // handles both POST and GET requests (for now) per the RequestVerb enum
    private func initRequest(for endpoint: GHEndpoint, requestURL: URL) -> URLRequest {
        var request = URLRequest(url: requestURL.appendingPathComponent(endpoint.path))
        request.httpMethod = endpoint.verb.rawValue
        request.allHTTPHeaderFields = endpoint.headers
        
        // decide query params or body here using verb enum
        // change the request by passing it as an inout var
        // (can't do it otherwise since it's a struct and they're passed by value)
        endpoint.verb.setRequestData(request: &request, data: endpoint.parameters)
        
        return request
    }
    
    /// How will that work?
//    public func call<T>(endpoint: GHEndpoint, completion: (Result<T, Error>) -> ()) {
//
//    }
}


extension GithubAPI {
    private static let defaultParams = [
        "client_secret" : "",
        "client_id" : "3fed7e1efcc8b36c1336" // TODO: hide and put somewhere else
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
}

extension GithubAPI.GHEndpoint {
    var parameters: [String : Any] {
        switch self {
        case .accessToken(let code):
            return [
                "code" : code,
            ].merging(GithubAPI.defaultParams) { (current, _) in current }
        case .user:
            return GithubAPI.defaultParams
        }
    }
    
    var headers: [String : String] {
        switch self {
        case .user(let accessToken): // get the access token of the instance
            return GithubAPI.authHeaders(token: accessToken).merging(GithubAPI.defaultHeaders) { current, _ in current } // use token for modified auth header enum
        case .accessToken:
            return GithubAPI.defaultHeaders
        }
    }
    
    var path: String {
        switch self {
        case .accessToken:
            return "/access_token"
        case .user:
            return "/user"
        }
    }
    
    // FIXME: Trun into a enum
    var verb: Network.RequestVerb {
        switch self {
        case .accessToken:
            return Network.RequestVerb.POST
        case .user:
            return Network.RequestVerb.GET
        }
    }
}
