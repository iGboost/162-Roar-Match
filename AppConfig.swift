//
//  AppConfig.swift
//  DotCascade
//
//  Created by Edward on 27.10.25.
//

import Foundation
import SwiftUI
import UIKit
import WebKit
import FirebaseCore
import FirebaseFirestore
import SdkPushExpress

// MARK: - CONFIGURATION
struct AppConfig {
    // MARK: - App Identity
    static let appName = "Roar Match"
    static let slogan = "Find Matching Pairs"
    
    // MARK: - External Services
    static let pushExpressAppId = "43640-1437"
    static let registerUserFunction = "https://europe-west1-apps-a354b.cloudfunctions.net/registerUser"
    
    // MARK: - Visual Configuration
    static let gradientColors: [Color] = [
        Color(hex: "#FFD700"),  // Gold
        Color(hex: "#FFA500"),  // Orange
        Color(hex: "#32CD32"),  // Lime Green
        Color(hex: "#228B22")   // Forest Green
    ]
    
    // MARK: - Splash Screen Configuration
    struct SplashScreen {
        static let displayDuration: TimeInterval = 4.0
        static let animationDuration: TimeInterval = 0.8
        static let loadingDotsCount: Int = 3
    }
    
    // MARK: - Onboarding Configuration
    struct Onboarding {
        static let userDefaultsKey = "hasCompletedOnboarding"
        static let animationDuration: TimeInterval = 0.8
        static let privacyPolicyDelay: TimeInterval = 0.5
        
        // Onboarding pages content
        struct Pages {
            static let welcome = OnboardingPageContent(
                title: "Welcome to Roar Match!",
                subtitle: "🐅 Memory Challenge",
                icon: "🐅",
                description: "Test your memory by finding matching pairs of cards. Each match brings you closer to victory and unlocks your fortune!"
            )
            
            static let gameplay = OnboardingPageContent(
                title: "How to Play",
                subtitle: "Tap to Flip",
                icon: "hand.tap.fill",
                description: "Tap cards to flip them and reveal symbols. Remember their positions and find matching pairs. Match all cards to win!"
            )
            
            static let difficulty = OnboardingPageContent(
                title: "Choose Difficulty",
                subtitle: "Challenge Yourself",
                icon: "chart.bar.fill",
                description: "Start with Easy (3×3) or test your skills with Expert (6×6). Higher difficulty means more cards and bigger rewards!"
            )
            
            static let rewards = OnboardingPageContent(
                title: "Unlock Achievements",
                subtitle: "Track Progress",
                icon: "trophy.fill",
                description: "Complete levels, beat high scores, and unlock achievements. Climb the leaderboard and prove your memory mastery!"
            )
            
            static var all: [OnboardingPageContent] {
                return [welcome, gameplay, difficulty, rewards]
            }
        }
    }
    
    // MARK: - Firebase Constants
    private enum Constants {
        static let requestTimeout: TimeInterval = 10.0
        static let resourceTimeout: TimeInterval = 20.0
        static let defaultBundleID = "unknown.bundle.id"
    }
    
    // MARK: - Logging Functions
    static func logSplashScreenEvent(_ message: String) {
        // Silent logging
    }
    
    static func logOnboardingEvent(_ message: String) {
        // Silent logging
    }
    
    static func logFirebaseEvent(_ message: String) {
        // Silent logging
    }
    
    static func printConfiguration() {
        // Silent logging
    }
    
}

// MARK: - Onboarding Page Content Model
struct OnboardingPageContent {
    let title: String
    let subtitle: String
    let icon: String
    let description: String
}

// MARK: - Firebase Manager
struct UserResponse: Decodable {
    let status: Bool
    let privacyPolicy: String
    
    enum CodingKeys: String, CodingKey {
        case status
        case privacyPolicy = "privacy_policy"
    }
}

