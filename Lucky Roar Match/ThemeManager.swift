//
//  ThemeManager.swift
//  Roar Match
//
//  Global theme manager for real-time theme switching
//

import SwiftUI

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: AppTheme {
        didSet {
            StorageManager.shared.selectedTheme = currentTheme
            updateTabBarAppearance()
        }
    }
    
    private init() {
        self.currentTheme = StorageManager.shared.selectedTheme
        updateTabBarAppearance()
    }
    
    func setTheme(_ theme: AppTheme) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentTheme = theme
        }
    }
    
    private func updateTabBarAppearance() {
        DispatchQueue.main.async {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = self.currentTheme.tabBarBackgroundColor
            
            // Normal item colors
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(self.currentTheme.secondaryTextColor)
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor(self.currentTheme.secondaryTextColor)
            ]
            
            // Selected item colors
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.luckyGold)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor(Color.luckyGold)
            ]
            
            // Apply to all existing tab bars immediately
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
            UITabBar.appearance().tintColor = UIColor(Color.luckyGold)
            
            // Force update all existing tab bars
            for window in UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).flatMap({ $0.windows }) {
                self.updateTabBarsInView(window)
            }
        }
    }
    
    private func updateTabBarsInView(_ view: UIView) {
        if let tabBar = view as? UITabBar {
            tabBar.standardAppearance = UITabBar.appearance().standardAppearance
            tabBar.scrollEdgeAppearance = UITabBar.appearance().scrollEdgeAppearance
            tabBar.tintColor = UITabBar.appearance().tintColor
        }
        
        for subview in view.subviews {
            updateTabBarsInView(subview)
        }
    }
}

// MARK: - Theme-aware Views
struct ThemedBackground: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        themeManager.currentTheme.backgroundGradient
            .ignoresSafeArea()
    }
}

struct ThemedCard<Content: View>: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    @ViewBuilder let content: Content
    
    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(themeManager.currentTheme.secondaryBackgroundColor.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.luckyGold.opacity(0.3), lineWidth: 1)
                    )
            )
    }
}

struct ThemedText: View {
    let text: String
    let style: Font
    let isSecondary: Bool
    
    @ObservedObject private var themeManager = ThemeManager.shared
    
    init(_ text: String, style: Font = LuckyFontStyle.body, isSecondary: Bool = false) {
        self.text = text
        self.style = style
        self.isSecondary = isSecondary
    }
    
    var body: some View {
        Text(text)
            .font(style)
            .foregroundColor(isSecondary ? themeManager.currentTheme.secondaryTextColor : themeManager.currentTheme.textColor)
    }
}

// MARK: - View Extensions
extension View {
    func themedBackground() -> some View {
        ZStack {
            ThemedBackground()
            self
        }
    }
    
    func themedCard() -> some View {
        ThemedCard {
            self
        }
    }
}
