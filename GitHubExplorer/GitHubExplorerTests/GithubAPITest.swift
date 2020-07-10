//
//  GithubAPITest.swift
//  GitHubExplorerTests
//
//  Created by ts38 on 9.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import XCTest
import UIKit
import KeychainAccess
@testable import GitHubExplorer

class GithubAPITest: XCTestCase{
    
    var jsonUser: [String: Any] = [
        "login" : "alexvidenov",
        "email" : "alexvidenov@sample.com",
        "name" : "alex",
        "bio" : "bio",
        "avatar_url" : "https://github.com/avatar",
        "location" : "epic location",
        "public_repos" : 3,
        "followers" : 5,
        "following" : 4,
        "repos_url" : "https://github.com/repos"
    ]
    
    var jsonData: Data?
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        jsonData = try? JSONSerialization.data(withJSONObject: jsonUser, options: .prettyPrinted)  // serializes dict into binary
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testUserEndpointSuccessWithToken(){
        let endpoint = GithubEndpoints.UserEndpoint.GetUser(accessToken: "access")
        
        let session = NetworkProviderMock(data: jsonData, response: HTTPURLResponse(), error: nil) // mocked response
        
        let network: Network = Network(session: session)
        let api = GithubAPI(network: network) // mocked API without external dependencies
        
        api.call(endpoint: endpoint) { (result) in
            switch result {
            case .success(let user): // tests the user adoption of decodable
                XCTAssertEqual(user.username, "alexvidenov")
                XCTAssertEqual(user.email, "alexvidenov@sample.com")
                XCTAssertEqual(user.nickname, "alex")
            case .failure:
                XCTFail()
            }
        }
        
    }
    
    func testUserEndpointFailsWithNetwork(){
        let endpoint = GithubEndpoints.UserEndpoint.GetUser(accessToken: "accessToken")
        
        let session = NetworkProviderMock(data: jsonData, response: HTTPURLResponse(), error: Network.NetworkError.noData) // mocked response
        
        let network: Network = Network(session: session)
        let api = GithubAPI(network: network) // mocked API without external dependencies
        
        api.call(endpoint: endpoint) { (result) in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, GithubAPI.APIError.network)
            }
        }

    }
    
    func testUserFailsWithAuthentication(){
        let endpoint = GithubEndpoints.UserEndpoint.GetUser(accessToken: "accessToken")
              
        let session = NetworkProviderMock(data: jsonData, response: HTTPURLResponse(url: URL(string: "https://github.com")!, statusCode: 401, httpVersion: nil, headerFields: nil), error: nil) // mocked response
        
        let network: Network = Network(session: session)
        let api = GithubAPI(network: network) // mocked API without external dependencies
        
        api.call(endpoint: endpoint) { (result) in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, GithubAPI.APIError.authentication)
            }
        }
    }
    
    func testUserGithubError(){
        let endpoint = GithubEndpoints.UserEndpoint.GetUser(accessToken: "accessToken")
              
        jsonUser = [
            "userName" : "alexvidenov", // wrong key
            "userMail" : "alexvidenov@sample.com", // wrong key
            "name" : "alex",
            "bio" : "bio",
            "avatar_url" : "https://github.com/avatar",
            "location" : "epic location",
            "public_repos" : 3,
            "followers" : 5,
            "following" : 4,
            "repos_url" : "https://github.com/repos"
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: jsonUser, options: .prettyPrinted) // serializes dict into binary
        
        let session = NetworkProviderMock(data: jsonData, response: HTTPURLResponse(), error: nil) // mocked response
        
        let network: Network = Network(session: session)
        let api = GithubAPI(network: network) // mocked API without external dependencies
        
        api.call(endpoint: endpoint) { (result) in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, GithubAPI.APIError.github)
            }
        }
    
    }

}
