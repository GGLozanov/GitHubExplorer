//
//  Network.swift
//  GitHubExplorer
//
//  Created by Dilchovski on 3.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import UIKit

class Network {
    enum NetworkError: Error {
        case cocoaNetworking(NSError)
        case noResponse
        case noData
        case badStatusCode(Int)
        
        // FIXME: extract into protocol or find a way to generalise
        var alert: UIAlertController {
               let title: String
               let message: String
            
               switch self {
               case .noResponse:
                   title = "No response"
                   message = "Please try again"
               case .noData:
                   title = "No data received"
                   message = "Please check your Internet connection"
               case .badStatusCode(let statusCode):
                   title = "Bad status code: \(statusCode)"
                   message = "Please try again or contact a developer"
               case .cocoaNetworking(let cocoaNetworking):
                   title = "Internal connection error: \(cocoaNetworking.code)"
                   message = "Please contact a developer"
               }
               
               let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
               let action = UIAlertAction(title: "OK", style: .default)
               alert.addAction(action)
               
               return alert
           }
    }
    
    enum RequestVerb: String {
        case POST
        case GET
        case DELETE
    }
    
    private let session: NetworkProvider
    static let instance: Network = Network()
    
    init(session: NetworkProvider = URLSession.shared) {
        self.session = session
    }
    
    func call(request: URLRequest, completion: @escaping (Result<(Data, URLResponse), NetworkError>) -> ()) {
        session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                let error = error! as NSError
                DispatchQueue.main.async { completion(.failure(.cocoaNetworking(error))) }
                print("[Networking] \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "call") failed: \(error.debugDescription)")
                return
            }

            guard let response = response as? HTTPURLResponse else {
                DispatchQueue.main.async { completion(.failure(.noResponse)) }
                print("[Networking] \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "call") no response")
                return
            }
            
            guard response.statusCode >= 200, response.statusCode < 400 else {
                DispatchQueue.main.async { completion(.failure(.badStatusCode(response.statusCode))) }
                print("[Networking] \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "call") Bad response code: \(response.statusCode)")
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(.noData)) }
                print("[Networking] \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "call") no data")
                return
            }
            
            print("[Networking] \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "call") SUCCESS!")
            DispatchQueue.main.async { completion(.success((data, response))) }
        }.resume() // start the data task
    }
    
}
