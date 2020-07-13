//
//  UIUtils.swift
//  GitHubExplorer
//
//  Created by ts51 on 13.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import UIKit

class UIUtils {
    func renderOptionalLabelText<T: CustomStringConvertible>(label: UILabel, textValue: T?, prefix: String?, renderPredicate: (T?) -> Bool = { value in
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
