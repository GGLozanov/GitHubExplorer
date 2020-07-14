//
//  UIUtils.swift
//  GitHubExplorer
//
//  Created by ts51 on 13.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import UIKit

extension UILabel {
    public func renderOptionalLabelText<T: CustomStringConvertible>(textValue: T?, prefix: String?, renderPredicate: (T?) -> Bool = { value in
        value != nil
        }) {
        if renderPredicate(textValue) {
            guard let textValue = textValue else {
                #warning("Predicate doesn't check for nil")
                return
            }
            
            self.text = (prefix ?? "") + String(describing: textValue)
            self.isHidden = false
        } else {
            self.isHidden = true
        }
    }
}

extension UIButton {
    public func roundUpButton(cornerRadius: CGFloat = 15, borderWidth: CGFloat = 1) {
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = borderWidth
    }
}
