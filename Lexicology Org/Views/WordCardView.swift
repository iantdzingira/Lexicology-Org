//
//  WordCardView.swift
//  Lexicology Org
//
//  Created by Ian. T. Dzingira on 17/11/2025.
//
import SwiftUI


struct WordCardView: View {
    let word: WordEntry
    let timeRemaining: String
    @Binding var cardFlip: Bool
    @Binding var glowOpacity: Double
    @State private var contentAppeared = false
    
    @Environment(\.horizontalSizeClass) var hSize
    @Environment(\.verticalSizeClass) var vSize

    private var layout: DeviceLayout {
        DeviceLayout(horizontal: hSize, vertical: vSize)
    }

    private var contentPadding: CGFloat {
        switch layout {
        case .largeScreen, .iPadRegular:
            return 40
        default:
            return 30
        }
    }
    
    private var wordFontSize: CGFloat {
        switch layout {
        case .largeScreen, .iPadRegular:
            return 52
        default:
            return 42
        }
    }

    private var iconSize: CGFloat {
        switch layout {
        case .largeScreen, .iPadRegular:
            return 80
        default:
            return 70
        }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            headerIcon
            
            wordDisplay
            
            contentSection
            
            glowingDivider
            
            countdownSection
        }
        .padding(contentPadding)
        .background(cardBackground)
        .overlay(cardBorder)
        .rotation3DEffect(
            .degrees(cardFlip ? 360 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .scaleEffect(contentAppeared ? 1 : 0.8)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                contentAppeared = true
            }
        }
    }
    
    private var headerIcon: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: iconSize, height: iconSize)
                .shadow(color: .blue.opacity(glowOpacity), radius: 10, x: 0, y: 5)
            
            Image(systemName: "sparkles")
                .font(.system(size: iconSize * 0.43, weight: .bold))
                .foregroundColor(.white)
        }
    }
    
    private var wordDisplay: some View {
        VStack(spacing: 8) {
            Text("WORD OF THE DAY")
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.black)
                .foregroundColor(.blue)
                .tracking(2)
            
            Text(word.word)
                .font(.system(size: wordFontSize, weight: .black, design: .serif))
                .foregroundColor(.primary)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .shadow(color: .blue.opacity(0.2), radius: 2, x: 0, y: 2)
        }
    }
    
    private var contentSection: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("Definition")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .textCase(.uppercase)
                    .tracking(1)
                
                Text(word.meaning)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
            }
            
            VStack(spacing: 8) {
                Text("In Context")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .textCase(.uppercase)
                    .tracking(1)
                
                Text("“\(word.sentence)”")
                    .font(.body.italic())
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
            }
        }
    }
    
    private var glowingDivider: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.clear, .blue.opacity(0.6), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 2)
            .padding(.horizontal, 20)
    }
    
    private var countdownSection: some View {
        VStack(spacing: 8) {
            Text("Next word in")
                .font(.system(.caption, design: .rounded))
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text(timeRemaining)
                .font(.system(.title3, design: .monospaced))
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.blue.opacity(0.1))
                )
        }
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 28)
            .fill(.ultraThinMaterial)
            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
    
    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 28)
            .stroke(
                LinearGradient(
                    colors: [.blue.opacity(0.3), .purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
    }
}
