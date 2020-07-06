//
//  Utils.swift
//  GitHubExplorer
//
//  Created by ts51 on 4.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import Foundation


func dictionaryToJsonString(_ dict: [String : Any]) -> String {
    let jsonString = dict.reduce("") { (jsonString, pair) in
        return jsonString + "\"\(pair.key)\" : \"\(pair.value)\","
    }
    return String("{\(jsonString.dropLast(1))}") // Drops the last trailing comma
}
