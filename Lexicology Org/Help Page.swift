//
//  Help Page.swift
//  Lexicology Org
//
//  Created by Ian. T. Dzingira on 26/09/2025.
//
import SwiftUI
import MessageUI

struct HelpOption: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(title)
                .foregroundColor(.primary)
                .font(.body)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct HelpView: View {
    
    @Environment(\.horizontalSizeClass) var hSize
    @Environment(\.verticalSizeClass) var vSize
    
    @State private var showingFeedbackSheet = false
    
    var layout: DeviceLayout {
        DeviceLayout(horizontal: hSize, vertical: vSize)
    }
    
    private var maxContentWidth: CGFloat? {
        layout.allowsSplitView ? 600 : nil
    }

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    
                    VStack(spacing: 8) {
                        Text("Help & Support")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("We're here to help")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 30)
                    .padding(.bottom, 20)
                    
                    LazyVStack(spacing: 12) {
                        
                        NavigationLink(destination: HowToUseView()) {
                            HelpOption(title: "How to Use", icon: "book.fill", color: .blue)
                        }
                        
                        NavigationLink(destination: TroubleshootingView()) {
                            HelpOption(title: "Troubleshooting", icon: "wrench.fill", color: .orange)
                        }
                        
                        NavigationLink(destination: ContactSupportDetailView()) {
                            HelpOption(title: "Contact Support", icon: "envelope.fill", color: .green)
                        }
                        
                        NavigationLink(destination: FAQView()) {
                            HelpOption(title: "FAQ", icon: "questionmark.circle.fill", color: .purple)
                        }
                    }
                    .padding(.horizontal, layout.allowsSplitView ? 0 : 20)
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Button("Send Feedback") {
                            showingFeedbackSheet = true
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.horizontal, 40)
                        
                        Text("Version \(appVersion)")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.bottom, 20)
                    }
                    .padding(.top, 40)
                    
                }
                .frame(maxWidth: maxContentWidth)
                .padding(.horizontal, layout.allowsSplitView ? 20 : 0)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Support")
            .navigationBarTitleDisplayMode(.inline)
            
            .sheet(isPresented: $showingFeedbackSheet) {
                FeedbackView()
            }
        }
    }
}

#Preview {
    HelpView()
}
