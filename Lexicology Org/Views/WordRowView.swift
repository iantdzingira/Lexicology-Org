//
//  WordRowView.swift
//  Lexicology Org
//
//  Created by Ian. T. Dzingira on 29/09/2025.
//
import SwiftUI

struct WordRowView: View {
    let entry: WordEntry
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(\.horizontalSizeClass) var hSize
    @Environment(\.verticalSizeClass) var vSize

    private var isSpaciousLayout: Bool {
        return hSize == .regular || UIDevice.current.userInterfaceIdiom == .pad
    }

    private var outerVerticalPadding: CGFloat {
        isSpaciousLayout ? 12 : 8
    }
    
    private var innerPadding: CGFloat {
        isSpaciousLayout ? 25 : 15
    }

    private var spacing: CGFloat {
        isSpaciousLayout ? 12 : 8
    }
    
    private var wordFont: Font {
        isSpaciousLayout ? .title2 : .title3
    }
    
    private var definitionFont: Font {
        isSpaciousLayout ? .body : .callout
    }

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            HStack(alignment: .firstTextBaseline) {
                Text(entry.word)
                    .font(wordFont)
                    .fontWeight(.bold)
                    .foregroundColor(.accentColor)
                Spacer()
                if entry.source == "Lexicology" {
                    Image(systemName: "star.fill")
                        .foregroundColor(.orange)
                        .imageScale(isSpaciousLayout ? .large : .medium)
                        .accessibilityLabel("Lexicology Source")
                }
            }
            Text(entry.meaning)
                .font(definitionFont)
                .foregroundColor(.secondary)
                .lineLimit(2)
            if !entry.sentence.isEmpty {
                Text(entry.sentence)
                    .font(.caption)
                    .italic()
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .padding(.top, 4)
            }
        }
        .padding(innerPadding)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(color: colorScheme == .dark ? .black.opacity(0.4) : .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 5)
        .padding(.vertical, outerVerticalPadding)
    }
}

struct WordRowView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            WordRowView(entry: WordEntry(word: "Serendipity", meaning: "A fortunate coincidence.", sentence: "What a serendipitous moment!", source: "Lexicology"))
            
            WordRowView(entry: WordEntry(word: "Ephemeral", meaning: "Lasting for a very short time.", sentence: "Cherry blossoms are ephemeral.", source: "User"))
        }
        .padding()
        .previewLayout(.sizeThatFits)
        .previewDisplayName("iPhone Default")
        
        VStack {
            WordRowView(entry: WordEntry(word: "Spacious Word", meaning: "A concept requiring a larger view for comfortable reading and appreciation of detail.", sentence: "This text adapts to the wider screen.", source: "Lexicology"))
        }
        .padding()
        .previewLayout(.sizeThatFits)
        .previewDevice("iPad Pro (11-inch) (4th generation)")
        .previewDisplayName("iPad Spacious")
    }
}
