//
//  AchievementsView.swift
//  Roar Match
//
//  Achievements and progress tracking view
//

import SwiftUI

struct AchievementsView: View {
    @ObservedObject private var storageManager = StorageManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var selectedAchievement: Achievement?
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.currentTheme.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header with progress
                        achievementHeader
                        
                        // Achievement grid
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(storageManager.achievements) { achievement in
                                AchievementCard(achievement: achievement) {
                                    selectedAchievement = achievement
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(item: $selectedAchievement) { achievement in
            AchievementDetailView(achievement: achievement)
        }
    }
    
    private var achievementHeader: some View {
        VStack(spacing: 16) {
            // Trophy icon with animation
            Text("🏆")
                .font(.system(size: 60))
                .scaleEffect(1.0)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: true)
            
            VStack(spacing: 8) {
                Text("Your Progress")
                    .font(LuckyFontStyle.title)
                    .foregroundColor(.luckyGold)
                
                Text("\(unlockedCount) of \(totalCount) Achievements")
                    .font(LuckyFontStyle.body)
                    .foregroundColor(.secondary)
            }
            
            // Progress bar
            ProgressView(value: progressPercentage)
                .progressViewStyle(LinearProgressViewStyle(tint: .luckyGold))
                .scaleEffect(y: 3)
                .frame(height: 8)
                .padding(.horizontal, 40)
            
            Text("\(Int(progressPercentage * 100))% Complete")
                .font(LuckyFontStyle.caption)
                .foregroundColor(.warmOrange)
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
        .padding(.horizontal)
    }
    
    private var unlockedCount: Int {
        storageManager.achievements.filter { $0.isUnlocked }.count
    }
    
    private var totalCount: Int {
        storageManager.achievements.count
    }
    
    private var progressPercentage: Double {
        guard totalCount > 0 else { return 0 }
        return Double(unlockedCount) / Double(totalCount)
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Icon with glow effect for unlocked achievements
                ZStack {
                    if achievement.isUnlocked {
                        Circle()
                            .fill(Color.luckyGold.opacity(0.2))
                            .frame(width: 60, height: 60)
                            .scaleEffect(1.2)
                            .blur(radius: 8)
                    }
                    
                    Text(achievement.icon)
                        .font(.system(size: 32))
                        .opacity(achievement.isUnlocked ? 1.0 : 0.3)
                }
                
                VStack(spacing: 4) {
                    Text(achievement.title)
                        .font(LuckyFontStyle.headline)
                        .foregroundColor(achievement.isUnlocked ? .luckyGold : .secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    Text(achievement.description)
                        .font(LuckyFontStyle.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
                
                // Progress indicator
                if !achievement.isUnlocked && achievement.progress > 0 {
                    VStack(spacing: 4) {
                        ProgressView(value: Double(achievement.progress) / Double(achievement.target))
                            .progressViewStyle(LinearProgressViewStyle(tint: .warmOrange))
                            .scaleEffect(y: 2)
                        
                        Text("\(achievement.progress)/\(achievement.target)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                } else if achievement.isUnlocked {
                    Text("✅ Unlocked")
                        .font(.caption)
                        .foregroundColor(.green)
                        .fontWeight(.semibold)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 180)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(achievement.isUnlocked ? Color.luckyGold.opacity(0.1) : Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(
                                achievement.isUnlocked ? Color.luckyGold.opacity(0.5) : Color.gray.opacity(0.3),
                                lineWidth: 2
                            )
                    )
            )
        }
        .scaleEffect(achievement.isUnlocked ? 1.0 : 0.95)
        .animation(.easeInOut(duration: 0.2), value: achievement.isUnlocked)
    }
}

struct AchievementDetailView: View {
    let achievement: Achievement
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Large icon with celebration effect
                    ZStack {
                        if achievement.isUnlocked {
                            ForEach(0..<8, id: \.self) { index in
                                Circle()
                                    .fill(Color.luckyGold.opacity(0.3))
                                    .frame(width: 8, height: 8)
                                    .offset(
                                        x: cos(Double(index) * .pi / 4) * 80,
                                        y: sin(Double(index) * .pi / 4) * 80
                                    )
                                    .animation(
                                        .easeInOut(duration: 2.0)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(index) * 0.1),
                                        value: true
                                    )
                            }
                        }
                        
                        Text(achievement.icon)
                            .font(.system(size: 120))
                            .scaleEffect(achievement.isUnlocked ? 1.1 : 0.8)
                            .opacity(achievement.isUnlocked ? 1.0 : 0.5)
                    }
                    
                    VStack(spacing: 16) {
                        Text(achievement.title)
                            .font(LuckyFontStyle.largeTitle)
                            .foregroundColor(.luckyGold)
                            .multilineTextAlignment(.center)
                        
                        Text(achievement.description)
                            .font(LuckyFontStyle.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Status section
                    VStack(spacing: 12) {
                        if achievement.isUnlocked {
                            HStack {
                                Text("🎉")
                                Text("Achievement Unlocked!")
                                    .font(LuckyFontStyle.headline)
                                    .foregroundColor(.green)
                                Text("🎉")
                            }
                        } else {
                            VStack(spacing: 8) {
                                Text("Progress")
                                    .font(LuckyFontStyle.headline)
                                    .foregroundColor(.warmOrange)
                                
                                ProgressView(value: Double(achievement.progress) / Double(achievement.target))
                                    .progressViewStyle(LinearProgressViewStyle(tint: .luckyGold))
                                    .scaleEffect(y: 3)
                                    .frame(height: 8)
                                
                                Text("\(achievement.progress) / \(achievement.target)")
                                    .font(LuckyFontStyle.body)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white.opacity(0.1))
                            )
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Achievement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.luckyGold)
                }
            }
        }
    }
}

#Preview {
    AchievementsView()
}
