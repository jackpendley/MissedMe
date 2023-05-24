//
//  MissMe.swift
//
//
//  Created by Daniel Herman on 1/24/23.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    return true
  }
}



@main
struct MissMe: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate;
    
    //@StateObject var authManager = FirebaseAuthManager.shared
    //let authManager: FirebaseAuthManager
    //let persistenceController = PersistenceController.shared
    //delegate.application();
    // https://DATABASE_NAME.firebaseio.com
    
    init() {
        FirebaseApp.configure()
        //self.authManager = FirebaseAuthManager.shared
    }
    
        
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}

