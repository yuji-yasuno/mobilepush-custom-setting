//
//  AppDelegate.swift
//  mc taskforce mobile custom setting
//
//  Created by 楊野勇智 on 2016/01/17.
//  Copyright © 2016年 salesforce.com. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ExactTargetOpenDirectDelegate {
    
    let etAppId = "Put your marketing cloud application id"
    let etAccessToken = "Put your marketing cloud application access token"

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        ETPush.setETLoggerToRequiredState(true)
        var success = false
        do {
            try ETPush.pushManager().configureSDKWithAppID(etAppId, andAccessToken: etAccessToken, withAnalytics: true, andLocationServices: true, andCloudPages: true, withPIAnalytics: true)
            success = true
        } catch let error as NSError {
            print("\(error.description)")
        }
        
        if success {
            
            let yesAction = UIMutableUserNotificationAction()
            yesAction.identifier = "Yes"
            yesAction.title = "YES"
            yesAction.activationMode = .Foreground
            yesAction.authenticationRequired = false
            yesAction.destructive = true
            
            let noAction = UIMutableUserNotificationAction()
            noAction.identifier = "No"
            noAction.title = "NO"
            noAction.activationMode = .Foreground
            noAction.authenticationRequired = false
            noAction.destructive = false
            
            let unknowAction = UIMutableUserNotificationAction()
            unknowAction.identifier = "UnKnown"
            unknowAction.title = "UN-KNOWN"
            unknowAction.activationMode = .Foreground
            unknowAction.authenticationRequired = false
            unknowAction.destructive = false
            
            let category = UIMutableUserNotificationCategory()
            category.identifier = "test_category"
            category.setActions([yesAction, noAction, unknowAction], forContext: .Default)
            
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: (NSSet(object: category)) as? Set<UIUserNotificationCategory>)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            ETPush.pushManager().registerUserNotificationSettings(settings)
            ETPush.pushManager().registerForRemoteNotifications()
            ETPush.pushManager().setOpenDirectDelegate(self)
            ETPush.pushManager().applicationLaunchedWithOptions(launchOptions)
        }
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        print("application:handleActionWithIdentifier:forRemoteNotification")
        print("identifier: \(identifier!)")
        print("userInfo: \(userInfo)")
        ETPush.pushManager().handleNotification(userInfo, forApplicationState: application.applicationState)
        completionHandler()
    }

    // MARK: - Delegates for Push Notification
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        ETPush.pushManager().didRegisterUserNotificationSettings(notificationSettings)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        ETPush.pushManager().registerDeviceToken(deviceToken)
        ETPush.pushManager().setSubscriberKey("taskforce_custom_setting")
        ETPush.pushManager().updateET()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        ETPush.pushManager().applicationDidFailToRegisterForRemoteNotificationsWithError(error)
    }
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print("didReceiveRemoteNotification")
        print("userInfo: \(userInfo)")
        ETPush.pushManager().handleNotification(userInfo, forApplicationState: application.applicationState)
    }

    // MARK: - Delegate of Open Direct
    func shouldDeliverOpenDirectMessageIfAppIsRunning() -> Bool {
        return true
    }
    
    func didReceiveOpenDirectMessageWithContents(payload: String!) {
        print("didReceiveOpenDirectMessageWithContents")
        print("payload: \(payload)")
        dispatch_async(dispatch_get_main_queue(), {
            let landingPage = ETLandingPagePresenter(forLandingPageAt: payload)
            self.window?.rootViewController?.presentViewController(landingPage, animated: true, completion: nil)
        })
    }

}

