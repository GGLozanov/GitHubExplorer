//
//  GithubAPI.swift
//  GitHubExplorer
//
//  Created by Dilchovski on 3.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import Foundation
import KeychainAccess

extension Notification.Name {
    static let noCodeInOAuthRedirect = Notification.Name("noCodeInOAuthRedirect")
    static let oauthCodeExtracted = Notification.Name("oauthCodeExtracted")
}

class GithubAPI {
    enum GHEndpoint {
        case accessToken(code: String)
        case user(accessToken: String)
        case invalidateToken(accessToken: String)
    }
    
    private let network: Network
    private let baseURL: URL
    private let oauthBaseURL: URL
    private let notificationCenter: NotificationCenter
    private let keychain: Keychain
    
    private let decoder = JSONDecoder()
    
    init(network: Network = Network(),
         baseURL: URL = URL(string: "https://api.github.com")!,
         oauthBaseURL: URL = URL(string: "https://github.com/login/oauth")!,
         notificationCenter: NotificationCenter = .default,
         keychain: Keychain = Keychain(service: "com.example.GitHubExplorer")) {
        self.network = network
        self.baseURL = baseURL
        self.oauthBaseURL = oauthBaseURL
        self.notificationCenter = notificationCenter
        self.keychain = keychain
    }
    
    func getAccessToken(code: String, completion: @escaping (Result<String, APIError>) -> ()) {
        let endpoint = GHEndpoint.accessToken(code: code)
        let request = initRequest(for: endpoint, requestURL: oauthBaseURL)
        
        network.call(request: request) { result in
            switch result {
            case let .success((data, _)):
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
                
            case let .failure(networkError):
                completion(.failure(APIError.error(from: networkError)))
            }
        }
    }
    
    func getUser(completion: @escaping (Result<User, APIError>) -> ()) {
        guard let accessToken = keychain["accessToken"] else {
            completion(.failure(.authentication))
            return
        }
        
        let endpoint = GHEndpoint.user(accessToken: accessToken)
        let request = initRequest(for: endpoint, requestURL: baseURL)
        
        network.call(request: request) { result in
            switch result {
            case let .success((data, _)):
                do {
                    let user = try self.decoder.decode(User.self, from: data)
                    completion(.success(user))
                } catch {
                    print("[GithubAPI] Could not parse response in get_user call")
                    completion(.failure(.github))
                }
            case let .failure(networkError):
                completion(.failure(APIError.error(from: networkError)))
            }
        }
    }
    
    func invalidateAccessToken(completion: @escaping (Result<Void, APIError>) -> ()) {
        guard let accessToken = keychain["accessToken"] else {
                 completion(.failure(.authentication))
                 return
        }
        
        let endpoint = GHEndpoint.invalidateToken(accessToken: accessToken)
        let request = initRequest(for: endpoint, requestURL: baseURL)
        
        network.call(request: request) { result in
            switch result {
            case .success:
                completion(.success(()))
            case let .failure(networkError):
                completion(.failure(APIError.error(from: networkError)))
            }
        }
    }
    
    func extractAccessCode(from url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
        guard let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            notificationCenter.post(name: NSNotification.Name.noCodeInOAuthRedirect, object: nil)
            return
        }
        
        notificationCenter.post(Notification(name: Notification.Name.oauthCodeExtracted, object: nil, userInfo: ["code" : code]))
    }
    
    /// How will that work?
//    public func call<T>(endpoint: GHEndpoint, completion: (Result<T, Error>) -> ()) {
//
//    }
}

extension GithubAPI {
    // handles both POST and GET requests (for now) per the RequestVerb enum
    private func initRequest(for endpoint: GHEndpoint, requestURL: URL) -> URLRequest {
        var request = URLRequest(url: requestURL.appendingPathComponent(endpoint.path))
        request.httpMethod = endpoint.verb.rawValue
        request.allHTTPHeaderFields = endpoint.headers
        
        // decide query params or body here using verb enum
        // change the request by passing it as an inout var
        // (can't do it otherwise since it's a struct and they're passed by value)
        switch endpoint.verb {
        case .GET:
            var requestURLComponents = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!
            requestURLComponents.queryItems = endpoint.parameters.map { (dictPair) in
                
                let (key, value) = dictPair // can't deconstruct, smh
                return URLQueryItem(name: key, value: (value as! String))
                    // Might crash for different params
                    // never give query params different types than string
            }
            
            request.url = requestURLComponents.url!;
        case .POST, .DELETE:
            request.httpBody = dictionaryToJsonString(endpoint.parameters).data(using: .utf8)
        }
        
        return request
    }
}


extension GithubAPI {
    private static let secretParams = [
    ]
    
    private static let defaultParams = [
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
                .merging(GithubAPI.secretParams) { (current, _) in current }
        case .user:
            return GithubAPI.defaultParams
        case .invalidateToken(let token):
            return [
                "access_token" : token
            ]
        }
    }
    
    var headers: [String : String] {
        switch self {
        case .user(let accessToken): // get the access token of the instance
            return GithubAPI.authHeaders(token: accessToken).merging(GithubAPI.defaultHeaders) { current, _ in current } // use token for modified auth header enum
        case .accessToken:
            return GithubAPI.defaultHeaders
        case .invalidateToken:
            let username = GithubAPI.defaultParams["client_id"] ?? ""
            let password = GithubAPI.secretParams["client_secret"] ?? ""
            let base64Encoded = basicAuthToken(username: username, password: password)
            return GithubAPI.defaultHeaders.merging(["Authorization" : "Basic \(base64Encoded)"]) { current, _ in current }
        }
    }
    
    var path: String {
        switch self {
        case .accessToken:
            return "/access_token"
        case .user:
            return "/user"
        case .invalidateToken:
            return "/applications/\(GithubAPI.defaultParams["client_id"]!)/grant"
        }
    }
    
    var verb: Network.RequestVerb {
        switch self {
        case .accessToken:
            return Network.RequestVerb.POST
        case .user:
            return Network.RequestVerb.GET
        case .invalidateToken:
            return Network.RequestVerb.DELETE
        }
    }
    
    private func basicAuthToken(username: String, password: String) -> String {
        let unencoded = "\(username):\(password)"
        return unencoded.data(using: .utf8)!.base64EncodedString()
    }
}
