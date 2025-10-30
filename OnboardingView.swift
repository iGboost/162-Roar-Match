//
//  OnboardingView.swift
//  Roar Match
//
//  Created by Edward on 27.10.25.
//

import SwiftUI
import WebKit

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var isAnimating = false
    @State private var showPrivacyPolicy = false
    
    // Parameters from SplashView
    let isVerified: Bool
    let privacyURL: String?
    let onComplete: () -> Void
    
    // Initializer with default parameters for backwards compatibility
    init(isVerified: Bool = false, privacyURL: String? = nil, onComplete: @escaping () -> Void = {}) {
        self.isVerified = isVerified
        self.privacyURL = privacyURL
        self.onComplete = onComplete
    }
    
    // Pages from AppConfig
    private let pages = AppConfig.Onboarding.Pages.all
    
    var body: some View {
        ZStack {
            // Background gradient from AppConfig
            LinearGradient(
                colors: AppConfig.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(
                            page: pages[index],
                            isAnimating: isAnimating
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.5), value: currentPage)
                
                // Page indicators with enhanced design
                HStack(spacing: 12) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: index == currentPage 
                                            ? [Color.luckyGold, Color.warmOrange]
                                            : [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: index == currentPage ? 12 : 10, height: index == currentPage ? 12 : 10)
                                .shadow(
                                    color: index == currentPage ? Color.luckyGold.opacity(0.5) : Color.clear,
                                    radius: 5
                                )
                            
                            if index == currentPage {
                                Circle()
                                    .stroke(Color.luckyGold, lineWidth: 2)
                                    .frame(width: 14, height: 14)
                            }
                        }
                        .scaleEffect(index == currentPage ? 1.3 : 1.0)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentPage)
                    }
                }
                .padding(.vertical, 20)
                
                // Navigation buttons
                HStack(spacing: 16) {
                    if currentPage > 0 {
                        Button(action: {
                            AppConfig.logOnboardingEvent("Back button pressed - page \(currentPage) → \(currentPage - 1)")
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage -= 1
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Back")
                            }
                        }
                        .font(LuckyFontStyle.headline)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.darkNavy.opacity(0.7), Color.darkNavy.opacity(0.5)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.luckyGold.opacity(0.3), lineWidth: 1.5)
                                )
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if currentPage == pages.count - 1 {
                            AppConfig.logOnboardingEvent("'Start Playing' button pressed - completing onboarding")
                            completeOnboarding()
                        } else {
                            AppConfig.logOnboardingEvent("'Next' button pressed - page \(currentPage) → \(currentPage + 1)")
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage += 1
                            }
                        }
                    }) {
                        HStack(spacing: 8) {
                            Text(currentPage == pages.count - 1 ? "Start Playing" : "Next")
                            if currentPage == pages.count - 1 {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 14, weight: .bold))
                            } else {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                        }
                    }
                    .font(LuckyFontStyle.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, currentPage == pages.count - 1 ? 36 : 32)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(
                                LinearGradient(
                                    colors: [Color.luckyGold, Color.warmOrange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white.opacity(0.4), lineWidth: 2)
                            )
                            .shadow(color: Color.luckyGold.opacity(0.6), radius: 15, x: 0, y: 5)
                    )
                    .scaleEffect(currentPage == pages.count - 1 ? 1.05 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            AppConfig.logOnboardingEvent("========== ONBOARDING STARTED ==========")
            AppConfig.logOnboardingEvent("View appeared - initializing...")
            AppConfig.logOnboardingEvent("Total pages: \(pages.count)")
            AppConfig.logOnboardingEvent("Animation duration: \(AppConfig.Onboarding.animationDuration)s")
            AppConfig.logOnboardingEvent("Privacy policy delay: \(AppConfig.Onboarding.privacyPolicyDelay)s")
            
            withAnimation(.easeInOut(duration: AppConfig.Onboarding.animationDuration)) {
                isAnimating = true
            }
            
            AppConfig.logOnboardingEvent("✅ Animations started")
            checkAndShowPrivacyPolicy()
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            if let privacyURL = privacyURL {
                PrivacyWebViewWrapper(url: privacyURL)
            }
        }
    }
    
    // MARK: - Privacy Policy Logic
    private func checkAndShowPrivacyPolicy() {
        AppConfig.logOnboardingEvent("Checking privacy policy requirements...")
        AppConfig.logOnboardingEvent("   • Is Verified: \(isVerified)")
        AppConfig.logOnboardingEvent("   • Privacy URL: \(privacyURL ?? "nil")")
        
        // Show privacy policy if isVerified == false AND URL exists
        if isVerified == false, let url = privacyURL {
            AppConfig.logOnboardingEvent("📄 Privacy policy required - will show after \(AppConfig.Onboarding.privacyPolicyDelay)s")
            // Small delay for smoothness (from AppConfig)
            DispatchQueue.main.asyncAfter(deadline: .now() + AppConfig.Onboarding.privacyPolicyDelay) {
                AppConfig.logOnboardingEvent("📄 Showing privacy policy: \(url)")
                showPrivacyPolicy = true
            }
        } else {
            AppConfig.logOnboardingEvent("✅ Privacy policy not required")
        }
    }
    
    private func completeOnboarding() {
        AppConfig.logOnboardingEvent("========== ONBOARDING COMPLETED ==========")
        // Save onboarding completion using AppConfig key
        UserDefaults.standard.set(true, forKey: AppConfig.Onboarding.userDefaultsKey)
        AppConfig.logOnboardingEvent("✅ Saved to UserDefaults: \(AppConfig.Onboarding.userDefaultsKey) = true")
        AppConfig.logOnboardingEvent("✅ Calling completion handler...")
        onComplete()
    }
}

