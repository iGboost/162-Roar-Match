//
//  Lucky_Roar_MatchApp.swift
//  Roar Match
//
//  Created by 11 on 17.09.2025.
//

import SwiftUI
import FirebaseCore
import SdkPushExpress

@main
struct Lucky_Roar_MatchApp: App {
    @State private var showSplash = true
    @State private var showOnboarding = false
    @ObservedObject private var storageManager = StorageManager.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        setupApp()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if showSplash {
                    SplashScreenView {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showSplash = false
                            // Check if onboarding is needed
                            showOnboarding = !storageManager.hasCompletedOnboarding
                        }
                    }
                    .transition(.opacity)
                    .ignoresSafeArea(.all)
                } else if showOnboarding {
                    OnboardingView {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showOnboarding = false
                        }
                    }
                    .transition(.opacity)
                    .ignoresSafeArea(.all)
                } else {
                    MainTabView()
                        .preferredColorScheme(.light)
                        .statusBarHidden(false)
                        .transition(.opacity)
                        .ignoresSafeArea(.all)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.ignoresSafeArea())
        }
    }

    private func setupApp() {
        // Firebase configuration
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        // PushExpress initialization
        do {
            try PushExpressManager.shared.initialize(
                appId: AppConfig.pushExpressAppId,
                essentialsOnly: true
            )
        } catch {
            // Silent error handling
        }

        // UI appearance setup
        UINavigationBar.appearance().isTranslucent = false
        UITabBar.appearance().isTranslucent = false
    }
}

// MARK: - AppDelegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        return true
    }

    // MARK: - Remote Notifications
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenParts = deviceToken.map { String(format: "%02.2hhx", $0) }
        let token = tokenParts.joined()
        PushExpressManager.shared.transportToken = token
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        // Silent error handling
    }
}
