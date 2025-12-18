//
//  FAQView.swift
//  Lexicology Org
//
//  Created by Ian. T. Dzingira on 29/09/2025.
//
import SwiftUI

struct FAQView: View {
    
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
                        DisclosureGroup("Is the app free to use?") {
                            Text("Yes, the core dictionary and Word of the Day features are completely free. We may introduce premium features for advanced learning modules in the future.")
                        }
                        
                        DisclosureGroup("Does the app work offline?") {
                            Text("Basic functionality, including your saved vocabulary, works offline. However, fetching new definitions, etymologies, and images requires an active internet connection.")
                        }
                        
                        DisclosureGroup("How often is the dictionary updated?") {
                            Text("Our primary dictionary data source is updated quarterly. New slang and technical terms are integrated as they are officially recognized in contemporary usage.")
                        }
                        
                        DisclosureGroup("Can I suggest a feature?") {
                            Text("Absolutely! We welcome all feedback. Please use the 'Send Feedback' button at the bottom of the Help screen to share your ideas.")
                        }
                    }
                    .frame(height: 500)
                    
                    Spacer()
                }
                .frame(maxWidth: maxContentWidth)
                .padding(.horizontal, layout.allowsSplitView ? 20 : 0)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("FAQ")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    NavigationStack {
        FAQView()
    }
}