// MARK: - Onboarding Page View
struct OnboardingPageView: View {
    let page: OnboardingPageContent
    let isAnimating: Bool
    
    @State private var iconScale: Double = 0.8
    @State private var textOpacity: Double = 0
    @State private var textOffset: Double = 30
    
    // Check if icon is emoji (for custom rendering)
    private var isEmojiIcon: Bool {
        page.icon.count == 1 && page.icon.unicodeScalars.first?.properties.isEmoji == true
    }
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon with animation
            ZStack {
                // Outer glow circle
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.luckyGold.opacity(0.2), Color.clear],
                            center: .center,
                            startRadius: 40,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
                
                // Background circle with border
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.luckyGold.opacity(0.3), Color.mainGreen.opacity(0.1)],
                            center: .center,
                            startRadius: 20,
                            endRadius: 80
                        )
                    )
                    .frame(width: 140, height: 140)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color.luckyGold, Color.warmOrange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                    )
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .animation(.easeInOut(duration: 0.8), value: isAnimating)
                
                // Icon or Emoji
                Group {
                    if isEmojiIcon {
                        Text(page.icon)
                            .font(.system(size: 70))
                            .scaleEffect(iconScale)
                            .animation(
                                .easeInOut(duration: 1.2)
                                .repeatForever(autoreverses: true),
                                value: iconScale
                            )
                    } else {
                        Image(systemName: page.icon)
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(.luckyGold)
                            .shadow(color: Color.luckyGold.opacity(0.5), radius: 10)
                    }
                }
                .scaleEffect(iconScale)
                .animation(
                    .easeInOut(duration: 1.2)
                    .repeatForever(autoreverses: true),
                    value: iconScale
                )
                .shadow(color: Color.luckyGold.opacity(0.6), radius: 15, x: 0, y: 5)
                
                // Sparkle effect for emoji icons
                if isEmojiIcon && isAnimating {
                    SparkleEffect()
                }
            }
            
            // Text content
            VStack(spacing: 20) {
                Text(page.title)
                    .font(LuckyFontStyle.largeTitle)
                    .foregroundColor(.luckyGold)
                    .multilineTextAlignment(.center)
                    .opacity(textOpacity)
                    .offset(y: textOffset)
                    .animation(.easeInOut(duration: 0.8).delay(0.2), value: textOpacity)
                    .animation(.easeInOut(duration: 0.8).delay(0.2), value: textOffset)
                    .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
                
                Text(page.subtitle)
                    .font(LuckyFontStyle.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .opacity(textOpacity)
                    .offset(y: textOffset)
                    .animation(.easeInOut(duration: 0.8).delay(0.4), value: textOpacity)
                    .animation(.easeInOut(duration: 0.8).delay(0.4), value: textOffset)
                
                Text(page.description)
                    .font(LuckyFontStyle.body)
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .opacity(textOpacity)
                    .offset(y: textOffset)
                    .animation(.easeInOut(duration: 0.8).delay(0.6), value: textOpacity)
                    .animation(.easeInOut(duration: 0.8).delay(0.6), value: textOffset)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .onAppear {
            if isAnimating {
                withAnimation(.easeInOut(duration: 0.6)) {
                    iconScale = 1.1
                }
                
                withAnimation(.easeInOut(duration: 0.8)) {
                    textOpacity = 1.0
                    textOffset = 0
                }
            }
        }
    }
}

// MARK: - Privacy Web View Wrapper
struct PrivacyWebViewWrapper: View {
    let url: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            WebViewRepresentable(url: url)
                .navigationTitle("Privacy Policy")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

// MARK: - WebView Component
struct WebViewRepresentable: UIViewRepresentable {
    let url: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
