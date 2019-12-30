//
//  UIAlertController.swift
//  Calendar
//
//  Created by Kautsya Kanu on 30/12/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import UIKit

//Because of Apple new bug
extension UIAlertController {
    func pruneNegativeWidthConstraints() {
        for subView in self.view.subviews {
            for constraint in subView.constraints where constraint.debugDescription.contains("width == - 16") {
                subView.removeConstraint(constraint)
            }
        }
    }
}
