//
//  ContentView.swift
//  Roar Match
//
//  Main app coordinator view handling app flow
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var storageManager = StorageManager.shared
    @State private var isLoading = true
    @State private var showOnboarding = false
    
    var body: some View {
        ZStack {
            if isLoading {
                LoadingView()
            } else if showOnboarding {
                OnboardingView {
                    withAnimation {
                        showOnboarding = false
                    }
                }
            } else {
                MainTabView()
            }
        }
        .ignoresSafeArea(.all) // Fix white bars by ignoring safe area
        .onAppear {
            initializeApp()
        }
    }
    
    private func initializeApp() {
        // Simulate loading time
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeInOut(duration: 0.5)) {
                isLoading = false
                showOnboarding = !storageManager.hasCompletedOnboarding
            }
        }
    }
}

#Preview {
    ContentView()
}
