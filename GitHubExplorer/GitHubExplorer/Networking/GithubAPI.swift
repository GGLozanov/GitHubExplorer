//
//  GithubAPI.swift
//  GitHubExplorer
//
//  Created by Dilchovski on 3.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import Foundation  

protocol Api {
    func getParameters() -> [String : Any]
    func getHeaders() -> [String : String]
    func getPath() -> String
    func getVerb() -> String
}

class GitHubApi{
    
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
     
    func setRequestData(request: inout URLRequest, data: [String : Any]){
        switch request.httpMethod{
        case "GET":
            var requestURLComponents = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!
            requestURLComponents.queryItems = data.map { (dictPair) in
                let (key, value) = dictPair
                return URLQueryItem(name: key, value: (value as! String))
            }
            requestURLComponents.percentEncodedQuery = requestURLComponents.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
            request.url = requestURLComponents.url!
            
        case "POST":
            request.httpBody = dictionaryToJsonString(data).data(using: .utf8)
        default: break
        }
    }
    
    func initRequest(for endpoint: Api, requestURL: URL) -> URLRequest{
        var request = URLRequest(url: requestURL.appendingPathComponent(endpoint.getPath()))
        request.httpMethod = endpoint.getVerb()
        request.allHTTPHeaderFields = endpoint.getHeaders()
        return request
    }
}


