//
//  SettingsView.swift
//  Roar Match
//
//  Settings and preferences view
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var storageManager = StorageManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var showResetAlert = false
    @State private var showResetOnboardingAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.currentTheme.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        settingsHeader
                        
                        // Game settings
                        gameSettings
                        
                        // App settings
                        appSettings
                        
                        
                        Spacer(minLength: 100)
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("Reset All Progress", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                storageManager.resetAllProgress()
            }
        } message: {
            Text("This will permanently delete all your game progress, statistics, and achievements. This action cannot be undone.")
        }
        .alert("Reset Tutorial", isPresented: $showResetOnboardingAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                storageManager.resetOnboarding()
            }
        } message: {
            Text("This will show the tutorial again when you next open the app.")
        }
    }
    
    private var settingsHeader: some View {
        VStack(spacing: 16) {
            Text("⚙️")
                .font(.system(size: 60))
            
            VStack(spacing: 8) {
                Text("Settings")
                    .font(LuckyFontStyle.title)
                    .foregroundColor(.luckyGold)
                
                Text("Customize your gaming experience")
                    .font(LuckyFontStyle.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.luckyGold.opacity(0.3), lineWidth: 2)
                )
        )
    }
    
    private var gameSettings: some View {
        SettingsSection(title: "Game Settings", icon: "🎮") {
            SettingsToggle(
                title: "Sound Effects",
                subtitle: "Play sounds during gameplay",
                icon: "🔊",
                isOn: Binding(
                    get: { storageManager.soundEnabled },
                    set: { storageManager.soundEnabled = $0 }
                )
            )
            
            SettingsToggle(
                title: "Haptic Feedback",
                subtitle: "Feel vibrations during gameplay",
                icon: "📳",
                isOn: Binding(
                    get: { storageManager.hapticEnabled },
                    set: { storageManager.hapticEnabled = $0 }
                )
            )
        }
    }
    
    private var appSettings: some View {
        SettingsSection(title: "App Settings", icon: "📱") {
            SettingsButton(
                title: "Reset Tutorial",
                subtitle: "Show the onboarding tutorial again",
                icon: "🎯",
                action: {
                    showResetOnboardingAlert = true
                }
            )
            
            SettingsButton(
                title: "Reset All Progress",
                subtitle: "Delete all game data and start fresh",
                icon: "🗑️",
                isDestructive: true,
                action: {
                    showResetAlert = true
                }
            )
        }
    }
    
}

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(icon)
                    .font(.title2)
                Text(title)
                    .font(LuckyFontStyle.headline)
                    .foregroundColor(.luckyGold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                content
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.luckyGold.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
}

struct SettingsToggle: View {
    let title: String
    let subtitle: String
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Text(icon)
                .font(.title2)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(LuckyFontStyle.body)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(LuckyFontStyle.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: .luckyGold))
        }
        .padding(.vertical, 4)
    }
}

struct SettingsButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let isDestructive: Bool
    let action: () -> Void
    
    init(title: String, subtitle: String, icon: String, isDestructive: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.isDestructive = isDestructive
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Text(icon)
                    .font(.title2)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(LuckyFontStyle.body)
                        .foregroundColor(isDestructive ? .fortuneRed : .primary)
                    
                    Text(subtitle)
                        .font(LuckyFontStyle.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}


#Preview {
    SettingsView()
}
