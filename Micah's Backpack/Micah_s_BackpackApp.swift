//
//  Micah_s_BackpackApp.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 12/23/23.
//

import SwiftUI
import Firebase
import UserNotifications
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    var app: Micah_s_BackpackApp?
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        
        //Asking user to allow notifications.
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        /*
        if let url = launchOptions?[.url] as? URL {
            if let result = app?.viewmodel.checkDeepLink(url: url){
            }
        }
         */
        return true
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    

    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if Messaging.messaging().fcmToken != nil {
            Messaging.messaging().subscribe(toTopic: "general")
        }
    }
}

@main
struct Micah_s_BackpackApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var dataController = DataController()
    @StateObject var viewmodel = MyBagViewModel()
    

    var body: some Scene {
        WindowGroup {
            ResponsiveView { prop in
                RootView(layoutProperties: prop)
                    .environment(\.managedObjectContext, dataController.container.viewContext)
                    .environmentObject(dataController)
                    .environmentObject(viewmodel)
                    .onOpenURL { url in
                        viewmodel.checkDeepLink(url: url)
                    }
                    .onAppear {
                        delegate.app = self
                    }
            }
        }
    }
}

@available(iOS 10, *)

extension AppDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        
        completionHandler([[.banner, .badge, .sound]])
    }
    
    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if let deeplink = response.notification.request.content.userInfo["link"] as? String ,
           let url = URL(string: deeplink) {
            guard let result = app?.viewmodel.checkDeepLink(url: url) else {
                return
            }
        }
        
        
        completionHandler()
    }
     
}