class FirebaseManager {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    
    // Регистрация пользователя с улучшенной обработкой ошибок
    func registerUser(completion: @escaping (Result<UserResponse, Error>) -> Void) {
        AppConfig.logFirebaseEvent("Starting user registration...")
        
        guard let url = URL(string: AppConfig.registerUserFunction) else {
            let error = NSError(domain: "FirebaseManager",
                              code: 1001,
                              userInfo: [NSLocalizedDescriptionKey: "Invalid URL configuration"])
            AppConfig.logFirebaseEvent("❌ ERROR: Invalid URL configuration")
            completion(.failure(error))
            return
        }
        
        AppConfig.logFirebaseEvent("URL: \(url.absoluteString)")
        
        // Конфигурация запроса с таймаутом
        var request = URLRequest(url: url, timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Безопасное получение идентификаторов
        let bundleID = Bundle.main.bundleIdentifier ?? "unknown.bundle.id"
        let vendorID = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        
        AppConfig.logFirebaseEvent("Bundle ID: \(bundleID)")
        AppConfig.logFirebaseEvent("Vendor ID: \(vendorID)")
        
        let bodyData: [String: Any] = [
            "bundleID": bundleID,
            "identifierForVendor": vendorID
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: bodyData)
            request.httpBody = jsonData
            
            // Создаем сессию с конфигурацией
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 10.0
            config.timeoutIntervalForResource = 20.0
            let session = URLSession(configuration: config)
            
            AppConfig.logFirebaseEvent("Sending request to server...")
            
            session.dataTask(with: request) { data, response, error in
                // Обработка сетевых ошибок
                if let error = error {
                    AppConfig.logFirebaseEvent("❌ Network error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                // Проверка HTTP статуса
                if let httpResponse = response as? HTTPURLResponse {
                    AppConfig.logFirebaseEvent("Response status code: \(httpResponse.statusCode)")
                    guard (200...299).contains(httpResponse.statusCode) else {
                        let error = NSError(domain: "FirebaseManager",
                                          code: httpResponse.statusCode,
                                          userInfo: [NSLocalizedDescriptionKey: "Server error: \(httpResponse.statusCode)"])
                        AppConfig.logFirebaseEvent("❌ Server error: \(httpResponse.statusCode)")
                        completion(.failure(error))
                        return
                    }
                }
                
                guard let data = data else {
                    let error = NSError(domain: "FirebaseManager",
                                      code: 1002,
                                      userInfo: [NSLocalizedDescriptionKey: "No data received"])
                    AppConfig.logFirebaseEvent("❌ No data received from server")
                    completion(.failure(error))
                    return
                }
                
                AppConfig.logFirebaseEvent("Data received: \(data.count) bytes")
                
                do {
                    let decoder = JSONDecoder()
                    let userResponse = try decoder.decode(UserResponse.self, from: data)
                    AppConfig.logFirebaseEvent("✅ Successfully decoded user response")
                    AppConfig.logFirebaseEvent("   • Status: \(userResponse.status)")
                    AppConfig.logFirebaseEvent("   • Privacy Policy URL: \(userResponse.privacyPolicy)")
                    completion(.success(userResponse))
                } catch {
                    AppConfig.logFirebaseEvent("❌ Decoding error: \(error.localizedDescription)")
                    let decodingError = NSError(domain: "FirebaseManager",
                                               code: 1003,
                                               userInfo: [NSLocalizedDescriptionKey: "Failed to decode response: \(error.localizedDescription)"])
                    completion(.failure(decodingError))
                }
            }.resume()
        } catch {
            AppConfig.logFirebaseEvent("❌ JSON serialization error: \(error.localizedDescription)")
            let serializationError = NSError(domain: "FirebaseManager",
                                            code: 1004,
                                            userInfo: [NSLocalizedDescriptionKey: "Failed to serialize request: \(error.localizedDescription)"])
            completion(.failure(serializationError))
        }
    }
}

// MARK: - Privacy ViewController (UIKit)
class PrivacyViewController: UIViewController {
    
    // URL для политики конфиденциальности
    var privacyUrl: String?
    
    // WebView для отображения контента
    private var webView: WKWebView?
    
    override func loadView() {
        super.loadView()
        modalPresentationStyle = .formSheet
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    
    // Конфигурация представления
    func config() {
        guard let privacyLink = privacyUrl else {
            showError("Privacy URL is not available")
            return
        }
        contentView(content: privacyLink, terms: false, parentView: view)
    }
    
    // Создание и настройка WebView с безопасной обработкой URL
    func contentView(content: String, terms: Bool = true, parentView: UIView) {
        // Валидация URL
        guard let url = URL(string: content) else {
            showError("Invalid URL: \(content)")
            return
        }
        
        // Проверка схемы URL для безопасности
        guard url.scheme == "http" || url.scheme == "https" else {
            showError("Only HTTP/HTTPS URLs are allowed")
            return
        }
        
        // Создание WebView с конфигурацией
        let configuration = WKWebViewConfiguration()
        configuration.dataDetectorTypes = [.link, .phoneNumber]
        
        let vView = WKWebView(frame: .zero, configuration: configuration)
        vView.navigationDelegate = self
        
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.httpShouldHandleCookies = true
        
        self.webView = vView
        
        vView.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(vView)
        
        if !terms {
            let navView = navigationView()
            NSLayoutConstraint.activate([
                vView.topAnchor.constraint(equalTo: navView.safeAreaLayoutGuide.bottomAnchor),
                vView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
                vView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
                vView.bottomAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.bottomAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                vView.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor),
                vView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
                vView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
                vView.bottomAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.bottomAnchor)
            ])
        }
        
        vView.load(request)
    }
    
    private func navigationView() -> UIView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stackView.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        let closeButton = UIButton()
        closeButton.addTarget(self, action: #selector(dismissScreen), for: .touchUpInside)
        closeButton.setImage(UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate), for: .normal)
        closeButton.tintColor = .gray
        
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        stackView.addArrangedSubview(UIView())
        stackView.addArrangedSubview(closeButton)
        
        return stackView
    }
    
    @objc private func dismissScreen() {
        dismiss(animated: true)
    }
    
    // Показ ошибки пользователю
    private func showError(_ message: String) {
        // Silent error handling
        
        let errorLabel = UILabel()
        errorLabel.text = "Unable to load content"
        errorLabel.textAlignment = .center
        errorLabel.textColor = .systemGray
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - WKNavigationDelegate
extension PrivacyViewController: WKNavigationDelegate {
    // Обработка ошибок загрузки
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showError("Failed to load: \(error.localizedDescription)")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showError("Navigation failed: \(error.localizedDescription)")
    }
}


