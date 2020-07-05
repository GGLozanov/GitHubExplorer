//
//  Resource.swift
//  GitHubExplorer
//
//  Created by ts51 on 4.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import Foundation

class RequestResource {
    var parameters: [String : Any]
    
    var headers: [String : String]
    
    var path: String
    
    var verb: RequestVerb
    
    init(parameters: [String : Any], headers: [String : String], path: String, verb: RequestVerb) {
        self.parameters = parameters
        self.headers = headers
        self.path = path
        self.verb = verb
    }
    
    // use this instead of default params because we don't want the option to omit in constructor
    convenience init() {
        self.init(parameters: [:], headers: [:], path: "/", verb: RequestVerb.GET)
    }
    
    func call() {
        preconditionFailure("This method must be overridden")
    }
}
