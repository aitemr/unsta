//
//  AppDelegate+Notifications.swift
//  unsta
//
//  Created by Nurdaulet Bolatov on 5/31/17.
//  Copyright © 2017 ZeroToOneLabs. All rights reserved.
//

import UIKit
import Permission

extension AppDelegate {
    func configureNotifications(_ application: UIApplication) {
        let permission: Permission = .notifications
        permission.presentPrePermissionAlert = true

        let alert = permission.prePermissionAlert
        alert.title   = "Let Access Notifications?"
        alert.message = "This lets you receive notifications about unlocked profiles"
        alert.cancel  = "Not now"
        alert.confirm = "Give Access"

        permission.request { status in
            switch status {
            case .authorized: application.registerForRemoteNotifications()
            default: print("Access for remote notifications denied")
            }
        }
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.reduce("") { $0 + String(format: "%02x", $1) }
        print(token)
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if let aps = userInfo["aps"] as? NSDictionary, let message = aps["alert"] as? String {
            Drop.down(message, state: .success)
        }
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Error occured while registering for notifications \(error.localizedDescription)")
    }
}
