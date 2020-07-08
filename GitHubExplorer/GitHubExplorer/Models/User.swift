//
//  User.swift
//  GitHubExplorer
//
//  Created by Dilchovski on 3.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import Foundation

struct User: Codable {
    enum CodingKeys: String, CodingKey {
        case username = "login"
        case profileImageURL = "avatar_url"
    }
    
    let username: String
    let profileImageURL: String
}
