//
//  OAuthResource.swift
//  GitHubExplorer
//
//  Created by ts38 on 4.07.20.
//  Copyright © 2020 example. All rights reserved.
//
 
import Foundation
 
class OAuthResource: Api{
    private let code: String
    
    init(code: String) {
        self.code = code
    }
    
    func getParameters() -> [String : Any]{
        return [
            "code" : code,
        ].merging(GitHubApi.defaultParams) { (current, _) in current }
    }
    
    func getHeaders() -> [String : String] {
        return GitHubApi.defaultHeaders
    }
    
    func getPath() -> String {
        return "/access_token"
    }
    
    func getVerb() -> String {
        return "POST"
    }
}

extension OAuthResource: NetworkRequest{
    typealias Model = String 
    
    func decode(data: Data) -> Model? {
        guard let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String : Any] else {
            print("[GithubAPI] Could not parse response in access_token call")
            return nil
        }
        
        guard let token = json["access_token"] as? String else {
            print("[GithubAPI] access_token not found in access_token call")
            return nil
        }
        return token
    }
    
    func call(completion: @escaping (Result<(Model?, URLResponse), APIError>) -> ()){
        var request = GitHubApi().initRequest(for: self, requestURL: GitHubApi.OAuthBaseURL)
        GitHubApi().setRequestData(request: &request, data: getParameters())
        call(request: request, completion: completion)
    }
}
