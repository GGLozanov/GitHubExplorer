//
//  Repositories.swift
//  GitHubExplorer
//
//  Created by ts38 on 8.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import Foundation

struct Repository: Codable {
    enum CodingKeys: String, CodingKey {
        case repoName = "name"
        case repoDescription = "description"
        case commitsURL = "commits_url"
        case forks = "forks_count"
        case stars = "stargazers_count"
    }
       
    let repoName: String
    let repoDescription: String?
    let commitsURL: String
    let forks: Int?
    let stars: Int?
}
