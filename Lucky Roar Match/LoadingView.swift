//
//  LoadingView.swift
//  Roar Match
//
//  Loading screen with tiger animation and golden coins
//

import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    @State private var rotationAngle: Double = 0
    @State private var scaleEffect: CGFloat = 1.0
    @State private var showCoins = false
    @ObservedObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        ZStack {
            // Background gradient
            themeManager.currentTheme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Main tiger with animation
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(Color.luckyGold.opacity(0.3))
                        .frame(width: 200, height: 200)
                        .scaleEffect(scaleEffect)
                        .blur(radius: 20)
                    
                    // Rotating coins around tiger
                    if showCoins {
                        ForEach(0..<8, id: \.self) { index in
                            Text("🪙")
                                .font(.system(size: 24))
                                .offset(x: 80)
                                .rotationEffect(.degrees(rotationAngle + Double(index) * 45))
                                .opacity(0.8)
                        }
                    }
                    
                    // Main tiger
                    Text("🐅")
                        .font(.system(size: 120))
                        .scaleEffect(scaleEffect)
                        .rotationEffect(.degrees(isAnimating ? 5 : -5))
                }
                .onAppear {
                    // Start animations
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        scaleEffect = 1.1
                        isAnimating = true
                    }
                    
                    withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                        rotationAngle = 360
                    }
                    
                    // Show coins after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showCoins = true
                        }
                    }
                }
                
                // App title with animation
                VStack(spacing: 16) {
                    Text("Roar Match")
                        .font(LuckyFontStyle.largeTitle)
                        .foregroundColor(.luckyGold)
                        .opacity(isAnimating ? 1.0 : 0.7)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Text("Loading your fortune...")
                        .font(LuckyFontStyle.body)
                        .foregroundColor(.secondary)
                        .opacity(0.8)
                }
                
                Spacer()
                
                // Loading indicator
                VStack(spacing: 16) {
                    // Custom loading bar
                    LoadingBar()
                    
                    // Lucky symbols floating
                    HStack(spacing: 20) {
                        ForEach(["🏮", "🐉", "🧿"], id: \.self) { symbol in
                            Text(symbol)
                                .font(.title2)
                                .opacity(0.6)
                                .offset(y: isAnimating ? -10 : 0)
                                .animation(
                                    .easeInOut(duration: 1.0)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double.random(in: 0...0.5)),
                                    value: isAnimating
                                )
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

struct LoadingBar: View {
    @State private var progress: CGFloat = 0
    @State private var showSparkles = false
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Background
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 8)
            
            // Progress fill with gradient
            RoundedRectangle(cornerRadius: 10)
                .fill(LinearGradient.luckyGradient)
                .frame(width: progress * 250, height: 8)
                .animation(.easeInOut(duration: 0.3), value: progress)
            
            // Sparkles on progress bar
            if showSparkles {
                HStack(spacing: 0) {
                    ForEach(0..<Int(progress * 10), id: \.self) { _ in
                        Circle()
                            .fill(Color.white)
                            .frame(width: 2, height: 2)
                            .offset(y: CGFloat.random(in: -5...5))
                    }
                    Spacer()
                }
                .frame(width: progress * 250)
            }
        }
        .frame(width: 250)
        .onAppear {
            startLoading()
        }
    }
    
    private func startLoading() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if progress < 1.0 {
                progress += 0.02
                
                if progress > 0.3 && !showSparkles {
                    withAnimation {
                        showSparkles = true
                    }
                }
            } else {
                timer.invalidate()
            }
        }
    }
}

struct FloatingSymbol: View {
    let symbol: String
    @State private var yOffset: CGFloat = 0
    @State private var opacity: Double = 0.6
    
    var body: some View {
        Text(symbol)
            .font(.title2)
            .opacity(opacity)
            .offset(y: yOffset)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: Double.random(in: 1.5...2.5))
                    .repeatForever(autoreverses: true)
                ) {
                    yOffset = CGFloat.random(in: -15...15)
                    opacity = Double.random(in: 0.3...0.8)
                }
            }
    }
}

#Preview {
    LoadingView()
}
