//
//  DesignSystem.swift
//  Roar Match
//
//  Design system with colors, fonts, and UI components for Lucky Fortune theme
//

import SwiftUI

// MARK: - Colors
extension Color {
    // Lucky Fortune Theme Colors
    static let luckyGold = Color(red: 1.0, green: 0.84, blue: 0.0) // #FFD700
    static let fortuneRed = Color(red: 0.9, green: 0.0, blue: 0.15) // #E60026
    static let warmOrange = Color(red: 1.0, green: 0.48, blue: 0.0) // #FF7A00
    
    // Supporting Colors
    static let darkGold = Color(red: 0.8, green: 0.65, blue: 0.0)
    static let lightGold = Color(red: 1.0, green: 0.95, blue: 0.7)
    static let cardBack = Color(red: 0.95, green: 0.85, blue: 0.4)
    
    // Theme Variants
    static let nightTheme = Color(red: 0.1, green: 0.1, blue: 0.2)
    static let dayTheme = Color.white
    static let goldenGlow = Color.luckyGold.opacity(0.1)
}

// MARK: - Gradients
extension LinearGradient {
    static let luckyGradient = LinearGradient(
        colors: [Color.luckyGold, Color.fortuneRed],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cardGradient = LinearGradient(
        colors: [Color.lightGold, Color.luckyGold],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let backgroundGradient = LinearGradient(
        colors: [Color.goldenGlow, Color.dayTheme],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Typography
struct LuckyFontStyle {
    static let largeTitle = Font.custom("BebasNeue-Regular", size: 38)
    static let title = Font.custom("BebasNeue-Regular", size: 32)
    static let headline = Font.custom("BebasNeue-Regular", size: 26)
    static let body = Font.custom("BebasNeue-Regular", size: 20)
    static let caption = Font.custom("BebasNeue-Regular", size: 16)
    
    // Fallback to system fonts if custom font fails to load
    static let largeTitleFallback = Font.system(size: 34, weight: .bold, design: .default)
    static let titleFallback = Font.system(size: 28, weight: .bold, design: .default)
    static let headlineFallback = Font.system(size: 22, weight: .semibold, design: .default)
    static let bodyFallback = Font.system(size: 17, weight: .regular, design: .default)
    static let captionFallback = Font.system(size: 14, weight: .light, design: .default)
}

// MARK: - UI Components
struct LuckyButton: View {
    let title: String
    let action: () -> Void
    var style: ButtonStyle = .primary
    
    enum ButtonStyle {
        case primary, secondary, danger
        
        var colors: [Color] {
            switch self {
            case .primary: return [Color.luckyGold, Color.fortuneRed]
            case .secondary: return [Color.lightGold, Color.darkGold]
            case .danger: return [Color.fortuneRed, Color.warmOrange]
            }
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(LuckyFontStyle.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: style.colors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(25)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        }
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: false)
    }
}

struct LuckyCard: View {
    let symbol: String
    let isFlipped: Bool
    let isMatched: Bool
    let onTap: () -> Void
    @ObservedObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isMatched ? Color.luckyGold.opacity(0.3) : themeManager.currentTheme.cardBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.luckyGold, lineWidth: 2)
                    )
                
                if isFlipped || isMatched {
                    Text(symbol)
                        .font(.system(size: 32))
                        .scaleEffect(isMatched ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isMatched)
                } else {
                    // Card back design with Asian pattern
                    ZStack {
                        themeManager.currentTheme.cardBackgroundColor
                            .cornerRadius(10)
                        
                        VStack(spacing: 4) {
                            Text("🐅")
                                .font(.system(size: 20))
                                .opacity(0.6)
                            Text("🪙")
                                .font(.system(size: 16))
                                .opacity(0.4)
                        }
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .rotation3DEffect(
            .degrees(isFlipped ? 0 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.easeInOut(duration: 0.3), value: isFlipped)
    }
}

// MARK: - Animations
struct SparkleEffect: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { index in
                Circle()
                    .fill(Color.luckyGold)
                    .frame(width: 4, height: 4)
                    .offset(
                        x: animate ? CGFloat.random(in: -50...50) : 0,
                        y: animate ? CGFloat.random(in: -50...50) : 0
                    )
                    .opacity(animate ? 0 : 1)
                    .animation(
                        .easeOut(duration: 1.0).delay(Double(index) * 0.1),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

struct GoldenFlashEffect: View {
    @State private var animate = false
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [Color.luckyGold.opacity(0.8), Color.clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 50
                )
            )
            .scaleEffect(animate ? 2.0 : 0.1)
            .opacity(animate ? 0 : 1)
            .animation(.easeOut(duration: 0.6), value: animate)
            .onAppear {
                animate = true
            }
    }
}

// MARK: - Theme Manager
enum AppTheme: String, CaseIterable {
    case day = "Day"
    case night = "Night"
    case goldenGlow = "Golden Glow"
    
    var backgroundColor: Color {
        switch self {
        case .day: return .white
        case .night: return Color(red: 0.1, green: 0.1, blue: 0.15)
        case .goldenGlow: return Color(red: 1.0, green: 0.98, blue: 0.9) // Warm cream background
        }
    }
    
    var secondaryBackgroundColor: Color {
        switch self {
        case .day: return Color(red: 0.95, green: 0.95, blue: 0.97)
        case .night: return Color(red: 0.15, green: 0.15, blue: 0.2)
        case .goldenGlow: return Color(red: 0.98, green: 0.94, blue: 0.85) // Slightly darker cream
        }
    }
    
    var textColor: Color {
        switch self {
        case .day: return .black
        case .night: return .white
        case .goldenGlow: return Color(red: 0.3, green: 0.2, blue: 0.1) // Dark brown text
        }
    }
    
    var secondaryTextColor: Color {
        switch self {
        case .day: return .gray
        case .night: return Color(red: 0.7, green: 0.7, blue: 0.7)
        case .goldenGlow: return Color(red: 0.6, green: 0.5, blue: 0.4) // Warm brown
        }
    }
    
    var cardBackgroundColor: Color {
        switch self {
        case .day: return Color(red: 0.95, green: 0.85, blue: 0.4)
        case .night: return Color(red: 0.4, green: 0.35, blue: 0.2)
        case .goldenGlow: return Color(red: 1.0, green: 0.9, blue: 0.6) // Brighter golden cards
        }
    }
    
    var tabBarBackgroundColor: UIColor {
        switch self {
        case .day: return UIColor.systemBackground
        case .night: return UIColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 0.95)
        case .goldenGlow: return UIColor(red: 1.0, green: 0.98, blue: 0.9, alpha: 0.95)
        }
    }
    
    var backgroundGradient: LinearGradient {
        switch self {
        case .day:
            return LinearGradient(
                colors: [Color.white, Color(red: 0.98, green: 0.98, blue: 1.0)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .night:
            return LinearGradient(
                colors: [Color(red: 0.05, green: 0.05, blue: 0.1), Color(red: 0.1, green: 0.1, blue: 0.15)],
                startPoint: .top,
                endPoint: .bottom
            )
        case .goldenGlow:
            return LinearGradient(
                colors: [Color(red: 1.0, green: 0.95, blue: 0.8), Color(red: 1.0, green: 0.98, blue: 0.9)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}
