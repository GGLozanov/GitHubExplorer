//
//  OAuthResource.swift
//  GitHubExplorer
//
//  Created by ts38 on 4.07.20.
//  Copyright © 2020 example. All rights reserved.
//
 
import Foundation
 
class OAuthResource: RequestResource {
    
    private let code: String
    
    init(code: String) {
        self.code = code
        super.init(parameters: [
            "code" : code,
            ].merging(GithubAPI.defaultParams) { (current, _) in current }, headers: GithubAPI.defaultHeaders, path: "/access_token", verb: RequestVerb.POST)
    }
}

extension OAuthResource: NetworkRequest {
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
    
    override func call(completion: @escaping (Result<(Model?, URLResponse), APIError>) -> ()) {
        var request = GithubAPI().initRequest(for: self, requestURL: GithubAPI.OAuthBaseURL)
        call(request: request, completion: completion)
    }
}
