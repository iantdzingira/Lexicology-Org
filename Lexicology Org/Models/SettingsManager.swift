//
//  SettingsManager.swift
//  Lexicology Org
//
//  Created by Ian. T. Dzingira on 18/12/2025.
//
import SwiftUI
import Combine

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @AppStorage("wordOfDayNotifications") var wordOfDayNotifications: Bool = true
    
    func resetSettings() {
        isDarkMode = false
        wordOfDayNotifications = true
    }
}

class DeveloperSettings: ObservableObject {
    static let shared = DeveloperSettings()
    
    @AppStorage("isDeveloperModeEnabled") var isDeveloperModeEnabled: Bool = false
    @AppStorage("developerTapCount") var tapCount: Int = 0
    
    @Published var showDevAlert: Bool = false
    @Published var lastTapTime: Date = Date()
    
    private init() {}
    
    func handleVersionTap() {
        let now = Date()
        if now.timeIntervalSince(lastTapTime) > 3.0 {
            tapCount = 0
        }
        
        lastTapTime = now
        tapCount += 1
        
        if tapCount >= 5 {
            isDeveloperModeEnabled = true
            showDevAlert = true
            tapCount = 0
        }
    }
    
    func resetDeveloperMode() {
        isDeveloperModeEnabled = false
        tapCount = 0
    }
    
    func exportDatabase() {
        print(" Developer: Database export triggered (Pre-share preparation)")
    }
    
    func clearCache() {
        print("🗑️ Developer: Cache cleared")
    }
}

extension Bundle {
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}
