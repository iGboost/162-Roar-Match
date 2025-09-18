//
//  SoundManager.swift
//  Roar Match
//
//  Sound effects and haptic feedback manager
//

import SwiftUI
import AVFoundation
import AudioToolbox

class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    private var audioPlayer: AVAudioPlayer?
    private let storageManager = StorageManager.shared
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    // MARK: - Sound Effects (Using System Sounds)
    func playCardFlip() {
        guard storageManager.soundEnabled else { return }
        // System sound for card flip
        AudioServicesPlaySystemSound(1104) // Pop sound
    }
    
    func playMatch() {
        guard storageManager.soundEnabled else { return }
        // System sound for successful match
        AudioServicesPlaySystemSound(1057) // Success sound
        
        // Add haptic feedback
        if storageManager.hapticEnabled {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
    }
    
    func playCombo() {
        guard storageManager.soundEnabled else { return }
        // System sound for combo
        AudioServicesPlaySystemSound(1016) // Chime sound
        
        // Strong haptic feedback for combo
        if storageManager.hapticEnabled {
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
        }
    }
    
    func playMistake() {
        guard storageManager.soundEnabled else { return }
        // System sound for mistake
        AudioServicesPlaySystemSound(1053) // Error sound
        
        // Haptic feedback for mistake
        if storageManager.hapticEnabled {
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.error)
        }
    }
    
    func playLevelComplete() {
        guard storageManager.soundEnabled else { return }
        // System sound for level completion
        AudioServicesPlaySystemSound(1025) // Achievement sound
        
        // Success haptic feedback
        if storageManager.hapticEnabled {
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.success)
        }
    }
    
    func playAchievementUnlocked() {
        guard storageManager.soundEnabled else { return }
        // System sound for achievement
        AudioServicesPlaySystemSound(1013) // Bell sound
        
        // Achievement haptic pattern
        if storageManager.hapticEnabled {
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                impactFeedback.impactOccurred()
            }
        }
    }
    
    func playTigerRoar() {
        guard storageManager.soundEnabled else { return }
        // Special sound for big combos or achievements
        AudioServicesPlaySystemSound(1009) // Bell tower sound (closest to roar)
        
        // Tiger roar haptic pattern
        if storageManager.hapticEnabled {
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            for i in 0..<3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                    impactFeedback.impactOccurred()
                }
            }
        }
    }
    
    func playButtonTap() {
        guard storageManager.soundEnabled else { return }
        // Light button tap sound
        AudioServicesPlaySystemSound(1104)
        
        // Light haptic feedback
        if storageManager.hapticEnabled {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
    }
    
    // MARK: - Haptic Only
    func lightHaptic() {
        guard storageManager.hapticEnabled else { return }
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    func mediumHaptic() {
        guard storageManager.hapticEnabled else { return }
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    func heavyHaptic() {
        guard storageManager.hapticEnabled else { return }
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
}

// MARK: - Enhanced Button with Sound
struct SoundButton<Content: View>: View {
    let action: () -> Void
    @ViewBuilder let content: Content
    
    var body: some View {
        Button(action: {
            SoundManager.shared.playButtonTap()
            action()
        }) {
            content
        }
    }
}

// MARK: - Enhanced LuckyButton with Sound
struct EnhancedLuckyButton: View {
    let title: String
    let action: () -> Void
    var style: LuckyButton.ButtonStyle = .primary
    
    var body: some View {
        SoundButton(action: action) {
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
