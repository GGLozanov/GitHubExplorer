//
//  GithubAPI.swift
//  GitHubExplorer
//
//  Created by Dilchovski on 3.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import Foundation
import KeychainAccess

extension Notification.Name {
    static let noCodeInOAuthRedirect = Notification.Name("noCodeInOAuthRedirect")
    static let oauthCodeExtracted = Notification.Name("oauthCodeExtracted")
}

class GithubAPI {
    private let network: Network
    private let notificationCenter: NotificationCenter
    private let keychain: Keychain
    
    private let decoder = JSONDecoder()
    
    init(network: Network = Network(),
         notificationCenter: NotificationCenter = .default,
         keychain: Keychain = Keychain(service: "com.example.GitHubExplorer")) {
        self.network = network
        self.notificationCenter = notificationCenter
        self.keychain = keychain
    }

    public func call<T: Endpoint>(endpoint: T, completion: @escaping (Result<T.ModelType, APIError>) -> ()) {
        network.call(request: endpoint.request) { result in
            switch result {
            case let .success((data, _)):
                if !(T.ModelType.self is Empty.Type) {
                    do {
                        let model = try self.decoder.decode(T.ModelType.self, from: data)
                        completion(.success(model))
                    } catch {
                        print("[GithubAPI] Could not parse response in the api call: \((error as NSError).debugDescription)")
                        completion(.failure(.github))
                    }
                }
                else {
                    completion(.success(Empty() as! T.ModelType))
                }
            case let .failure(networkError):
                completion(.failure(APIError.error(from: networkError)))
            }
        }
    }
    
    func extractAccessCode(from url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
        guard let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            notificationCenter.post(name: NSNotification.Name.noCodeInOAuthRedirect, object: nil)
            return
        }
        
        notificationCenter.post(Notification(name: Notification.Name.oauthCodeExtracted, object: nil, userInfo: ["code" : code]))
    }
    
    public func getUserFromStoredToken(completion: @escaping ((Result<User, APIError>) -> ())) {
        var getUserEndpoint: GithubEndpoints.UserEndpoint.GetUser
        
        do {
            getUserEndpoint = try GithubEndpoints.UserEndpoint.GetUser()
        } catch {
            if let apiError = error as? GithubAPI.APIError {
                completion(.failure(apiError))
            } else {
                assert(false, "No handling for new error yet")
            }
            return
        }
        
        call(endpoint: getUserEndpoint) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let user):
                completion(.success(user))
            }
        }
    }
}


