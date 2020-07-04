//
//  UserResource.swift
//  GitHubExplorer
//
//  Created by ts38 on 4.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import Foundation


class UserResource: Api {
    private let accessToken: String
    
    init(accessToken: String) {
        self.accessToken = accessToken
    }
     
    func getParameters() -> [String : Any]{
        return GitHubApi.defaultParams
    }
      
    func getHeaders() -> [String : String] {
        return GitHubApi.authHeaders(token: accessToken).merging(GitHubApi.defaultHeaders) { current, _ in current }
    }
      
    func getPath() -> String {
        return "/user"
    } 
      
    func getVerb() -> String {
        return "GET"
    }
    
}

extension UserResource: NetworkRequest{
    typealias Model = User
    
    func decode(data: Data) -> Model? {
        guard let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String : Any] else {
            return nil
        }
        return User() // fill with the User constructor
    }
    
    func call(completion: @escaping (Result<(Model?, URLResponse), APIError>) -> ()){
        var request = GitHubApi().initRequest(for: self, requestURL: GitHubApi.baseURL)
        GitHubApi().setRequestData(request: &request, data: getParameters())
        call(request: request, completion: completion)
    }
}



 
