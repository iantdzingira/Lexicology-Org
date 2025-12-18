//
//  Lexicology_OrgApp.swift
//  Lexicology Org
//
//  Created by Ian. T. Dzingira on 23/09/2025.
//
import SwiftUI
import SwiftData

@main
struct LexicologyOrg: App {

    @StateObject private var settings = SettingsManager.shared
    @StateObject var dataManager = LearningDataManager()
    
    var body: some Scene {
        WindowGroup {
            AppRootView()
             
                .preferredColorScheme(settings.isDarkMode ? .dark : .light)
                .environmentObject(dataManager)
        }
        .modelContainer(for: WordEntry.self)
    }
}
