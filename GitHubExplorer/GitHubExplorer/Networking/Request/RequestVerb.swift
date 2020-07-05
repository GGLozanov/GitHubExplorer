//
//  RequestVerb.swift
//  GitHubExplorer
//
//  Created by ts51 on 4.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import Foundation

enum RequestVerb: String {
    case POST
    case GET

    func setRequestData(request: inout URLRequest, data: [String: Any]) {
        switch self {
        case .GET:
            var requestURLComponents = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!

            requestURLComponents.queryItems = data.map { (dictPair) in

                let (key, value) = dictPair // can't deconstruct, smh
                return URLQueryItem(name: key, value: (value as! String))
                    // Might crash for different params
                    // never give query params different types than string
            }

            requestURLComponents.percentEncodedQuery = requestURLComponents
                .percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
            // done to make sure special characters don't f*ck up the URL
            
            request.url = requestURLComponents.url!;
        case .POST:
            request.httpBody = dictionaryToJsonString(data).data(using: .utf8)
        }
    }
}
