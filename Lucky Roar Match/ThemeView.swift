//
//  ThemeView.swift
//  Roar Match
//
//  Theme selection and customization view
//

import SwiftUI

struct ThemeView: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.currentTheme.backgroundGradient
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.5), value: themeManager.currentTheme)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        themeHeader
                        
                        // Theme selection
                        themeSelection
                        
                        // Preview section
                        themePreview
                        
                        Spacer(minLength: 100)
                    }
                    .padding()
                }
            }
            .navigationTitle("Themes")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    
    private var themeHeader: some View {
        VStack(spacing: 16) {
            Text("🎨")
                .font(.system(size: 60))
                .scaleEffect(1.0)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: true)
            
            VStack(spacing: 8) {
                Text("Choose Your Style")
                    .font(LuckyFontStyle.title)
                    .foregroundColor(themeManager.currentTheme.textColor)
                
                Text("Customize the look and feel of your game")
                    .font(LuckyFontStyle.body)
                    .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(themeManager.currentTheme.secondaryBackgroundColor.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.luckyGold.opacity(0.3), lineWidth: 2)
                )
        )
    }
    
    private var themeSelection: some View {
        VStack(spacing: 16) {
            Text("Available Themes")
                .font(LuckyFontStyle.headline)
                .foregroundColor(themeManager.currentTheme.textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 16) {
                ForEach(AppTheme.allCases, id: \.self) { theme in
                    ThemeCard(
                        theme: theme,
                        isSelected: themeManager.currentTheme == theme,
                        currentTheme: themeManager.currentTheme
                    ) {
                        themeManager.setTheme(theme)
                    }
                }
            }
        }
    }
    
    private var themePreview: some View {
        VStack(spacing: 16) {
            Text("Preview")
                .font(LuckyFontStyle.headline)
                .foregroundColor(themeManager.currentTheme.textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 16) {
                // Sample game elements preview
                HStack(spacing: 12) {
                    ForEach(0..<3, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(themeManager.currentTheme.cardBackgroundColor)
                        .frame(width: 60, height: 60)
                            .overlay(
                                Text(["🐅", "🪙", "🏮"][index])
                                    .font(.title2)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.luckyGold, lineWidth: 1)
                            )
                    }
                }
                
                // Sample UI elements
                VStack(spacing: 12) {
                    HStack {
                        Text("Score: 1,250")
                            .font(LuckyFontStyle.body)
                            .foregroundColor(.luckyGold)
                        
                        Spacer()
                        
                        Text("Time: 02:45")
                            .font(LuckyFontStyle.body)
                            .foregroundColor(.fortuneRed)
                    }
                    
                    Button("Sample Button") {}
                        .font(LuckyFontStyle.body)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(LinearGradient.luckyGradient)
                        .cornerRadius(20)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(themeManager.currentTheme.secondaryBackgroundColor.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.luckyGold.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
}

struct ThemeCard: View {
    let theme: AppTheme
    let isSelected: Bool
    let currentTheme: AppTheme
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Theme preview
                VStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(theme.backgroundColor)
                        .frame(width: 60, height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.luckyGold.opacity(0.5), lineWidth: 1)
                        )
                        .overlay(
                            VStack(spacing: 2) {
                                Circle()
                                    .fill(Color.luckyGold)
                                    .frame(width: 8, height: 8)
                                HStack(spacing: 2) {
                                    Rectangle()
                                        .fill(theme.textColor.opacity(0.6))
                                        .frame(width: 12, height: 2)
                                    Rectangle()
                                        .fill(theme.textColor.opacity(0.4))
                                        .frame(width: 8, height: 2)
                                }
                            }
                        )
                    
                    Text(themeIcon)
                        .font(.title2)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(theme.rawValue)
                        .font(LuckyFontStyle.headline)
                        .foregroundColor(currentTheme.textColor)
                    
                    Text(themeDescription)
                        .font(LuckyFontStyle.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.luckyGold)
                        .font(.title2)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.secondary)
                        .font(.title2)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(currentTheme == .night ? 0.1 : 0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(
                                isSelected ? Color.luckyGold : Color.gray.opacity(0.3),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    private var themeIcon: String {
        switch theme {
        case .day: return "☀️"
        case .night: return "🌙"
        case .goldenGlow: return "✨"
        }
    }
    
    private var themeDescription: String {
        switch theme {
        case .day: return "Bright and clean interface"
        case .night: return "Dark mode for comfortable play"
        case .goldenGlow: return "Warm golden theme with lucky vibes"
        }
    }
}

#Preview {
    ThemeView()
}
