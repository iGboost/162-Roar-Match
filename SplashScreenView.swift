import SwiftUI
import SdkPushExpress

struct SplashScreenView: View {
    var onComplete: () -> Void
    
    @State private var isAnimating = false
    @State private var rotationAngle: Double = 0
    @State private var scale: Double = 0.8
    @State private var opacity: Double = 0
    @State private var ballOffset: CGFloat = -100
    @State private var completeDeadline = false
    @State private var userResponse: UserResponse?
    @State private var hasResponse = false
    @State private var showOnboarding = false
    
    var body: some View {
        ZStack {
            // Background gradient from AppConfig
            LinearGradient(
                colors: AppConfig.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo with animation
                VStack(spacing: 20) {
                    // Animated ball icon
                    ZStack {
                        // Outer ring
                        Circle()
                            .stroke(Color.luckyGold.opacity(0.3), lineWidth: 4)
                            .frame(width: 100, height: 100)
                        
                        // Inner ring with animation
                        Circle()
                            .trim(from: 0, to: 0.3)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.luckyGold, Color.warmOrange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 4, lineCap: .round)
                            )
                            .frame(width: 100, height: 100)
                            .rotationEffect(.degrees(rotationAngle))
                            .animation(
                                .linear(duration: 1.5)
                                .repeatForever(autoreverses: false),
                                value: rotationAngle
                            )
                        
                        // Ball icon with tiger emoji
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [.luckyGold, .warmOrange],
                                        center: .topLeading,
                                        startRadius: 5,
                                        endRadius: 25
                                    )
                                )
                                .frame(width: 50, height: 50)
                                .shadow(color: .luckyGold.opacity(0.5), radius: 10)
                            
                            Text("🐅")
                                .font(.system(size: 28))
                        }
                        .scaleEffect(scale)
                        .opacity(opacity)
                        .animation(
                            .easeInOut(duration: 1.0)
                            .repeatForever(autoreverses: true),
                            value: scale
                        )
                    }
                    
                    // App name with design system styling
                    VStack(spacing: 8) {
                        Text(AppConfig.appName)
                            .font(LuckyFontStyle.largeTitle)
                            .foregroundColor(.luckyGold)
                            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
                        
                        Text(AppConfig.slogan)
                            .font(LuckyFontStyle.body)
                            .foregroundColor(.white.opacity(0.8))
                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                    }
                    .opacity(opacity)
                }
                
                Spacer()
                
                // Loading indicator
                VStack(spacing: 12) {
                    HStack(spacing: 6) {
                        ForEach(0..<AppConfig.SplashScreen.loadingDotsCount) { index in
                            Circle()
                                .fill(Color.luckyGold)
                                .frame(width: 10, height: 10)
                                .scaleEffect(isAnimating ? 1.2 : 0.8)
                                .animation(
                                    .easeInOut(duration: 0.6)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.2),
                                    value: isAnimating
                                )
                        }
                    }
                    
                    Text("Loading...")
                        .font(LuckyFontStyle.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .opacity(opacity)
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            AppConfig.printConfiguration()
            AppConfig.logSplashScreenEvent("========== SPLASH SCREEN STARTED ==========")
            AppConfig.logSplashScreenEvent("View appeared - initializing...")
            AppConfig.logSplashScreenEvent("Display Duration: \(AppConfig.SplashScreen.displayDuration)s")
            AppConfig.logSplashScreenEvent("Animation Duration: \(AppConfig.SplashScreen.animationDuration)s")
            AppConfig.logSplashScreenEvent("Loading Dots: \(AppConfig.SplashScreen.loadingDotsCount)")
            
            startAnimations()
            regProfile()
            
            // Transition after configured duration
            DispatchQueue.main.asyncAfter(deadline: .now() + AppConfig.SplashScreen.displayDuration) {
                AppConfig.logSplashScreenEvent("⏰ Display duration completed (\(AppConfig.SplashScreen.displayDuration)s)")
                completeDeadline = true
                checkAndNavigate()
            }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView(
                isVerified: userResponse?.status ?? true,
                privacyURL: userResponse?.privacyPolicy,
                onComplete: onComplete
            )
        }
    }
    
    private func regProfile() {
        AppConfig.logSplashScreenEvent("Starting Firebase user registration...")
        
        FirebaseManager.shared.registerUser { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    AppConfig.logSplashScreenEvent("✅ User registration successful")
                    AppConfig.logSplashScreenEvent("   • User Status: \(user.status)")
                    AppConfig.logSplashScreenEvent("   • Privacy Policy: \(user.privacyPolicy)")
                    
                    userResponse = user
                    hasResponse = true
                    
                    // Initialize PushExpress if status == false
                    if user.status == false {
                        AppConfig.logSplashScreenEvent("User not verified - initializing PushExpress...")
                        let vendorID = UIDevice.current.identifierForVendor?.uuidString ?? ""
                        do {
                            try PushExpressManager.shared.initialize(appId: AppConfig.pushExpressAppId, essentialsOnly: true)
                            PushExpressManager.shared.requestNotificationsPermission(registerForRemoteNotifications: true)
                            try PushExpressManager.shared.activate(extId: vendorID)
                            AppConfig.logSplashScreenEvent("✅ PushExpress activated with ID: '\(PushExpressManager.shared.externalId)'")
                        } catch {
                            AppConfig.logSplashScreenEvent("⚠️ PushExpress initialization failed: \(error)")
                        }
                    } else {
                        AppConfig.logSplashScreenEvent("User verified - skipping PushExpress")
                    }
                    
                    checkAndNavigate()
                    
                case .failure(let error):
                    AppConfig.logSplashScreenEvent("❌ User registration failed: \(error.localizedDescription)")
                    hasResponse = true
                    checkAndNavigate()
                }
            }
        }
    }
    
    private func checkAndNavigate() {
        AppConfig.logSplashScreenEvent("Checking navigation conditions...")
        AppConfig.logSplashScreenEvent("   • Deadline completed: \(completeDeadline)")
        AppConfig.logSplashScreenEvent("   • Response received: \(hasResponse)")
        
        if completeDeadline && hasResponse {
            // Check if user has completed onboarding using AppConfig key
            let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: AppConfig.Onboarding.userDefaultsKey)
            AppConfig.logSplashScreenEvent("   • Onboarding completed: \(hasCompletedOnboarding)")
            
            if hasCompletedOnboarding {
                // Skip onboarding and go directly to main app
                AppConfig.logSplashScreenEvent("✅ Navigating to main app (onboarding skipped)")
                withAnimation(.easeInOut(duration: AppConfig.SplashScreen.animationDuration)) {
                    onComplete()
                }
            } else {
                // Show onboarding
                AppConfig.logSplashScreenEvent("📖 Showing onboarding flow")
                withAnimation(.easeInOut(duration: AppConfig.SplashScreen.animationDuration)) {
                    showOnboarding = true
                }
            }
        } else {
            AppConfig.logSplashScreenEvent("⏳ Waiting for conditions to complete...")
        }
    }
    
    private func startAnimations() {
        AppConfig.logSplashScreenEvent("Starting animations...")
        
        // Start rotation animation
        rotationAngle = 360
        
        withAnimation(.easeInOut(duration: AppConfig.SplashScreen.animationDuration)) {
            scale = 1.0
            opacity = 1.0
        }
        
        // Start dot animation
        withAnimation(.easeInOut(duration: 0.6)) {
            isAnimating = true
        }
        
        AppConfig.logSplashScreenEvent("✅ Animations started successfully")
    }
}

#Preview {
    SplashScreenView(onComplete: {})
}
