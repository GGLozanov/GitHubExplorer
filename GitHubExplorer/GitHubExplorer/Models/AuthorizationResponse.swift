//
//  AuthorizationResponse.swift
//  GitHubExplorer
//
//  Created by ts38 on 7.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import Foundation

struct AuthorizationResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case access_token = "access_token"
    }
       
    let access_token: String
}
