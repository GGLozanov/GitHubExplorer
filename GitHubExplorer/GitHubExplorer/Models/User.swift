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
        
        case email
        case nickname = "name"
        case description = "bio"
        case location
        
        case profileImageURL = "avatar_url"
        case reposURL = "repos_url"
        
        case publicRepoCount = "public_repos"
        case followerCount = "followers"
        case followingCount = "following"
 
    }
    
    let username: String
    
    let email: String?
    let nickname: String?
    let description: String?
    let location: String?
    
    let profileImageURL: String?
    let reposURL: String
    
    let publicRepoCount: Int
    let followerCount: Int
    let followingCount: Int
     
}
