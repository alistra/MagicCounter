//
//  AppDelegate.swift
//  magiccounter
//
//  Created by Aleksander Balicki on 10/02/2019.
//  Copyright © 2019 Alistra. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        UserDefaults.standard.synchronize()
    }


}

