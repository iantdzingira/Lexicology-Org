//
//  WordCard.swift
//  Lexicology Org
//
//  Created by Ian. T. Dzingira on 29/09/2025.
//
import SwiftUI

struct WordCard: View {
    let wordEntry: WordEntry
    @State private var isPressed = false
    @State private var showDetail = false
    @State private var cardTilt: Double = 0
    @State private var glowOpacity: Double = 0.3
    @StateObject private var learningManager = LearningDataManager()
    
    // Environment variables for adaptive layout
    @Environment(\.horizontalSizeClass) var hSize
    @Environment(\.verticalSizeClass) var vSize

    private var layout: DeviceLayout {
        DeviceLayout(horizontal: hSize, vertical: vSize)
    }

    private var contentPadding: CGFloat {
        switch layout {
        case .largeScreen, .iPadRegular: return 30 // Larger padding for spacious screens
        case .iPadCompact: return 25
        case .iPhonePortrait: return 20
        case .iPhoneLandscape: return 16 // Slightly smaller padding for constrained landscape
        }
    }
    
    private var wordFontSize: Font {
        switch layout {
        case .largeScreen, .iPadRegular:
            return .system(.title, design: .serif).weight(.black)
        case .iPadCompact:
            return .system(.title2, design: .serif).weight(.black)
        case .iPhonePortrait, .iPhoneLandscape:
            return .system(.title2, design: .serif).weight(.black)
        }
    }

    private var bodyTextFont: Font {
        switch layout {
        case .largeScreen, .iPadRegular: return .body
        default: return .callout
        }
    }
    
    private var sourceTracking: CGFloat {
        switch layout {
        case .largeScreen, .iPadRegular: return 1.5
        default: return 1.2
        }
    }


