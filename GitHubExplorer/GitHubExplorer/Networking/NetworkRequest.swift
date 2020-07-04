//
//  Network.swift
//  GitHubExplorer
//
//  Created by Dilchovski on 3.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import Foundation 
 
protocol NetworkRequest: AnyObject{
      associatedtype Model
      func decode(data: Data) -> Model?
}

extension NetworkRequest{
    
    func call(request: URLRequest, completion: @escaping (Result<(Model?, URLResponse), APIError>) -> ()){
           let session = URLSession.shared
           let task = session.dataTask(with: request) { data, response, error in
               guard error == nil else {
                    let error = error! as NSError
                    completion(.failure(APIError.error(from: .cocoaNetworking(error))))
                    print("[Networking] call failed: \(error.debugDescription)")
                    return
               }

               guard let response = response as? HTTPURLResponse else {
                    completion(.failure(APIError.error(from: .noResponse)))
                    print("[Networking] no response")
                    return
               }
               
               guard response.statusCode >= 200, response.statusCode < 400 else {
                    completion(.failure(APIError.error(from: .badStatusCode(response.statusCode))))
                    print("[Networking] Bad response code: \(response.statusCode)")
                    return
               }
               
               guard let data = data else {
                    completion(.failure(APIError.error(from: .noData)))
                   print("[Networking] no data")
                   return
               }
               
               print("[Networking] SUCCESS!")
               completion(.success((self.decode(data: data), response))) // will return any value of certain Model, decoded
           }
           task.resume()
               
       }
}

enum NetworkError: Error {
    case cocoaNetworking(NSError)
    case noResponse
    case noData
    case badStatusCode(Int)
}





