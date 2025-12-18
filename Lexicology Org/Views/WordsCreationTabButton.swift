//
//  TabButton.swift
//  Lexicology Org
//
//  Created by Ian. T. Dzingira on 29/09/2025.
//

import SwiftUI

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    @Environment(\.horizontalSizeClass) var hSize
    
    private var isSpaciousLayout: Bool {
        hSize == .regular || UIDevice.current.userInterfaceIdiom == .pad
    }
    
    private var adaptiveFont: Font {
        isSpaciousLayout ? .headline.bold() : .subheadline.bold()
    }
    
    private var adaptivePadding: CGFloat {
        isSpaciousLayout ? 14 : 10
    }
    
    private var adaptiveUnderlineHeight: CGFloat {
        isSpaciousLayout ? 4 : 3
    }
    
    private var adaptiveSpacing: CGFloat {
        isSpaciousLayout ? 6 : 4
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: adaptiveSpacing) {
                Text(title)
                    .font(adaptiveFont)
                    .foregroundColor(isSelected ? .blue : .gray)
                
                if isSelected {
                    Capsule()
                        .fill(Color.blue)
                        .frame(height: adaptiveUnderlineHeight)
                        .transition(.move(edge: .bottom))
                } else {
                    Capsule()
                        .fill(Color.clear)
                        .frame(height: adaptiveUnderlineHeight)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, adaptivePadding)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
