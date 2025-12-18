//
//  HowToUseView.swift
//  Lexicology Org
//
//  Created by Ian. T. Dzingira on 29/09/2025.
//


import SwiftUI

struct HowToUseView: View {
    
    @Environment(\.horizontalSizeClass) var hSize
    @Environment(\.verticalSizeClass) var vSize
    
    var layout: DeviceLayout {
        DeviceLayout(horizontal: hSize, vertical: vSize)
    }
    
    private var maxContentWidth: CGFloat? {
        layout.allowsSplitView ? 700 : nil
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    List {
                        Section("Search & Discovery") {
                            HStack {
                                Image(systemName: "magnifyingglass.circle.fill").foregroundColor(.blue)
                                Text("Tap the 'Search Bar' on the main screen to start typing a word. The app provides instant suggestions for accurate spelling and definitions.")
                            }
                        }
                        
                        Section("Word Saving") {
                            HStack {
                                Image(systemName: "star.circle.fill").foregroundColor(.yellow)
                                Text("To save a word to your personal 'Vocabulary List', tap the 'Star' icon next to the definition. Saved words are synced across all your devices.")
                            }
                        }
                        
                        Section("Daily Word") {
                            HStack {
                                Image(systemName: "calendar.circle.fill").foregroundColor(.green)
                                Text("The 'Word of the Day' is displayed prominently on the Home screen. Tap it to see detailed etymology, usage examples, and related words.")
                            }
                        }
                        
                        Section("Settings") {
                            HStack {
                                Image(systemName: "gear.circle.fill").foregroundColor(.gray)
                                Text("Customize your experience in the 'Settings' tab. Here you can toggle Dark Mode, manage notifications, and reset app data.")
                            }
                        }
                    }
                    .frame(height: 550)
                }
                .frame(maxWidth: maxContentWidth)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("How to Use")
            .padding(.top, layout.allowsSplitView ? 20 : 0)
        }
    }
}

#Preview {
    NavigationStack {
        HowToUseView()
    }
}
