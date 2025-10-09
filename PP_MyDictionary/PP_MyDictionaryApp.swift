//
//  PP_MyDictionaryApp.swift
//  PP_MyDictionary
//
//  Created by Myung Woo on 8/8/25.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct PP_MyDictionaryApp: App {
    
    @StateObject private var appState = AppState()
    @Environment(\.modelContext) var modelContext
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    init() {
        UIView.appearance().overrideUserInterfaceStyle = .light
    }
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appState)
                .onReceive(NotificationCenter.default.publisher(for: .switchToSecondTab)) {_ in
                    print("Called")
                    appState.tabIndex = 1
                }
        }
        .modelContainer(for: [Vocabulary.self])
        
    }
}

final class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: "Main Scene", sessionRole: connectingSceneSession.role)
        
        return configuration
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound,.badge]) { (granted, error) in
            if granted {
                print("User notifications are allowed!")
            } else {
                print("User notifications are not allowed!")
            }
        }
        
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // Thong bao cho app biet can chuyen tab
        NotificationCenter.default.post(name: .switchToSecondTab, object: nil)
        
        completionHandler()
    }
}

final class AppState: ObservableObject {
    @Published var tabIndex = 0
}

extension Notification.Name {
    static let switchToSecondTab = Notification.Name("switchToSecondTab")
}
