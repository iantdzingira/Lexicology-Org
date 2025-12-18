//
//  WordCategory.swift
//  Lexicology Org
//
//  Created by Ian. T. Dzingira on 18/12/2025.
//
import SwiftUI

enum WordCategory: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    case technical = "Technical", programming = "Programming", cooking = "Cooking", sports = "Sports", history = "History", science = "Science", arts = "Arts & Culture", slang = "Slang", academic = "Academic", colloquial = "Colloquial", finance = "Finance", philosophy = "Philosophy", literature = "Literature", medical = "Medical", technology = "Technology"
    
    var icon: String {
        switch self {
        case .technical: return "gear"
        case .programming: return "keyboard"
        case .cooking: return "fork.knife"
        case .sports: return "sportscourt"
        case .history: return "book.closed"
        case .science: return "atom"
        case .arts: return "paintpalette"
        case .slang: return "quote.bubble"
        case .academic: return "graduationcap"
        case .colloquial: return "waveform"
        case .finance: return "dollarsign.circle"
        case .philosophy: return "brain.head.profile"
        case .literature: return "book"
        case .medical: return "stethoscope"
        case .technology: return "laptopcomputer"
        }
    }
}
