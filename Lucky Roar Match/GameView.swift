//
//  GameView.swift
//  Roar Match
//
//  Main game view with card grid and game controls
//

import SwiftUI

struct GameView: View {
    @StateObject private var gameViewModel = GameViewModel()
    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var showPauseMenu = false
    
    var body: some View {
        ZStack {
            themeManager.currentTheme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header with score and time
                gameHeader
                
                // Game content
                switch gameViewModel.gameState {
                case .menu:
                    menuView
                case .playing, .paused:
                    gamePlayView
                case .completed:
                    gameCompletedView
                case .gameOver:
                    gameOverView
                }
                
                Spacer()
            }
            .padding()
            
            // Effects overlay
            if gameViewModel.showMatchEffect {
                ZStack {
                    GoldenFlashEffect()
                    ParticleSystem(
                        particleCount: 15,
                        colors: [.luckyGold, .warmOrange, .fortuneRed]
                    )
                }
                .allowsHitTesting(false)
            }
            
            if gameViewModel.showComboEffect {
                ZStack {
                    SparkleEffect()
                    ParticleSystem(
                        particleCount: 25,
                        colors: [.luckyGold, .white, .yellow]
                    )
                }
                .allowsHitTesting(false)
            }
            
            if gameViewModel.showMistakeEffect {
                Color.fortuneRed.opacity(0.3)
                    .ignoresSafeArea()
                    .shakeEffect()
                    .allowsHitTesting(false)
            }
        }
        .sheet(isPresented: $showPauseMenu) {
            PauseMenuView(
                onResume: {
                    showPauseMenu = false
                    gameViewModel.resumeGame()
                },
                onRestart: {
                    showPauseMenu = false
                    gameViewModel.startGame(level: gameViewModel.currentLevel)
                },
                onBackToMenu: {
                    showPauseMenu = false
                    gameViewModel.resetGame()
                }
            )
        }
    }
    
    // MARK: - Header
    private var gameHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Score")
                    .font(LuckyFontStyle.caption)
                    .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                Text("\(gameViewModel.currentScore)")
                    .font(LuckyFontStyle.headline)
                    .foregroundColor(.luckyGold)
            }
            
            Spacer()
            
            if gameViewModel.gameState == .playing || gameViewModel.gameState == .paused {
                VStack(spacing: 4) {
                    Text("Time")
                        .font(LuckyFontStyle.caption)
                        .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                    Text(gameViewModel.formattedTime)
                        .font(LuckyFontStyle.headline)
                        .foregroundColor(.fortuneRed)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Level")
                    .font(LuckyFontStyle.caption)
                    .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                Text(gameViewModel.currentLevel.displayName)
                    .font(LuckyFontStyle.caption)
                    .foregroundColor(.warmOrange)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Menu View
    private var menuView: some View {
        VStack(spacing: 30) {
            VStack(spacing: 10) {
                Text("🐅")
                    .font(.system(size: 80))
                    .scaleEffect(1.0)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: true)
                
                Text("Roar Match")
                    .font(LuckyFontStyle.largeTitle)
                    .foregroundColor(.luckyGold)
                    .multilineTextAlignment(.center)
                
                Text("Find matching pairs and unleash your luck!")
                    .font(LuckyFontStyle.body)
                    .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 20) {
                LuckyButton(title: "PLAY GAME") {
                    gameViewModel.startGame(level: .medium)
                }
                
                HStack(spacing: 30) {
                    VStack(spacing: 4) {
                        Text("🏆")
                            .font(.title2)
                        Text("\(StorageManager.shared.gameStatistics.bestScore)")
                            .font(LuckyFontStyle.headline)
                            .foregroundColor(.luckyGold)
                        Text("Best Score")
                            .font(LuckyFontStyle.caption)
                            .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                    }
                    
                    VStack(spacing: 4) {
                        Text("🎯")
                            .font(.title2)
                        Text(String(format: "%.0f%%", StorageManager.shared.gameStatistics.winRate))
                            .font(LuckyFontStyle.headline)
                            .foregroundColor(.fortuneRed)
                        Text("Win Rate")
                            .font(LuckyFontStyle.caption)
                            .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                    }
                    
                    VStack(spacing: 4) {
                        Text("🎮")
                            .font(.title2)
                        Text("\(StorageManager.shared.gameStatistics.gamesPlayed)")
                            .font(LuckyFontStyle.headline)
                            .foregroundColor(.warmOrange)
                        Text("Games")
                            .font(LuckyFontStyle.caption)
                            .foregroundColor(themeManager.currentTheme.secondaryTextColor)
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
    
    // MARK: - Game Play View
    private var gamePlayView: some View {
        VStack(spacing: 20) {
            // Progress bar
            ProgressView(value: gameViewModel.gameProgress)
                .progressViewStyle(LinearProgressViewStyle(tint: .luckyGold))
                .scaleEffect(y: 3)
                .padding(.horizontal)
            
            // Game grid
            let gridSize = gameViewModel.currentLevel.gridSize
            let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: gridSize)
            
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(gameViewModel.cards) { card in
                    LuckyCard(
                        symbol: card.symbol,
                        isFlipped: card.isFlipped,
                        isMatched: card.isMatched,
                        onTap: {
                            gameViewModel.flipCard(card)
                        }
                    )
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
            
            // Game controls
            HStack(spacing: 20) {
                Button("⏸️ Pause") {
                    gameViewModel.pauseGame()
                    showPauseMenu = true
                }
                .font(LuckyFontStyle.body)
                .foregroundColor(.warmOrange)
                
                Spacer()
                
                if gameViewModel.comboCount > 1 {
                    Text("Combo x\(gameViewModel.comboCount)")
                        .font(LuckyFontStyle.headline)
                        .foregroundColor(.luckyGold)
                        .scaleEffect(1.2)
                        .animation(.spring(), value: gameViewModel.comboCount)
                }
                
                Spacer()
                
                Text("Score: \(gameViewModel.currentScore)")
                    .font(LuckyFontStyle.body)
                    .foregroundColor(.luckyGold)
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Game Completed View
    private var gameCompletedView: some View {
        ZStack {
            // Celebration background with particles
            ParticleSystem(
                particleCount: 30,
                colors: [.luckyGold, .warmOrange, .fortuneRed, .white]
            )
            .allowsHitTesting(false)
            
            VStack(spacing: 25) {
                // Animated celebration
                VStack(spacing: 15) {
                    Text("🎉")
                        .font(.system(size: 80))
                        .scaleEffect(1.0)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.3)
                            .repeatCount(3, autoreverses: true),
                            value: true
                        )
                    
                    Text("🐅")
                        .font(.system(size: 60))
                        .scaleEffect(1.0)
                        .animation(
                            .easeInOut(duration: 1.0)
                            .repeatForever(autoreverses: true),
                            value: true
                        )
                }
                
                VStack(spacing: 12) {
                    Text("Congratulations!")
                        .font(LuckyFontStyle.largeTitle)
                        .foregroundColor(.luckyGold)
                        .glowEffect(color: .luckyGold, radius: 10)
                    
                    Text("Level Completed")
                        .font(LuckyFontStyle.title)
                        .foregroundColor(.fortuneRed)
                        .glowEffect(color: .fortuneRed, radius: 5)
                }
                
                // Enhanced stats display
                VStack(spacing: 12) {
                    // Score with special formatting
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Final Score")
                                .font(LuckyFontStyle.caption)
                                .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                            Text("\(gameViewModel.currentScore)")
                                .font(LuckyFontStyle.largeTitle)
                                .foregroundColor(.luckyGold)
                                .glowEffect(color: .luckyGold, radius: 8)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Time")
                                .font(LuckyFontStyle.caption)
                                .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                            Text(gameViewModel.formattedTime)
                                .font(LuckyFontStyle.title)
                                .foregroundColor(.warmOrange)
                        }
                    }
                    
                    Divider()
                        .background(Color.luckyGold.opacity(0.3))
                    
                    // Additional stats
                    if let session = gameViewModel.session {
                        HStack(spacing: 30) {
                            VStack(spacing: 4) {
                                Text("Mistakes")
                                    .font(LuckyFontStyle.caption)
                                    .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                                Text("\(session.mistakes)")
                                    .font(LuckyFontStyle.headline)
                                    .foregroundColor(session.mistakes == 0 ? .green : .fortuneRed)
                            }
                            
                            VStack(spacing: 4) {
                                Text("Matches")
                                    .font(LuckyFontStyle.caption)
                                    .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                                Text("\(session.matches)")
                                    .font(LuckyFontStyle.headline)
                                    .foregroundColor(.luckyGold)
                            }
                            
                            VStack(spacing: 4) {
                                Text("Max Combo")
                                    .font(LuckyFontStyle.caption)
                                    .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                                Text("\(session.maxCombo)")
                                    .font(LuckyFontStyle.headline)
                                    .foregroundColor(.warmOrange)
                            }
                        }
                        
                        // Perfect game bonus indicator
                        if session.mistakes == 0 {
                            HStack {
                                Text("✨")
                                Text("Perfect Game Bonus!")
                                    .font(LuckyFontStyle.body)
                                    .foregroundColor(.green)
                                    .fontWeight(.semibold)
                                Text("✨")
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.green.opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.green.opacity(0.5), lineWidth: 1)
                                    )
                            )
                            .glowEffect(color: .green, radius: 5)
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(themeManager.currentTheme.secondaryBackgroundColor.opacity(0.9))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.luckyGold.opacity(0.5), lineWidth: 2)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                
                // Action buttons
                VStack(spacing: 12) {
                    HStack(spacing: 15) {
                        LuckyButton(title: "Play Again") {
                            gameViewModel.startGame(level: gameViewModel.currentLevel)
                        }
                        
                        LuckyButton(title: "Next Level", style: .secondary) {
                            let nextLevel = nextAvailableLevel()
                            gameViewModel.startGame(level: nextLevel)
                        }
                    }
                    
                    Button("Main Menu") {
                        gameViewModel.resetGame()
                    }
                    .font(LuckyFontStyle.body)
                    .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                }
            }
            .padding()
        }
        .onAppear {
            // Play celebration sound
            SoundManager.shared.playLevelComplete()
            
            // Check for achievements
            checkForNewAchievements()
        }
    }
    
    // MARK: - Game Over View
    private var gameOverView: some View {
        VStack(spacing: 30) {
            Text("😿")
                .font(.system(size: 80))
            
            Text("Game Over")
                .font(LuckyFontStyle.largeTitle)
                .foregroundColor(.fortuneRed)
            
            LuckyButton(title: "Try Again") {
                gameViewModel.startGame(level: gameViewModel.currentLevel)
            }
        }
    }
    
    // MARK: - Helper Methods
    private func nextAvailableLevel() -> GameLevel {
        let allLevels = GameLevel.allCases
        if let currentIndex = allLevels.firstIndex(of: gameViewModel.currentLevel),
           currentIndex + 1 < allLevels.count {
            let nextLevel = allLevels[currentIndex + 1]
            return StorageManager.shared.isLevelUnlocked(nextLevel) ? nextLevel : gameViewModel.currentLevel
        }
        return gameViewModel.currentLevel
    }
    
    private func checkForNewAchievements() {
        // Check if any new achievements were unlocked
        let unlockedAchievements = StorageManager.shared.achievements.filter { $0.isUnlocked }
        
        // Could add special celebration animations for new achievements here
        if !unlockedAchievements.isEmpty {
            // Play achievement sound for any unlocked achievements
            SoundManager.shared.playAchievementUnlocked()
        }
    }
}

// MARK: - Level Selector View
struct LevelSelectorView: View {
    @Binding var selectedLevel: GameLevel
    let onLevelSelected: (GameLevel) -> Void
    @ObservedObject private var storageManager = StorageManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Choose Your Challenge")
                    .font(LuckyFontStyle.largeTitle)
                    .foregroundColor(.luckyGold)
                    .padding(.top)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(GameLevel.allCases, id: \.self) { level in
                        LevelCard(
                            level: level,
                            isUnlocked: storageManager.isLevelUnlocked(level),
                            bestScore: storageManager.gameStatistics.bestScore
                        ) {
                            if storageManager.isLevelUnlocked(level) {
                                onLevelSelected(level)
                            }
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
            .background(themeManager.currentTheme.backgroundGradient)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct LevelCard: View {
    let level: GameLevel
    let isUnlocked: Bool
    let bestScore: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text(levelIcon)
                    .font(.system(size: 40))
                    .opacity(isUnlocked ? 1.0 : 0.3)
                
                Text(level.displayName)
                    .font(LuckyFontStyle.headline)
                    .foregroundColor(isUnlocked ? .luckyGold : .secondary)
                
                if isUnlocked {
                    Text("Best: \(bestScore)")
                        .font(LuckyFontStyle.caption)
                        .foregroundColor(.warmOrange)
                } else {
                    Text("🔒 Locked")
                        .font(LuckyFontStyle.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(isUnlocked ? Color.white.opacity(0.1) : Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(isUnlocked ? Color.luckyGold.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 2)
                    )
            )
        }
        .disabled(!isUnlocked)
    }
    
    private var levelIcon: String {
        switch level {
        case .easy: return "🐱"
        case .medium: return "🐅"
        case .hard: return "🦁"
        case .expert: return "🐉"
        }
    }
}

// MARK: - Pause Menu View
struct PauseMenuView: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    let onResume: () -> Void
    let onRestart: () -> Void
    let onBackToMenu: () -> Void
    
    var body: some View {
        ZStack {
            themeManager.currentTheme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Text("⏸️")
                        .font(.system(size: 80))
                        .scaleEffect(1.0)
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: true)
                    
                    VStack(spacing: 8) {
                        Text("Game Paused")
                            .font(LuckyFontStyle.largeTitle)
                            .foregroundColor(.luckyGold)
                        
                        Text("Take a break and choose your next move")
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
                
                // Menu options
                VStack(spacing: 20) {
                    LuckyButton(title: "▶️ Resume Game") {
                        SoundManager.shared.playButtonTap()
                        onResume()
                    }
                    
                    LuckyButton(title: "🔄 Restart Level", style: .secondary) {
                        SoundManager.shared.playButtonTap()
                        onRestart()
                    }
                    
                    LuckyButton(title: "🏠 Back to Menu", style: .danger) {
                        SoundManager.shared.playButtonTap()
                        onBackToMenu()
                    }
                }
                
                Spacer()
                
                // Game tips
                VStack(spacing: 12) {
                    Text("💡 Tips")
                        .font(LuckyFontStyle.headline)
                        .foregroundColor(.warmOrange)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("🧠")
                            Text("Remember card positions")
                                .font(LuckyFontStyle.caption)
                                .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                        }
                        
                        HStack {
                            Text("⚡")
                            Text("Build combos for bonus points")
                                .font(LuckyFontStyle.caption)
                                .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                        }
                        
                        HStack {
                            Text("🎯")
                            Text("Perfect games unlock achievements")
                                .font(LuckyFontStyle.caption)
                                .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(themeManager.currentTheme.secondaryBackgroundColor.opacity(0.6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.warmOrange.opacity(0.3), lineWidth: 1)
                        )
                )
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            SoundManager.shared.lightHaptic()
        }
    }
}

#Preview {
    GameView()
}
