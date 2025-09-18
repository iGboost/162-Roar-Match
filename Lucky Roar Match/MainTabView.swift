//
//  MainTabView.swift
//  Roar Match
//
//  Main tab navigation view with 5 tabs
//

import SwiftUI

struct MainTabView: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        ThemedTabView {
            // Game Tab
            GameView()
                .tabItem {
                    Image(systemName: "gamecontroller.fill")
                    Text("Game")
                }
            
            // Achievements Tab
            AchievementsView()
                .tabItem {
                    Image(systemName: "trophy.fill")
                    Text("Achievements")
                }
            
            // Statistics Tab
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Statistics")
                }
            
            // Theme Tab
            ThemeView()
                .tabItem {
                    Image(systemName: "paintbrush.fill")
                    Text("Theme")
                }
            
            // Settings Tab
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
        .ignoresSafeArea(.all) // Ensure full screen coverage
    }
}

struct ThemedTabView<Content: View>: UIViewControllerRepresentable {
    @ObservedObject private var themeManager = ThemeManager.shared
    @ViewBuilder let content: Content
    
    func makeUIViewController(context: Context) -> UITabBarController {
        let tabBarController = UITabBarController()
        
        // Create hosting controllers for each tab
        let gameVC = UIHostingController(rootView: GameView())
        gameVC.tabBarItem = UITabBarItem(title: "Game", image: UIImage(systemName: "gamecontroller.fill"), tag: 0)
        
        let achievementsVC = UIHostingController(rootView: AchievementsView())
        achievementsVC.tabBarItem = UITabBarItem(title: "Achievements", image: UIImage(systemName: "trophy.fill"), tag: 1)
        
        let statisticsVC = UIHostingController(rootView: StatisticsView())
        statisticsVC.tabBarItem = UITabBarItem(title: "Statistics", image: UIImage(systemName: "chart.bar.fill"), tag: 2)
        
        let themeVC = UIHostingController(rootView: ThemeView())
        themeVC.tabBarItem = UITabBarItem(title: "Theme", image: UIImage(systemName: "paintbrush.fill"), tag: 3)
        
        let settingsVC = UIHostingController(rootView: SettingsView())
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape.fill"), tag: 4)
        
        tabBarController.viewControllers = [gameVC, achievementsVC, statisticsVC, themeVC, settingsVC]
        
        // Ensure proper edge-to-edge display
        tabBarController.extendedLayoutIncludesOpaqueBars = true
        tabBarController.edgesForExtendedLayout = .all
        
        updateTabBarAppearance(tabBarController.tabBar)
        
        return tabBarController
    }
    
    func updateUIViewController(_ uiViewController: UITabBarController, context: Context) {
        updateTabBarAppearance(uiViewController.tabBar)
    }
    
    private func updateTabBarAppearance(_ tabBar: UITabBar) {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = themeManager.currentTheme.tabBarBackgroundColor
        
        // Normal item colors
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(themeManager.currentTheme.secondaryTextColor)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(themeManager.currentTheme.secondaryTextColor)
        ]
        
        // Selected item colors
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.luckyGold)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.luckyGold)
        ]
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = UIColor(Color.luckyGold)
    }
}

#Preview {
    MainTabView()
}
