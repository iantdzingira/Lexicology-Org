//
//  TroubleshootingView.swift
//  Lexicology Org
//
//  Created by Ian. T. Dzingira on 29/09/2025.
//

import SwiftUI

struct TroubleshootingView: View {
    @Environment(\.horizontalSizeClass) var hSize
    
    private var isSpaciousLayout: Bool {
        hSize == .regular
    }
    
    var body: some View {
        List {
            Section("App is Slow or Freezing") {
                AdaptiveTroubleshootingStep(
                    number: "1",
                    text: "Restart the app: Fully close the app from the multitasking view and relaunch it."
                )
                AdaptiveTroubleshootingStep(
                    number: "2",
                    text: "Clear Cache: If the issue persists, go to Settings > 'Clear Cache' (under Developer Options) to remove temporary files."
                )
            }
            
            Section("Definitions are Missing") {
                VStack(alignment: .leading, spacing: 5) {
                    Text("This usually indicates a **connectivity issue**.")
                    Text("Ensure you have a stable WiFi or Cellular connection. The app requires a connection to fetch complete dictionary data.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
            }
            
            Section("Notifications Not Appearing") {
                AdaptiveTroubleshootingStep(
                    number: "1",
                    text: "Go to your device's main Settings."
                )
                AdaptiveTroubleshootingStep(
                    number: "2",
                    text: "Find this app in the list and ensure Notifications are enabled."
                )
                AdaptiveTroubleshootingStep(
                    number: "3",
                    text: "Within the app, verify that 'Daily Word Notifications' is toggled on in the 'Settings' tab."
                )
            }
            
            Section("Cannot Save Words") {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Check if you are signed in or authenticated. Vocabulary lists require a valid user session.")
                    Text("If you are signed in and still experience issues, please contact support.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
            }
           
            if isSpaciousLayout {
                Section {
                    Text("If these steps do not resolve your issue, please email our support team directly for personalized assistance.")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 10)
                }
            }
        }
        .navigationTitle("Troubleshooting")
        .listStyle(.insetGrouped)
    }
}

struct AdaptiveTroubleshootingStep: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            
            Circle()
                .fill(Color.blue)
                .frame(width: 20, height: 20)
                .overlay(
                    Text(number)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
                .padding(.top, 2)
            
            Text(text)
                .font(.callout)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    NavigationStack {
        TroubleshootingView()
    }
}
