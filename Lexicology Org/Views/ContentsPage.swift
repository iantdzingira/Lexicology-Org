//
//  ContentView.swift
//  Lexicology Org
//
//  Created by Ian. T. Dzingira on 24/06/2025.
//
import SwiftUI
import UIKit
import Foundation

extension Color {
    static let primaryBlue = Color(red: 0.1, green: 0.3, blue: 0.8)
    static let accentBlue = Color(red: 0.27, green: 0.55, blue: 0.80)
    static let cardBackground = Color(uiColor: .systemBackground)
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct DashboardStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct DashboardFeatureCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(color)
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

struct ContentsPage: View {
    
    @EnvironmentObject var dataManager: LearningDataManager
    @Environment(\.horizontalSizeClass) var hSize
    @Environment(\.verticalSizeClass) var vSize
    
    @State private var showExitConfirmation = false
    
    var layout: DeviceLayout {
        DeviceLayout(horizontal: hSize, vertical: vSize)
    }
    
    private var maxContentWidth: CGFloat? {
        layout.allowsSplitView ? 800 : nil
    }
    
    private var featureGridColumns: [GridItem] {
        let count = layout.allowsSplitView ? 3 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 16), count: count)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Lexicology Dashboard")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(.primaryBlue)
                        
                        Text("Quick access to your vocabulary tools.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if layout.allowsSplitView {
                        HStack(spacing: 16) {
                            DashboardStatCard(
                                title: "Words Learned",
                                value: "\(dataManager.wordsLearned)",
                                icon: "text.book.closed",
                                color: .primaryBlue
                            )
                            DashboardStatCard(
                                title: "Current Streak",
                                value: "\(dataManager.currentStreak) \(dataManager.currentStreak == 1 ? "day" : "days")",
                                icon: "flame.fill",
                                color: .orange
                            )
                        }
                    } else {
                        VStack(spacing: 16) {
                            DashboardStatCard(
                                title: "Words Learned",
                                value: "\(dataManager.wordsLearned)",
                                icon: "text.book.closed",
                                color: .primaryBlue
                            )
                            DashboardStatCard(
                                title: "Current Streak",
                                value: "\(dataManager.currentStreak) \(dataManager.currentStreak == 1 ? "day" : "days")",
                                icon: "flame.fill",
                                color: .orange
                            )
                        }
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Core Features")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: featureGridColumns, spacing: 16) {
                            
                            NavigationLink(destination: WordDictionaryView()) {
                                DashboardFeatureCard(
                                    title: "Local Dictionary",
                                    subtitle: "Browse words",
                                    icon: "books.vertical.fill",
                                    color: .indigo
                                )
                            }
                            .buttonStyle(ScaleButtonStyle())
                            
                            NavigationLink(destination: WordsCreationParent()) {
                                DashboardFeatureCard(
                                    title: "My Words",
                                    subtitle: "Your collection",
                                    icon: "person.crop.circle.badge.plus",
                                    color: Color.primaryBlue
                                )
                            }
                            .buttonStyle(ScaleButtonStyle())
                            
                            NavigationLink(destination: GoogleLinks()) {
                                DashboardFeatureCard(
                                    title: "Online Lexico",
                                    subtitle: "Learn words online",
                                    icon: "globe.americas.fill",
                                    color: .teal
                                )
                            }
                            .buttonStyle(ScaleButtonStyle())
                            
                            NavigationLink(destination: WordOfTheDay()) {
                                DashboardFeatureCard(
                                    title: "Word of Day",
                                    subtitle: "Daily vocabulary",
                                    icon: "sparkles",
                                    color: .orange
                                )
                            }
                            .buttonStyle(ScaleButtonStyle())
                            
                            NavigationLink(destination: SettingsView()) {
                                DashboardFeatureCard(
                                    title: "Settings",
                                    subtitle: "Manage preferences",
                                    icon: "gearshape.fill",
                                    color: .gray
                                )
                            }
                            .buttonStyle(ScaleButtonStyle())
                            
                            NavigationLink(destination: HelpView()) {
                                DashboardFeatureCard(
                                    title: "Help & Support",
                                    subtitle: "Get assistance",
                                    icon: "questionmark.circle.fill",
                                    color: .purple
                                )
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: maxContentWidth)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showExitConfirmation = true
                    }) {
                        Label("Exit", systemImage: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            .alert("Exit Application", isPresented: $showExitConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Exit", role: .destructive) {
                    exitApplication()
                }
            } message: {
                Text("Are you sure you want to close the app?")
            }
        }
        .accentColor(Color.accentBlue)
        .navigationBarBackButtonHidden(true)
    }
    
    private func exitApplication() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            UIView.animate(withDuration: 0.4) {
                window.alpha = 0
                window.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            } completion: { _ in
                exit(0)
            }
        }
    }
}

#Preview {
    ContentsPage()
        .environmentObject(LearningDataManager())
}
