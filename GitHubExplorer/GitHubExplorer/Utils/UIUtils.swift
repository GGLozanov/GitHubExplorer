//
//  UIUtils.swift
//  GitHubExplorer
//
//  Created by ts51 on 13.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import UIKit

class UIUtils {
    public func renderOptionalLabelText<T: CustomStringConvertible>(label: UILabel, textValue: T?, prefix: String?, renderPredicate: (T?) -> Bool = { value in
        value != nil
        }) {
        if renderPredicate(textValue) {
            guard let textValue = textValue else {
                #warning("Predicate doesn't check for nil")
                return
            }
            
            label.text = (prefix ?? "") + String(describing: textValue)
            label.isHidden = false
        } else {
            label.isHidden = true
        }
    }
    
    public func roundUpButton(button: UIButton, cornerRadius: CGFloat = 15, borderWidth: CGFloat = 1) {
        button.layer.cornerRadius = cornerRadius
        button.layer.borderWidth = borderWidth
    }
}
