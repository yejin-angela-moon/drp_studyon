//
//  StudyOnApp.swift
//  StudyOn
//
//  Created by Victor Kang on 5/29/24.
//

import SwiftUI
import Firebase

@main
struct StudyOnApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
//                RootView()
                //AuthenticationView()
            }
            //ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    print("Configured Firebase!")
    return true
  }
}
