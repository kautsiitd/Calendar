//
//  UIViewController.swift
//  Calendar
//
//  Created by Kautsya Kanu on 24/12/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import UIKit

extension UIViewController {
    //FIXEME: iOS 13 Beta stage Bug, See better way to handle
    //pullToDismiss on modally presented ViewController
    func pullToDismiss(isEnable: Bool) {
        presentationController?.presentedView?.gestureRecognizers?[0].isEnabled = isEnable
    }
}
