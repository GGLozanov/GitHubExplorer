//
//  Storyboarded.swift
//  GitHubExplorer
//
//  Created by ts51 on 6.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import UIKit

// protocol used to extract VC from storyboard (req: storyboard_id and vc class must be the same)
protocol Storyboarded {
    associatedtype CoordinatorType
    
    var coordinator: CoordinatorType? { get set }
    
    static func instantiate() -> Self // Self -> eventual type that conforms to this protocol
}

extension Storyboarded where Self: UIViewController { // only applicable to UIViewController
    static func instantiate() -> Self {
        // VC signature w/ NS: <AppName>.<VCName>
        // => draw VC route and split by '.' character
        
        let vcFullName = NSStringFromClass(self)
        
        let vcName = vcFullName.components(separatedBy: ".")[1]
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
            // get main storyboard instance w/ main bundle alongside it
        
        return storyboard.instantiateViewController(identifier: vcName)
    }
}
