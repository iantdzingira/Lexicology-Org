//
//  SwipeActionsModifier.swift
//  Lexicology Org
//
//  Created by Ian. T. Dzingira on 18/12/2025.
//

import SwiftUI

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