    var body: some View {
        VStack(alignment: .leading, spacing: contentPadding * 0.8) {
            
            headerView
            
            dividerView
            
            definitionView
            
            exampleView
            
            sourceView
        }
        .padding(contentPadding)
        .background(cardBackground)
        .overlay(cardBorder)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .rotation3DEffect(
            .degrees(cardTilt),
            axis: (x: 1, y: 0, z: 0)
        )
        .shadow(
            color: .blue.opacity(glowOpacity),
            radius: 8, x: 0, y: 4
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isPressed = false
                }
            }
        }
        .onLongPressGesture(minimumDuration: 0.1) {
           
        }
        .contextMenu {
            contextMenuItems
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glowOpacity = 0.6
            }
        }
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text(wordEntry.word)
                    .font(wordFontSize)
                    .foregroundColor(.primary)
                    .textCase(nil)
                
                Text(wordEntry.word.uppercased())
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                    .tracking(sourceTracking)
                    .opacity(0.7)
            }
            
            Spacer()
            
            if wordEntry.source == "User" || wordEntry.source == "Personal Collection" {
                premiumBadge
            }
        }
    }
    
    private var premiumBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 12))
            
            Text("YOURS")
                .font(.system(.caption, design: .rounded))
                .fontWeight(.heavy)
                .textCase(.uppercase)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [.blue, .blue.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        )
    }
    
    private var dividerView: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.clear, .blue.opacity(0.3), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 1)
    }
    
    private var definitionView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.blue)
                
                Text("DEFINITION")
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .textCase(.uppercase)
                    .tracking(1.2)
                
                Spacer()
            }
            
            Text(wordEntry.meaning)
                .font(bodyTextFont)
                .foregroundColor(.primary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var exampleView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "quote.bubble.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.blue)
                
                Text("USAGE")
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .textCase(.uppercase)
                    .tracking(1.2)
                
                Spacer()
            }
            
            Text(wordEntry.sentence)
                .font(bodyTextFont)
                .italic()
                .foregroundColor(.secondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 8)
                .overlay(
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: 3)
                        .padding(.vertical, 2),
                    alignment: .leading
                )
        }
    }
    
    private var sourceView: some View {
        HStack {
            Image(systemName: sourceIcon)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
            
            Text("Source: \(wordEntry.source ?? "Unknown")")
                .font(.system(.caption2, design: .default))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text("\(wordEntry.word.count) chars")
                .font(.system(.caption2, design: .monospaced))
                .foregroundColor(.secondary.opacity(0.7))
        }
        .padding(.top, 8)
    }
    
    // MARK: - Computed Properties (Original Logic)
    
    private var sourceIcon: String {
        guard let source = wordEntry.source else {
            return "book.fill"
        }
        
        switch source {
        case "Lexicology":
            return "star.fill"
        case "User", "Personal Collection":
            return "person.fill"
        default:
            return "book.fill"
        }
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.regularMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.03), .clear, .blue.opacity(0.01)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
    }
    
    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(
                LinearGradient(
                    colors: [.blue.opacity(0.2), .blue.opacity(0.1), .blue.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
    }
    
    private var contextMenuItems: some View {
        Group {
            Button {
                UIPasteboard.general.string = wordEntry.word
            } label: {
                Label("Copy Word", systemImage: "doc.on.doc")
            }
            
            Button {
                UIPasteboard.general.string = wordEntry.meaning
            } label: {
                Label("Copy Definition", systemImage: "text.book.closed")
            }
            
            Button {
                UIPasteboard.general.string = wordEntry.sentence
            } label: {
                Label("Copy Example", systemImage: "quote.bubble")
            }
            
            Divider()
            
            Button(role: .destructive) {
                
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - Previews (Retained)

struct WordCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            WordCard(wordEntry: WordEntry(
                word: "Serendipity",
                meaning: "The occurrence and development of events by chance in a happy or beneficial way.",
                sentence: "A fortunate stroke of serendipity brought the two old friends together again after decades.",
                source: "Lexicology"
            ))
            
            WordCard(wordEntry: WordEntry(
                word: "Ephemeral",
                meaning: "Lasting for a very short time; transient.",
                sentence: "The beauty of cherry blossoms is ephemeral, reminding us to cherish each moment.",
                source: "Personal Collection"
            ))
            
            WordCard(wordEntry: WordEntry(
                word: "Quintessential",
                meaning: "Representing the most perfect or typical example of a quality or class.",
                sentence: "The little black dress is considered the quintessential item in any fashion-conscious wardrobe.",
                source: "Classic Literature"
            ))
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .previewDisplayName("Word Card Collection")
        
        // Single card preview
        WordCard(wordEntry: WordEntry(
            word: "Luminous",
            meaning: "Full of or shedding light; bright or shining, especially in the dark.",
            sentence: "The luminous moon cast an ethereal glow over the silent landscape.",
            source: "User"
        ))
        .padding()
        .background(Color(.systemGroupedBackground))
        .previewDisplayName("Single Card")
    }
}

// MARK: - Swipe Action Modifiers (Retained)

extension WordCard {
    func withSwipeActions(
        edge: HorizontalEdge,
        allowsFullSwipe: Bool,
        onDelete: @escaping () -> Void,
        onCopy: @escaping () -> Void
    ) -> some View {
        self.modifier(
            SwipeActionsModifier(
                edge: edge,
                allowsFullSwipe: allowsFullSwipe,
                onDelete: onDelete,
                onCopy: onCopy
            )
        )
    }
}

struct SwipeActionsModifier: ViewModifier {
    let edge: HorizontalEdge
    let allowsFullSwipe: Bool
    let onDelete: () -> Void
    let onCopy: () -> Void

    func body(content: Content) -> some View {
        content
            .swipeActions(edge: edge, allowsFullSwipe: allowsFullSwipe) {
                
                Button(role: .destructive) {
                    withAnimation(.spring()) {
                        onDelete()
                    }
                } label: {
                    Label("Delete", systemImage: "trash.fill")
                }
                
                Button {
                    onCopy()
                } label: {
                    Label("Copy", systemImage: "doc.on.doc.fill")
                }
                .tint(.blue)
            }
    }
}
