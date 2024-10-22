//
//  NotificationManager.swift
//  Micah's Backpack
//
//  Created by Anthony Du on 4/4/24.
//

import Foundation
import UserNotifications

@MainActor
final class NotificationManager: ObservableObject{
    static let shared = NotificationManager()
    
    @Published private(set) var hasPermission = false
    
    init() {
        Task{
            await getAuthStatus()
        }
    }
    
    func request() async{
        do {
            try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
             await getAuthStatus()
        } catch{
            print(error)
        }
    }
    
    func getAuthStatus() async {
        let status = await UNUserNotificationCenter.current().notificationSettings()
        switch status.authorizationStatus {
        case .authorized, .ephemeral, .provisional:
            hasPermission = true
        default:
            hasPermission = false
        }
    }
    
    
}
