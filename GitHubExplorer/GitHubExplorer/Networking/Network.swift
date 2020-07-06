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
    
    enum RequestVerb: String {
        case POST
        case GET
    }
    
    private let session: NetworkProvider
    
    init(session: NetworkProvider = URLSession.shared) {
        self.session = session
    }
    
    func call(request: URLRequest, completion: @escaping (Result<(Data, URLResponse), NetworkError>) -> ()) {
        session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                let error = error! as NSError
                DispatchQueue.main.async { completion(.failure(.cocoaNetworking(error))) }
                print("[Networking] call failed: \(error.debugDescription)")
                return
            }

            guard let response = response as? HTTPURLResponse else {
                DispatchQueue.main.async { completion(.failure(.noResponse)) }
                print("[Networking] no response")
                return
            }
            
            guard response.statusCode >= 200, response.statusCode < 400 else {
                DispatchQueue.main.async { completion(.failure(.badStatusCode(response.statusCode))) }
                print("[Networking] Bad response code: \(response.statusCode)")
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(.noData)) }
                print("[Networking] no data")
                return
            }
            
            print("[Networking] SUCCESS!")
            DispatchQueue.main.async { completion(.success((data, response))) }
        }.resume() // start the data task
    }
}
