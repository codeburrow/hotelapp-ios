//
//  NotificationManager.swift
//  HotelApp
//
//  Created by Konstantinos Loutas on 10/12/16.
//  Copyright © 2016 Constantine Lutas. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit
import Alamofire
import SwiftyJSON

enum NotificationOption: CustomStringConvertible {
    case mutable_content, content_available
    var description: String {
        switch self {
        case .mutable_content: return "mutable-content"
        case .content_available: return "content-available"
        }
    }
}

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    
    // MARK: - Requesting notifications
    
    func requestNotification(with options: [NotificationOption]) {
        let baseUrl = "https://hotelapp-web.herokuapp.com/push?"
        let url = options.reduce(baseUrl) { (result, option) -> String in
            result + option.description + "=1&"
        }
        print("Requesting notification with url: \(url)")
        Alamofire.request(url).responseString { (response) in
            if let responseString = response.result.value {
                print("Response string: \(responseString)")
            }
        }
    }
    
    // MARK: - Handling notifications
    
    // Respond to user actions on a notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case "yes1":
            print("Yes 1 button pressed")
        case "no1":
            print("No 1 button pressed")
        case "yes2":
            print("Yes 2 button pressed")
        case "no2":
            print("No 2 button pressed")
        default:
            print("Something else was pressed without a specified actionIdentifier")
        }
        completionHandler()
    }
    
    // Present an in-app notification when the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let x = notification.request.content.userInfo
        print("Notification received with payload:")
        print(x)
        completionHandler([.alert, .sound])
    }

    // MARK: - Registering for Push Notifications
    func setUpNotificationsFor(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        registerForRemoteNotifications()
        setupNotificationActionCategories()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func registerForRemoteNotifications() {
        // Registering Notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in /*...*/ }
        // Token registration for remote notifications
        UIApplication.shared.registerForRemoteNotifications()
        // Get user notification settings
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in /*...*/ }
    }
    
    func setupNotificationActionCategories() {
        let yes1Action = UNNotificationAction(identifier: "yes1", title: "Yes 1", options: [])
        let no1Action = UNNotificationAction(identifier: "no1", title: "No 1", options: [])
        let category1 = UNNotificationCategory(identifier: "com.CodeBurrow.HotelApp.notifications.test", actions: [yes1Action, no1Action], intentIdentifiers: [], options: [])
        
        let yes2Action = UNNotificationAction(identifier: "yes2", title: "Yes 2", options: [])
        let no2Action = UNNotificationAction(identifier: "no2", title: "No2 ", options: [])
        let category2 = UNNotificationCategory(identifier: "com.CodeBurrow.HotelApp.notifications.test2", actions: [yes2Action, no2Action], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category1, category2])
    }
    
    // MARK: Register device token on the server
    func registerDeviceToken(_ deviceToken: String, forUserID userID: String) {
        let parameters: Parameters = ["user_id": userID, "user_token": deviceToken]
        Alamofire.request("http://hotelapp-web.herokuapp.com/updateUserToken", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            let responseJSON = JSON(response.result.value)
            if responseJSON["success"] == true {
                print("Successfuly registered device token on Heroku Notification Server with response: \"\(responseJSON["message"])\"")
            } else {
                print("ERROR: Unable to register device token! Error message: \"\(responseJSON["message"])\"")
            }
        }
    }
    
    // Handling errors while registering for remote notification
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for Remote Notifications: \(error.localizedDescription)")
    }
    
}
