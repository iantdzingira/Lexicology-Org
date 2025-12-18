//
//  WordDetailView.swift
//  Lexicology Org
//
//  Created by Ian. T. Dzingira on 29/09/2025.
//
import SwiftUI
import UIKit
import Foundation

struct WordDetailView: View {
    let entry: WordEntry
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var dataManager: LearningDataManager
    
    @Environment(\.horizontalSizeClass) var hSize
    @Environment(\.verticalSizeClass) var vSize
    
    @State private var animatedElements = false
    @State private var glowOpacity: Double = 0.3
    @State private var cardTilt: Double = 0
    
    private var isSpaciousLayout: Bool {
        return hSize == .regular || UIDevice.current.userInterfaceIdiom == .pad
    }
    
    private var verticalSpacing: CGFloat {
        isSpaciousLayout ? 45 : 30
    }
    
    private var wordFontSize: Font {
        isSpaciousLayout ? .system(size: 64, weight: .black, design: .serif) : .system(size: 52, weight: .black, design: .serif)
    }
    
    private var detailTextFont: Font {
        isSpaciousLayout ? .system(.title3, design: .rounded) : .system(.body, design: .rounded)
    }
    
    private var detailPadding: CGFloat {
        isSpaciousLayout ? 30 : 24
    }
    
    private var buttonBottomPadding: CGFloat {
        isSpaciousLayout ? 80 : 60
    }
    
    var wordIsLearned: Bool {
        dataManager.hasLearned(wordID: entry.customID)
    }
    
