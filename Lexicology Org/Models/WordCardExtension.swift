//
//  WordCardExtension.swift
//  Lexicology Org
//
//  Created by Ian. T. Dzingira on 18/12/2025.
//

import Foundation
import SwiftUI

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
