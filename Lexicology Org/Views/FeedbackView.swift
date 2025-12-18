//
//  MailView.swift
//  Lexicology Org
//
//  Created by Ian. T. Dzingira on 29/08/2025.
//


import SwiftUI
import MessageUI

struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) var hSize
    @Environment(\.verticalSizeClass) var vSize
    
    @State private var showingMailComposer = false
    
    let supportEmail = "feedback.lexicology@gmail.com"
    
    var layout: DeviceLayout {
        DeviceLayout(horizontal: hSize, vertical: vSize)
    }
    
    private var maxContentWidth: CGFloat? {
        layout.allowsSplitView ? 500 : nil
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                ScrollView {
                    VStack(spacing: 15) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text("Share Your Thoughts")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Your feedback helps us improve the app! Whether it's a bug report, a feature request, or general praise, we want to hear it.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                    .padding(.vertical, 40)
                    .frame(maxWidth: maxContentWidth) // Constrain text width
                    
                    Spacer()
                    
                    VStack(spacing: 20) {
                        Button("Send Feedback Email") {
                            if MFMailComposeViewController.canSendMail() {
                                showingMailComposer = true
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        
                        Text("Emails will be sent to: \(supportEmail)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: maxContentWidth) 
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Send Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingMailComposer) {
                MailView(to: supportEmail, subject: "Feedback: Lexicology App")
            }
        }
    }
}

#Preview {
    FeedbackView()
}
