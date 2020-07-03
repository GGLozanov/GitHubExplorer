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
        case user
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
        var request = URLRequest(url: oauthBaseURL.appendingPathComponent(endpoint.path))
        request.httpMethod = endpoint.verb
        request.allHTTPHeaderFields = endpoint.headers
        
        //FIXME: determine if it's a body or query parameter based on verb enum
        request.httpBody = dictionaryToJsonString(endpoint.parameters).data(using: .utf8)
        
        network.call(request: request) { result in
            switch result {
            case let .success(data, response):
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
    
    func getUser() {
    }
    
    /// How will that work?
//    public func call<T>(endpoint: GHEndpoint, completion: (Result<T, Error>) -> ()) {
//
//    }
}

func dictionaryToJsonString(_ dict: [String : Any]) -> String {
    let jsonString = dict.reduce("") { (jsonString, pair) in
        return jsonString + "\"\(pair.key)\" : \"\(pair.value)\","
    }
    return String(jsonString.dropLast(1)) // Drops the last trailing comma
}

extension GithubAPI {
    private static let defaultParams = [
        "client_secret" : "",
        "client_id" : ""
    ]
    
    private static let defaultHeaders = [
        "Content-Type" : "application/json",
        "Accept" : "application/json",
        "User-Agent" : "GHExplorer"
    ]
    
    private static var authHeaders: [String : String] {
        return [
            "Authorization" : "token _"
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
        case .user:
            return GithubAPI.authHeaders.merging(GithubAPI.defaultHeaders) { current, _ in current }
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
    var verb: String {
        switch self {
        case .accessToken:
            return "POST"
        case .user:
            return "GET"
        }
    }
}
