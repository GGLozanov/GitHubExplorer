//
//  UserResource.swift
//  GitHubExplorer
//
//  Created by ts38 on 4.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import Foundation


class UserResource: RequestResource {
    private let accessToken: String
    
    init(accessToken: String) {
        self.accessToken = accessToken
        super.init(parameters: GithubAPI.defaultParams, headers: GithubAPI.authHeaders(token: accessToken).merging(GithubAPI.defaultHeaders) { current, _ in current }, path: "/user", verb: RequestVerb.GET)
    }
    
}

extension UserResource: NetworkRequest {
    typealias Model = User
    
    func decode(data: Data) -> Model? {
        guard let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String : Any] else {
            return nil
        }
        return User() // fill User constructor w/ json props
    }
    
    override func call(completion: @escaping (Result<(Model?, URLResponse), APIError>) -> ()){
        var request = GithubAPI().initRequest(for: self, requestURL: GithubAPI.baseURL)
        call(request: request, completion: completion)
    }
}



 
