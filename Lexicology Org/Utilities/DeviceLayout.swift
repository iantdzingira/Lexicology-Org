//
//  DeviceLayout.swift
//  Lexicology Org
//
//  Created by Ian. T. Dzingira on 02/10/2025.
//

import SwiftUI

enum DeviceLayout {
    case iPhonePortrait
    case iPhoneLandscape
    case iPadCompact
    case iPadRegular
    case largeScreen

    init(horizontal: UserInterfaceSizeClass?, vertical: UserInterfaceSizeClass?) {
        switch (horizontal, vertical) {
        case (.compact, .regular):
            self = .iPhonePortrait
        case (.compact, .compact):
            self = .iPhoneLandscape
        case (.regular, .compact):
            self = .iPadCompact
        case (.regular, .regular):
            self = .largeScreen
        default:
            self = .iPhonePortrait
        }
    }
    
    var isCompact: Bool {
        return self == .iPhonePortrait || self == .iPhoneLandscape
    }
    
    var isLargeScreen: Bool {
        return self == .largeScreen || self == .iPadCompact
    }
    
    var allowsSplitView: Bool {
        return self == .largeScreen
    }
    
    var prefersTwoColumns: Bool {
        return self == .largeScreen || self == .iPadRegular
    }
    
    var contentMaxWidth: CGFloat? {
        if isLargeScreen {
            return 800
        } else if self == .iPadCompact {
            return 700
        }
        return nil
    }
}
