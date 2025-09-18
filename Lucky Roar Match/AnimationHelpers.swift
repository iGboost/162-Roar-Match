//
//  AnimationHelpers.swift
//  Roar Match
//
//  Animation utilities and enhanced effects
//

import SwiftUI

// MARK: - Enhanced Card Flip Animation
struct FlipEffect: AnimatableModifier {
    var angle: Double
    
    var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(angle),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.5
            )
            .opacity(angle < 90 ? 1 : 0)
    }
}

// MARK: - Bounce Animation
struct BounceEffect: ViewModifier {
    @State private var bouncing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(bouncing ? 1.2 : 1.0)
            .animation(.interpolatingSpring(stiffness: 300, damping: 10), value: bouncing)
            .onAppear {
                bouncing = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    bouncing = false
                }
            }
    }
}

// MARK: - Pulse Animation
struct PulseEffect: ViewModifier {
    @State private var pulsing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(pulsing ? 1.1 : 1.0)
            .opacity(pulsing ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: pulsing)
            .onAppear {
                pulsing = true
            }
    }
}

// MARK: - Shake Animation
struct ShakeEffect: ViewModifier {
    @State private var shaking = false
    
    func body(content: Content) -> some View {
        content
            .offset(x: shaking ? -5 : 5, y: 0)
            .animation(.easeInOut(duration: 0.1).repeatCount(3, autoreverses: true), value: shaking)
            .onAppear {
                shaking = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    shaking = false
                }
            }
    }
}

// MARK: - Glow Effect
struct GlowEffect: ViewModifier {
    let color: Color
    let radius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.6), radius: radius, x: 0, y: 0)
            .shadow(color: color.opacity(0.4), radius: radius * 2, x: 0, y: 0)
            .shadow(color: color.opacity(0.2), radius: radius * 3, x: 0, y: 0)
    }
}

// MARK: - Floating Animation
struct FloatingEffect: ViewModifier {
    @State private var floating = false
    
    func body(content: Content) -> some View {
        content
            .offset(y: floating ? -10 : 0)
            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: floating)
            .onAppear {
                floating = true
            }
    }
}

// MARK: - Particle System for Celebrations
struct ParticleSystem: View {
    let particleCount: Int
    let colors: [Color]
    @State private var particles: [Particle] = []
    
    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var velocity: CGPoint
        var color: Color
        var life: Double = 1.0
        var size: CGFloat
    }
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(x: particle.x, y: particle.y)
                    .opacity(particle.life)
            }
        }
        .onAppear {
            createParticles()
            animateParticles()
        }
    }
    
    private func createParticles() {
        particles = (0..<particleCount).map { _ in
            Particle(
                x: 200,
                y: 200,
                velocity: CGPoint(
                    x: CGFloat.random(in: -100...100),
                    y: CGFloat.random(in: -150...50)
                ),
                color: colors.randomElement() ?? .luckyGold,
                size: CGFloat.random(in: 4...12)
            )
        }
    }
    
    private func animateParticles() {
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
            for i in particles.indices {
                particles[i].x += particles[i].velocity.x * 0.016
                particles[i].y += particles[i].velocity.y * 0.016
                particles[i].velocity.y += 200 * 0.016 // Gravity
                particles[i].life -= 0.016
            }
            
            particles.removeAll { $0.life <= 0 }
            
            if particles.isEmpty {
                timer.invalidate()
            }
        }
    }
}

// MARK: - View Extensions
extension View {
    func flipEffect(angle: Double) -> some View {
        modifier(FlipEffect(angle: angle))
    }
    
    func bounceEffect() -> some View {
        modifier(BounceEffect())
    }
    
    func pulseEffect() -> some View {
        modifier(PulseEffect())
    }
    
    func shakeEffect() -> some View {
        modifier(ShakeEffect())
    }
    
    func glowEffect(color: Color = .luckyGold, radius: CGFloat = 8) -> some View {
        modifier(GlowEffect(color: color, radius: radius))
    }
    
    func floatingEffect() -> some View {
        modifier(FloatingEffect())
    }
}
