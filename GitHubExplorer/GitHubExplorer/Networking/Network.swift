//
//  Network.swift
//  GitHubExplorer
//
//  Created by Dilchovski on 3.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import Foundation

class Network {
    enum NetworkError: Error {
        case cocoaNetworking(NSError)
        case noResponse
        case noData
        case badStatusCode(Int)
    }
    
    private let session: NetworkProvider
    
    init(session: NetworkProvider = URLSession.shared) {
        self.session = session
    }
    
    func call(request: URLRequest, completion: @escaping (Result<(Data, URLResponse), NetworkError>) -> ()) {
        session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                let error = error! as NSError
                completion(.failure(.cocoaNetworking(error)))
                print("[Networking] call failed: \(error.debugDescription)")
                return
            }

            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.noResponse))
                print("[Networking] no response")
                return
            }
            
            guard response.statusCode >= 200, response.statusCode < 400 else {
                completion(.failure(.badStatusCode(response.statusCode)))
                print("[Networking] Bad response code: \(response.statusCode)")
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                print("[Networking] no data")
                return
            }
            
            print("[Networking] SUCCESS!")
            completion(.success((data, response)))
        }.resume()
    }
}
