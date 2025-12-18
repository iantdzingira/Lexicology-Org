//
//  DeveloperSettings.swift
//  Lexicology Org
//
//  Created by Ian. T. Dzingira on 29/09/2025.
//
import SwiftUI
import UIKit

struct AboutDeveloperView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var hSize
    
    let email = "iantdzingira@gmail.com"
    let linkedInURL = "https://www.linkedin.com/in/ian-t-dzingira-31a76b383"
    let phoneNumber = "+263 780 809 553"
    
    var isRegular: Bool { hSize == .regular }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: isRegular ? 40 : 30) {
                    Image("Developer")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .foregroundColor(.blue)
                        .overlay(Circle().stroke(Color.blue.opacity(0.3), lineWidth: 4))
                        .shadow(radius: 5)
                    
                    Text("Ian T. Dzingira")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Connect with the Developer")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.top, 15)
                            .padding(.leading, 15)
                        
                        List {
                            Link(destination: URL(string: "tel:\(phoneNumber.filter("0123456789+".contains))")!) {
                                HStack {
                                    Image(systemName: "phone.fill")
                                        .foregroundColor(.blue)
                                    Text(phoneNumber)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Link(destination: URL(string: "mailto:\(email)")!) {
                                HStack {
                                    Image(systemName: "envelope.fill")
                                        .foregroundColor(.blue)
                                    Text(email)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Link(destination: URL(string: linkedInURL)!) {
                                HStack {
                                    Image(systemName: "link")
                                        .foregroundColor(.blue)
                                    Text("LinkedIn Profile")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .listStyle(.insetGrouped)
                        .frame(height: 200)
                        .scrollDisabled(true)
                    }
                    .padding(.horizontal, isRegular ? 50 : 0)
                    
                    VStack(spacing: 5) {
                        Text("© 2025 style: All rights reserved.")
                        Text("Developed by Ian. T. Dzingira")
                        Text("App Version: \(Bundle.main.appVersion)")
                    }
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.secondary.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.bottom, 30)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("About Developer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationCompactAdaptation(.none)
        .presentationDetents([.medium, .large])
    }
}

struct ExportDatabaseView: View {
    @Environment(\.dismiss) private var dismiss
    
    private func shareDatabaseFile() {
        let mockData = "--- lexicon_backup_data_\(Date.now.formatted()).json ---"
        let activityVC = UIActivityViewController(activityItems: [mockData], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "square.and.arrow.up.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Database Export")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Your database has been prepared for export. Tap 'Share' to save, AirDrop, or send the file.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                List {
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text("lexicon_backup.json")
                                .font(.headline)
                            Text("25.4 MB • Ready to Share")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .onTapGesture {
                        shareDatabaseFile()
                    }
                }
                .frame(height: 80)
                .scrollDisabled(true)
                .listStyle(.insetGrouped)
                .padding(.horizontal)
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .padding(.top, 40)
            .navigationTitle("Export Database")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Share") {
                        shareDatabaseFile()
                    }
                }
            }
        }
        .presentationCompactAdaptation(.none)
        .presentationDetents([.medium])
    }
}

struct SettingsView: View {
    @ObservedObject private var settings = SettingsManager.shared
    @StateObject private var devSettings = DeveloperSettings.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var showExportSheet = false
    @State private var showClearCacheAlert = false
    @State private var showAboutDeveloperSheet = false
    
    private var versionText: String {
        "Version \(Bundle.main.appVersion) (\(Bundle.main.buildNumber))"
    }
    
    private func shareApp() {
        guard let url = URL(string: "https://apps.apple.com/app/idMY_APP_ID") else { return }
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
    
    private func rateApp() {
        guard let url = URL(string: "https://apps.apple.com/app/idMY_APP_ID?action=write-review") else { return }
        UIApplication.shared.open(url)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                List {
                    Section {
                        Toggle("Dark Mode", isOn: $settings.isDarkMode)
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                    } header: {
                        Text("Appearance")
                    }
                    
                    Section {
                        Toggle("Daily Word Notifications", isOn: $settings.wordOfDayNotifications)
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                    } header: {
                        Text("Features")
                    }
                    
                    Section {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Version")
                                    .foregroundColor(.primary)
                                Text(versionText)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if devSettings.tapCount > 0 {
                                Text("\(devSettings.tapCount)/5")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Capsule().fill(Color.blue.opacity(0.1)))
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            devSettings.handleVersionTap()
                        }
                        
                        Button("Share App") {
                            shareApp()
                        }
                        .foregroundColor(.blue)
                        
                        Button("Rate App") {
                            rateApp()
                        }
                        .foregroundColor(.blue)
                        
                        Button {
                            showAboutDeveloperSheet = true
                        } label: {
                            HStack {
                                Text("About Developer")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                    } header: {
                        Text("About")
                    }
                    
                    if devSettings.isDeveloperModeEnabled {
                        Section {
                            
                            Button {
                                devSettings.exportDatabase()
                                showExportSheet = true
                            } label: {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                        .foregroundColor(.blue)
                                    Text("Export Database")
                                        .foregroundColor(.blue)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Button {
                                showClearCacheAlert = true
                            } label: {
                                HStack {
                                    Image(systemName: "trash")
                                        .foregroundColor(.orange)
                                    Text("Clear Cache")
                                        .foregroundColor(.orange)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Button(role: .destructive) {
                                devSettings.resetDeveloperMode()
                            } label: {
                                HStack {
                                    Image(systemName: "xmark.circle")
                                    Text("Disable Developer Mode")
                                    Spacer()
                                }
                            }
                        } header: {
                            HStack {
                                Text("Developer Options")
                                Spacer()
                                Image(systemName: "hammer.circle.fill")
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    
                    Section {
                        Button("Reset All Settings") {
                            settings.resetSettings()
                            if devSettings.isDeveloperModeEnabled {
                                devSettings.resetDeveloperMode()
                            }
                        }
                        .foregroundColor(.red)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .alert("Developer Mode Enabled! 🎉", isPresented: $devSettings.showDevAlert) {
                Button("Awesome!", role: .cancel) {
                    print(" Developer mode activated!")
                }
            } message: {
                Text("You now have access to developer tools and debugging options.")
            }
            .alert("Clear Cache", isPresented: $showClearCacheAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    devSettings.clearCache()
                }
            } message: {
                Text("This will clear all cached data. This action cannot be undone.")
            }
            .sheet(isPresented: $showExportSheet) {
                ExportDatabaseView()
            }
            .sheet(isPresented: $showAboutDeveloperSheet) {
                AboutDeveloperView()
            }
            .preferredColorScheme(settings.isDarkMode ? .dark : .light)
        }
    }
}

#Preview {
    SettingsView()
}
