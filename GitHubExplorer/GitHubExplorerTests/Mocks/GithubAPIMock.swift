//
//  GithubAPIMock.swift
//  GitHubExplorerTests
//
//  Created by ts38 on 9.07.20.
//  Copyright © 2020 example. All rights reserved.
//

@testable import GitHubExplorer
import UIKit

class GithubAPIMock {
    
    private let network: Network
    private let decoder = JSONDecoder()
    
    init(network: Network) {
        self.network = network
    }
    
    public func call<T: EndpointMockProtocol>(endpoint: T, completion: @escaping (Result<T.Model, GithubAPI.APIError>) -> ()) {
        network.call(request: endpoint.request) { result in
            switch result {
            case let .success((data, _)):
                if !(T.Model.self is Empty.Type) {
                    do {
                        let model = try self.decoder.decode(T.Model.self, from: data)
                        completion(.success(model))
                    } catch {
                        print("[GithubAPI] Could not parse response in the api call: \((error as NSError).debugDescription)")
                        completion(.failure(.github))
                    }
                }
                else {
                    completion(.success(Empty() as! T.Model))
                }
            case let .failure(networkError):
                completion(.failure(GithubAPI.APIError.error(from: networkError)))
            }
        }
    }
    
}