    var body: some View {
        ZStack {
            
            backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: verticalSpacing) {
                    headerView()
                    definitionView()
                    exampleView()
                    
                    if let source = entry.source, !source.isEmpty {
                        sourceView(source: source)
                    }
                    
                    markAsLearnedButton()
                        .padding(.top, verticalSpacing * 1.5)
                        .padding(.bottom, buttonBottomPadding)
                    
                    Spacer()
                }
                .padding(.horizontal, detailPadding * 0.8)
                .padding(.top, detailPadding)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                animatedElements = true
            }
            
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glowOpacity = 0.7
            }
        }
    }
    
    private func markAsLearnedButton() -> some View {
        Button {
            dataManager.wordLearned(entry: entry)
        } label: {
            HStack {
                Image(systemName: wordIsLearned ? "checkmark.circle.fill" : "checkmark.seal.fill")
                    .font(.title2)
                Text(wordIsLearned ? "Word Learned!" : "Mark '\(entry.word)' as Learned")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: wordIsLearned ? [Color.gray, Color.gray.opacity(0.8)] : [Color.blue, Color.purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(16)
            .shadow(color: wordIsLearned ? .clear : .blue.opacity(0.4), radius: 10, x: 0, y: 5)
        }
        .disabled(wordIsLearned)
        .scaleEffect(animatedElements ? 1 : 0.9)
        .opacity(animatedElements ? 1 : 0)
        .animation(.spring().delay(0.6), value: animatedElements)
    }
    
    private var backgroundGradient: some View {
        AngularGradient(
            gradient: Gradient(colors: [
                Color.blue.opacity(0.1),
                Color.purple.opacity(0.1),
                Color.blue.opacity(0.05),
                Color.indigo.opacity(0.1)
            ]),
            center: .topLeading,
            angle: .degrees(animatedElements ? 360 : 0)
        )
        .animation(.linear(duration: 20).repeatForever(autoreverses: false), value: animatedElements)
    }
    
    @ViewBuilder
    private func headerView() -> some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 8) {
                Text(entry.word)
                    .font(wordFontSize)
                    .foregroundColor(.primary)
                    .shadow(color: .blue.opacity(0.3), radius: 2, x: 0, y: 2)
                    .scaleEffect(animatedElements ? 1 : 0.8)
                    .opacity(animatedElements ? 1 : 0)
                
                Text(entry.word.uppercased())
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.blue)
                    .tracking(3)
                    .opacity(0.6)
            }
            
            Spacer()
            
            if let source = entry.source, source == "Lexicology" {
                premiumBadge
            }
        }
        .padding(.bottom, 10)
        .offset(y: animatedElements ? 0 : -50)
    }
    
    private var premiumBadge: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 44, height: 44)
                .shadow(color: .blue.opacity(glowOpacity), radius: 8, x: 0, y: 0)
            
            Image(systemName: "sparkles")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
        }
        .rotationEffect(.degrees(animatedElements ? 360 : 0))
        .scaleEffect(animatedElements ? 1 : 0.5)
    }
    
    @ViewBuilder
    private func definitionView() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeader(title: "Definition", icon: "brain.head.profile", color: .blue)
            
            Text(entry.meaning)
                .font(detailTextFont)
                .lineSpacing(8)
                .padding(detailPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    ZStack {
                        
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    colors: [.blue.opacity(0.3), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                )
                .scaleEffect(animatedElements ? 1 : 0.9)
                .rotation3DEffect(
                    .degrees(cardTilt),
                    axis: (x: 1, y: 0, z: 0)
                )
        }
        .offset(x: animatedElements ? 0 : -UIScreen.main.bounds.width)
        .gesture(
            DragGesture()
                .onChanged { value in
                    withAnimation(.interactiveSpring()) {
                        cardTilt = Double(value.translation.height / 10)
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring()) {
                        cardTilt = 0
                    }
                }
        )
    }
    
    @ViewBuilder
    private func exampleView() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeader(title: "Example Usage", icon: "text.word.spacing", color: .blue)
            
            ZStack(alignment: .leading) {
                Text(entry.sentence)
                    .font(detailTextFont)
                    .italic()
                    .foregroundColor(.primary)
                    .lineSpacing(8)
                    .padding(detailPadding)
                    .padding(.leading, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(.ultraThinMaterial)
                            
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 2
                                )
                        }
                    )
                
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 6, height: animatedElements ? (isSpaciousLayout ? 150 : 120) : 0)
                    .padding(.leading, 20)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.5), value: animatedElements)
            }
            .scaleEffect(animatedElements ? 1 : 0.9)
        }
        .offset(x: animatedElements ? 0 : UIScreen.main.bounds.width)
    }
    
    @ViewBuilder
    private func sourceView(source: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "book.closed.circle.fill")
                .font(.title3)
                .foregroundColor(.blue)
                .symbolRenderingMode(.hierarchical)
            
            Text("Source: \(source)")
                .font(.callout)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right.circle.fill")
                .font(.callout)
                .foregroundColor(.blue.opacity(0.7))
        }
        .padding(16)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: .blue.opacity(0.2), radius: 5, x: 0, y: 3)
        )
        .scaleEffect(animatedElements ? 1 : 0.8)
        .opacity(animatedElements ? 1 : 0)
    }
    
    private func sectionHeader(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .symbolRenderingMode(.hierarchical)
                .scaleEffect(animatedElements ? 1 : 0)
            
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct WordDetailView_Previews: PreviewProvider {
    static let mockDataManager = LearningDataManager()
    
    static var previews: some View {
        NavigationView {
            WordDetailView(entry: WordEntry(
                word: "Serendipity",
                meaning: "The occurrence and development of events by chance in a happy or beneficial way.",
                sentence: "A fortunate stroke of serendipity brought the two old friends together again.",
                source: "Lexicology"
            ))
            .environmentObject(mockDataManager)
        }
        .previewDisplayName("iPhone Portrait (Compact)")
        
        NavigationView {
            WordDetailView(entry: WordEntry(
                word: "Ephemeral",
                meaning: "Lasting for a very short time; transient.",
                sentence: "The beauty of cherry blossoms is ephemeral, lasting only a week or two.",
                source: "Classic Literature"
            ))
            .environmentObject(mockDataManager)
        }
        .previewDevice("iPad Pro (11-inch) (4th generation)")
        .previewDisplayName("iPad Regular (Spacious)")
        
        NavigationView {
            WordDetailView(entry: WordEntry(
                word: "Quintessential",
                meaning: "Representing the most perfect or typical example of a quality or class.",
                sentence: "The little black dress is considered the quintessential item in any fashion-conscious wardrobe.",
                source: "User"
            ))
            .environmentObject(mockDataManager)
        }
        .previewInterfaceOrientation(.landscapeLeft)
        .previewDisplayName("iPhone Landscape (Less Spacious)")
    }
}
