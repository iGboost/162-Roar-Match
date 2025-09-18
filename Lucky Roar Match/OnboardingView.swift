//
//  OnboardingView.swift
//  Roar Match
//
//  Onboarding flow with 3 slides introduction
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @ObservedObject private var storageManager = StorageManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    let onComplete: () -> Void
    
    private let pages = [
        OnboardingPage(
            icon: "🃏",
            title: "Flip Cards to Find Pairs",
            subtitle: "Touch cards to reveal lucky symbols and find matching pairs",
            animation: "cards"
        ),
        OnboardingPage(
            icon: "🧧",
            title: "Collect Lucky Symbols",
            subtitle: "Discover tigers, golden coins, lanterns, dragons and magical amulets",
            animation: "symbols"
        ),
        OnboardingPage(
            icon: "🐅",
            title: "Unleash the Tiger Roar",
            subtitle: "Build combos, earn achievements and become the Fortune Master!",
            animation: "tiger"
        )
    ]
    
    var body: some View {
        ZStack {
            // Background gradient
            themeManager.currentTheme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        completeOnboarding()
                    }
                    .font(LuckyFontStyle.body)
                    .foregroundColor(.secondary)
                    .padding()
                }
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index], pageIndex: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Bottom section
                VStack(spacing: 24) {
                    // Page indicator
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? Color.luckyGold : Color.gray.opacity(0.3))
                                .frame(width: 10, height: 10)
                                .scaleEffect(currentPage == index ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 0.3), value: currentPage)
                        }
                    }
                    
                    // Action buttons
                    HStack(spacing: 20) {
                        if currentPage > 0 {
                            Button("Back") {
                                withAnimation {
                                    currentPage -= 1
                                }
                            }
                            .font(LuckyFontStyle.body)
                            .foregroundColor(.secondary)
                        } else {
                            Spacer()
                        }
                        
                        Spacer()
                        
                        if currentPage < pages.count - 1 {
                            LuckyButton(title: "Next") {
                                withAnimation {
                                    currentPage += 1
                                }
                            }
                        } else {
                            LuckyButton(title: "Let's Play!") {
                                completeOnboarding()
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 50)
            }
        }
    }
    
    private func completeOnboarding() {
        storageManager.hasCompletedOnboarding = true
        onComplete()
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let subtitle: String
    let animation: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    let pageIndex: Int
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Animated content based on page
            animatedContent
            
            // Text content
            VStack(spacing: 20) {
                Text(page.title)
                    .font(LuckyFontStyle.largeTitle)
                    .foregroundColor(.luckyGold)
                    .multilineTextAlignment(.center)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 20)
                    .animation(.easeOut(duration: 0.8).delay(0.3), value: isAnimating)
                
                Text(page.subtitle)
                    .font(LuckyFontStyle.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 20)
                    .animation(.easeOut(duration: 0.8).delay(0.5), value: isAnimating)
            }
            
            Spacer()
        }
        .onAppear {
            withAnimation {
                isAnimating = true
            }
        }
        .onDisappear {
            isAnimating = false
        }
    }
    
    @ViewBuilder
    private var animatedContent: some View {
        switch page.animation {
        case "cards":
            cardsAnimation
        case "symbols":
            symbolsAnimation
        case "tiger":
            tigerAnimation
        default:
            Text(page.icon)
                .font(.system(size: 120))
        }
    }
    
    private var cardsAnimation: some View {
        ZStack {
            // Background cards
            ForEach(0..<3, id: \.self) { index in
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.cardBack)
                    .frame(width: 80, height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.luckyGold, lineWidth: 2)
                    )
                    .offset(
                        x: CGFloat(index - 1) * 90,
                        y: isAnimating ? 0 : 100
                    )
                    .rotationEffect(.degrees(isAnimating ? 0 : 45))
                    .animation(
                        .spring(response: 0.8, dampingFraction: 0.6)
                        .delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
            
            // Flipping card effect
            if isAnimating {
                Text("🐅")
                    .font(.system(size: 40))
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(1.0), value: isAnimating)
            }
        }
    }
    
    private var symbolsAnimation: some View {
        ZStack {
            // Symbols in circular arrangement
            ForEach(Array(Card.symbols.enumerated()), id: \.offset) { index, symbol in
                Text(symbol)
                    .font(.system(size: 40))
                    .offset(
                        x: isAnimating ? cos(Double(index) * .pi / 3) * 80 : 0,
                        y: isAnimating ? sin(Double(index) * .pi / 3) * 80 : 0
                    )
                    .opacity(isAnimating ? 1.0 : 0.3)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .animation(
                        .spring(response: 0.8, dampingFraction: 0.6)
                        .delay(Double(index) * 0.1),
                        value: isAnimating
                    )
            }
            
            // Center glow
            Circle()
                .fill(Color.luckyGold.opacity(0.2))
                .frame(width: isAnimating ? 200 : 50, height: isAnimating ? 200 : 50)
                .blur(radius: 20)
                .animation(.easeInOut(duration: 1.5).delay(0.5), value: isAnimating)
        }
    }
    
    private var tigerAnimation: some View {
        ZStack {
            // Sparkles around tiger
            ForEach(0..<12, id: \.self) { index in
                Circle()
                    .fill(Color.luckyGold)
                    .frame(width: 6, height: 6)
                    .offset(
                        x: isAnimating ? cos(Double(index) * .pi / 6) * 120 : 0,
                        y: isAnimating ? sin(Double(index) * .pi / 6) * 120 : 0
                    )
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .animation(
                        .easeOut(duration: 1.0)
                        .delay(Double(index) * 0.05)
                        .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
            
            // Main tiger
            Text("🐅")
                .font(.system(size: 120))
                .scaleEffect(isAnimating ? 1.1 : 0.8)
                .rotationEffect(.degrees(isAnimating ? 0 : -10))
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isAnimating)
            
            // Roar effect
            if isAnimating {
                Text("ROAR!")
                    .font(LuckyFontStyle.headline)
                    .foregroundColor(.fortuneRed)
                    .offset(y: -80)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.6)
                        .delay(1.0)
                        .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
        }
    }
}

#Preview {
    OnboardingView {
        print("Onboarding completed")
    }
}
