//
//  Words From The Web.swift
//  Lexicology Org
//
//  Created by Ian. T. Dzingira on 25/09/2025.

//Explain the View hierarchy produced by a program

import SwiftUI

struct GoogleLinks: View {
    @Environment(\.openURL) var openURL
    @Environment(\.horizontalSizeClass) var hSize
    
    private var isSpaciousLayout: Bool {
        hSize == .regular
    }
    
    private var gridColumns: [GridItem] {
        isSpaciousLayout ? [GridItem(.flexible()), GridItem(.flexible())] : [GridItem(.flexible())]
    }
    
    private var horizontalPadding: CGFloat {
        isSpaciousLayout ? 80 : 20
    }
    
    private var topPadding: CGFloat {
        isSpaciousLayout ? 60 : 30
    }
    
    private var headerImageSize: CGFloat {
        isSpaciousLayout ? 100 : 80
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(.systemGroupedBackground), Color(.systemBackground)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    
                    // Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: headerImageSize, height: headerImageSize)
                            
                            Image(systemName: "globe")
                                .font(.system(size: headerImageSize * 0.45, weight: .medium))
                                .foregroundColor(.blue)
                        }
                        
                        VStack(spacing: 8) {
                            Text("Lex-Online Hub")
                                .font(isSpaciousLayout ? .largeTitle : .title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Instant access to world class lexical resources")
                                .font(isSpaciousLayout ? .title3 : .subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, topPadding)
                    .padding(.horizontal, horizontalPadding)

                    // Adaptive Grid of Dictionary Cards
                    LazyVGrid(columns: gridColumns, spacing: isSpaciousLayout ? 24 : 16) {
                        DictionaryCard(
                            title: "Dictionary.com",
                            description: "The world's leading online dictionary",
                            url: "https://www.dictionary.com",
                            icon: "book.closed.fill",
                            color: .blue
                        )
                        
                        DictionaryCard(
                            title: "Merriam-Webster",
                            description: "America's most trusted dictionary",
                            url: "https://www.merriam-webster.com",
                            icon: "building.columns.fill",
                            color: .red
                        )
                        
                        DictionaryCard(
                            title: "Oxford Dictionary",
                            description: "The definitive record of English language",
                            url: "https://www.oxfordlearnersdictionaries.com",
                            icon: "graduationcap.fill",
                            color: .purple
                        )
                        
                        DictionaryCard(
                            title: "Cambridge Dictionary",
                            description: "English dictionary, translations & thesaurus",
                            url: "https://dictionary.cambridge.org",
                            icon: "globe.europe.africa.fill",
                            color: .green
                        )
                        
                        DictionaryCard(
                            title: "Collins Dictionary",
                            description: "Comprehensive English dictionary",
                            url: "https://www.collinsdictionary.com",
                            icon: "text.book.closed.fill",
                            color: .orange
                        )
                    }
                    .padding(.horizontal, horizontalPadding)
                    
                    // Footer
                    VStack(spacing: 12) {
                        Text("More premium resources coming soon")
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 16) {
                            FeaturePill(icon: "bolt.fill", text: "Fast Access")
                            FeaturePill(icon: "lock.fill", text: "Secure")
                            FeaturePill(icon: "sparkles", text: "Premium")
                        }
                    }
                    .padding(.bottom, topPadding)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

struct DictionaryCard: View {
    let title: String
    let description: String
    let url: String
    let icon: String
    let color: Color
    @Environment(\.openURL) var openURL
    @State private var isPressed = false
    @State private var isHovered = false
    @Environment(\.horizontalSizeClass) var hSize
    
    private var isSpaciousLayout: Bool {
        hSize == .regular
    }
    
    private var cardPadding: CGFloat {
        isSpaciousLayout ? 25 : 20
    }
    
    private var iconSize: CGFloat {
        isSpaciousLayout ? 55 : 50
    }
    
    var body: some View {
        Button(action: {
            if let url = URL(string: url) {
                openURL(url)
            }
        }) {
            HStack(spacing: 16) {
                
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.gradient)
                        .frame(width: iconSize, height: iconSize)
                        .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
                    
                    Image(systemName: icon)
                        .font(.system(size: iconSize * 0.4, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.forward.circle.fill")
                    .font(isSpaciousLayout ? .title : .title3)
                    .foregroundColor(color)
                    .scaleEffect(isHovered ? 1.1 : 1.0)
            }
            .padding(cardPadding)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: .black.opacity(isHovered ? 0.1 : 0.05),
                        radius: isHovered ? 8 : 4,
                        x: 0,
                        y: isHovered ? 4 : 2
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isHovered = hovering
            }
        }
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = false
            }
        }
    }
}

struct FeaturePill: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .bold))
            Text(text)
                .font(.system(size: 10, weight: .medium))
        }
        .foregroundColor(.blue)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.blue.opacity(0.1))
        )
    }
}

struct PressEvents: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ _ in
                        onPress()
                    })
                    .onEnded({ _ in
                        onRelease()
                    })
            )
    }
}

extension View {
    func pressEvents(onPress: @escaping (() -> Void), onRelease: @escaping (() -> Void)) -> some View {
        modifier(PressEvents(onPress: {
            onPress()
        }, onRelease: {
            onRelease()
        }))
    }
}

#Preview {
    NavigationView {
        GoogleLinks()
    }
}

#Preview("iPad Large") {
    NavigationView {
        GoogleLinks()
    }
}
