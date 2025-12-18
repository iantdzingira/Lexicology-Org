//
//  ContactSupportDetailView.swift
//  Lexicology Org
//
//  Created by Ian. T. Dzingira on 29/09/2025.
//
import SwiftUI
import MessageUI

struct MailView: UIViewControllerRepresentable {
    let to: String
    let subject: String
    
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mail = MFMailComposeViewController()
        mail.setToRecipients([to])
        mail.setSubject(subject)
        mail.setMessageBody("\n\n---\nApp Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A")\niOS: \(UIDevice.current.systemVersion)", isHTML: false)
        mail.mailComposeDelegate = context.coordinator
        return mail
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let dismiss: DismissAction
        
        init(dismiss: DismissAction) {
            self.dismiss = dismiss
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            dismiss()
        }
    }
}

struct ContactSupportDetailView: View {
    
    @Environment(\.horizontalSizeClass) var hSize
    @Environment(\.verticalSizeClass) var vSize
    @State private var showingMailComposer = false
    @State private var mailAlertMessage: String?
    
    let supportEmail = "support@lexicology.app"
    
    var layout: DeviceLayout {
        DeviceLayout(horizontal: hSize, vertical: vSize)
    }
    
    private var maxContentWidth: CGFloat? {
        layout.allowsSplitView ? 700 : nil
    }
    
    var body: some View {
        ScrollView {
            VStack {
                List {
                    Section("Email Support") {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("The best way to get support is by email. We aim to respond to all inquiries within 24 hours.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Button("Start Email to Support") {
                                if MFMailComposeViewController.canSendMail() {
                                    showingMailComposer = true
                                } else {
                                    mailAlertMessage = "Email is not configured on this device. Please use a different method or set up a mail account."
                                }
                            }
                            .buttonStyle(.plain)
                            .foregroundColor(.blue)
                            .padding(.vertical, 5)
                        }
                    }
                    
                    Section("Other Resources") {
                        Link(destination: URL(string: "https://x.com/LexicologyApp")!) {
                            HStack {
                                Text("Twitter / X")
                                Spacer()
                                Text("@LexicologyApp")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Link(destination: URL(string: "https://support.lexicology.app")!) {
                            HStack {
                                Text("Support Website")
                                Spacer()
                                Text("support.lexicology.app")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Section("Operating Hours") {
                        Text("Our technical support team operates Monday to Friday, 9:00 AM to 5:00 PM (CAT).")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(height: 450)
                
                Spacer()
            }
            .frame(maxWidth: maxContentWidth)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Contact Support")
        .sheet(isPresented: $showingMailComposer) {
            MailView(to: supportEmail, subject: "Support Inquiry: Lexicology App")
        }
        .alert("Cannot Send Email", isPresented: .constant(mailAlertMessage != nil), actions: {
            Button("OK") { mailAlertMessage = nil }
        }, message: {
            Text(mailAlertMessage ?? "")
        })
    }
}

struct ContactSupportDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ContactSupportDetailView()
        }
    }
}
