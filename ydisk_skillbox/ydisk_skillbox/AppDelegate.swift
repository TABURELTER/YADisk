//
//  AppDelegate.swift
//  idk ydisk_skillbox
//
//  Created by Дмитрий Богданов on 28.02.2025.
//

import UIKit
import YandexLoginSDK

//
//class AppDelegate: UIResponder, UIApplicationDelegate {
//    
//    func application(
//        _ application: UIApplication,
//        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//    ) -> Bool {
//    
//        do {
//            let clientID = "yx867bd70c6e0b4d87b677da7e7d7ac01a"
//            try YandexLoginSDK.shared.activate(with: clientID)
//        } catch {
//            print("AppDelegate error = \(error)")
//        }
//        
//        return true
//    }
//    
//    func application(
//        _ app: UIApplication,
//        open url: URL,
//        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
//    ) -> Bool {
//    
//        do {
//            try YandexLoginSDK.shared.handleOpenURL(url)
//        } catch {
//            print("application openURL error = \(error)")
//        }
//        
//        return true
//    }
//    
//    func application(
//        _ application: UIApplication,
//        continue userActivity: NSUserActivity,
//        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
//    ) -> Bool {
//    
//        do {
//            try YandexLoginSDK.shared.handleUserActivity(userActivity)
//        } catch {
//            // handle error
//            print("application handleUserActivity error = \(error)")
//        }
//        
//        return true
//    }
//
//}
//@available(iOS 13.0, *)
//class SceneDelegate: UIResponder, UIWindowSceneDelegate {
//
//    func scene(
//        _ scene: UIScene,
//        openURLContexts URLContexts: Set<UIOpenURLContext>
//    ) {
//        for urlContext in URLContexts {
//            let url = urlContext.url
//            
//            do {
//                try YandexLoginSDK.shared.handleOpenURL(url)
//            } catch {
//                print("application SceneDelegate error = \(error)")
//            }
//        }
//    }
//
//}
