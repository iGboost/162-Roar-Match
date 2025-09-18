//
//  StatisticsView.swift
//  Roar Match
//
//  Game statistics and player progress view
//

import SwiftUI

struct StatisticsView: View {
    @ObservedObject private var storageManager = StorageManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.currentTheme.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        statisticsHeader
                        
                        // Main stats grid
                        mainStatsGrid
                        
                        // Detailed stats
                        detailedStats
                        
                        // Recent performance
                        recentPerformance
                        
                        Spacer(minLength: 100)
                    }
                    .padding()
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var statisticsHeader: some View {
        VStack(spacing: 16) {
            Text("📊")
                .font(.system(size: 60))
            
            VStack(spacing: 8) {
                Text("Your Performance")
                    .font(LuckyFontStyle.title)
                    .foregroundColor(.luckyGold)
                
                Text("Track your progress and achievements")
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
    
    private var mainStatsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatCard(
                icon: "🏆",
                title: "Best Score",
                value: "\(storageManager.gameStatistics.bestScore)",
                color: .luckyGold
            )
            
            StatCard(
                icon: "🎯",
                title: "Win Rate",
                value: String(format: "%.1f%%", storageManager.gameStatistics.winRate),
                color: .fortuneRed
            )
            
            StatCard(
                icon: "🎮",
                title: "Games Played",
                value: "\(storageManager.gameStatistics.gamesPlayed)",
                color: .warmOrange
            )
            
            StatCard(
                icon: "✨",
                title: "Perfect Games",
                value: "\(storageManager.gameStatistics.perfectGames)",
                color: .green
            )
        }
    }
    
    private var detailedStats: some View {
        VStack(spacing: 16) {
            Text("Detailed Statistics")
                .font(LuckyFontStyle.headline)
                .foregroundColor(.luckyGold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                StatRow(
                    title: "Total Score",
                    value: "\(storageManager.gameStatistics.totalScore)",
                    icon: "💰"
                )
                
                StatRow(
                    title: "Average Score",
                    value: String(format: "%.0f", storageManager.gameStatistics.averageScore),
                    icon: "📈"
                )
                
                StatRow(
                    title: "Games Won",
                    value: "\(storageManager.gameStatistics.gamesWon)",
                    icon: "🏅"
                )
                
                StatRow(
                    title: "Current Streak",
                    value: "\(storageManager.gameStatistics.currentStreak)",
                    icon: "🔥"
                )
                
                StatRow(
                    title: "Longest Streak",
                    value: "\(storageManager.gameStatistics.longestStreak)",
                    icon: "⭐"
                )
                
                StatRow(
                    title: "Total Matches",
                    value: "\(storageManager.gameStatistics.totalMatches)",
                    icon: "🎯"
                )
                
                StatRow(
                    title: "Error Rate",
                    value: String(format: "%.1f%%", storageManager.gameStatistics.errorRate),
                    icon: "⚠️"
                )
                
                if storageManager.gameStatistics.bestTime > 0 {
                    StatRow(
                        title: "Best Time",
                        value: formatTime(storageManager.gameStatistics.bestTime),
                        icon: "⏱️"
                    )
                    
                    StatRow(
                        title: "Average Time",
                        value: formatTime(storageManager.gameStatistics.averageTime),
                        icon: "⏰"
                    )
                }
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
    
    private var recentPerformance: some View {
        VStack(spacing: 16) {
            Text("Recent Performance")
                .font(LuckyFontStyle.headline)
                .foregroundColor(.luckyGold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                PerformanceIndicator(
                    title: "Accuracy",
                    percentage: max(0, 100 - storageManager.gameStatistics.errorRate),
                    color: .green
                )
                
                PerformanceIndicator(
                    title: "Consistency",
                    percentage: min(100, Double(storageManager.gameStatistics.currentStreak) * 10),
                    color: .luckyGold
                )
                
                PerformanceIndicator(
                    title: "Progress",
                    percentage: storageManager.completionPercentage(),
                    color: .fortuneRed
                )
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
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Text(icon)
                .font(.system(size: 32))
            
            VStack(spacing: 4) {
                Text(value)
                    .font(LuckyFontStyle.title)
                    .foregroundColor(color)
                    .fontWeight(.bold)
                
                Text(title)
                    .font(LuckyFontStyle.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(color.opacity(0.5), lineWidth: 2)
                )
        )
    }
}

struct StatRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Text(icon)
                .font(.title2)
            
            Text(title)
                .font(LuckyFontStyle.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(LuckyFontStyle.body)
                .foregroundColor(.luckyGold)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 4)
    }
}

struct PerformanceIndicator: View {
    let title: String
    let percentage: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(title)
                    .font(LuckyFontStyle.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(String(format: "%.1f%%", percentage))
                    .font(LuckyFontStyle.body)
                    .foregroundColor(color)
                    .fontWeight(.semibold)
            }
            
            ProgressView(value: percentage / 100.0)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
                .scaleEffect(y: 2)
        }
    }
}

#Preview {
    StatisticsView()
}
