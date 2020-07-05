//
//  GithubAPI.swift
//  GitHubExplorer
//
//  Created by Dilchovski on 3.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import Foundation  

//protocol RequestProperties {
//    var parameters: [String : Any] { get set }
//    var headers: [String : String] { get set }
//    var path: String { get set }
//    var verb: RequestVerb { get set }
//}

class GithubAPI {
    
    static let defaultParams = [
        "client_secret" : "",
        "client_id" : ""
    ]
    
    static let defaultHeaders = [
        "Content-Type" : "application/json",
        "Accept" : "application/json",
        "User-Agent" : "GHExplorer"
    ]
    
    static func authHeaders(token: String = "") -> [String : String] {
        return [
           "Authorization" : "token \token"
        ]
    }
    
    static let baseURL: URL = URL(string: "https://api.github.com")!
    
    static let OAuthBaseURL: URL = URL(string: "https://github.com/login/oauth")!
    
    func initRequest(for endpoint: RequestResource, requestURL: URL) -> URLRequest {
        var request = URLRequest(url: requestURL.appendingPathComponent(endpoint.path))
        request.httpMethod = endpoint.verb.rawValue
        request.allHTTPHeaderFields = endpoint.headers
        
        endpoint.verb.setRequestData(request: &request, data: endpoint.parameters)
            // inout param modifies current var as well as local function param
    
        return request
    }
}


