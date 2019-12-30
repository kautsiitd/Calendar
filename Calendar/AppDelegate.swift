//
//  AppDelegate.swift
//  Calendar
//
//  Created by Kautsya Kanu on 15/11/17.
//  Copyright © 2017 Kautsya Kanu. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		return true
	}
    
    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataStack.shared.save()
    }
}

