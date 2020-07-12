//
//  WithOptionalTextLabel.swift
//  GitHubExplorer
//
//  Created by ts51 on 12.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import UIKit

// Extracted if used later for other optional labels
protocol WithOptionalUILabel {
    
}

extension WithOptionalUILabel {
    func renderOptionalLabelText<T>(label: UILabel, textValue: T?, prefix: String?, renderPredicate: (T?) -> Bool = { value in
        value != nil
    }) {
        if renderPredicate(textValue) {
            guard let textValue = textValue else {
                #warning("Predicate doesn't check for nil")
                return
            }
            
            label.text = (prefix ?? "") + String(describing: textValue)
        } else {
            label.isHidden = true
        }
    }
}
