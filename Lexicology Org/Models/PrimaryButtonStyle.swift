//
//  PrimaryButtonStyle.swift
//  Lexicology Org
//
//  Created by Ian. T. Dzingira on 13/09/2025.
//
import SwiftUI
import SwiftData

struct PrimaryButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0) 
            .opacity(configuration.isPressed ? 0.9 : 1.0)
    }
}


