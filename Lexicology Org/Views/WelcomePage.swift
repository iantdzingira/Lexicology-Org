//
//  ContentView.swift
//  Lexicology Org
//
//  Created by Ian. T. Dzingira on 23/09/2025.
//
import SwiftUI

struct WelcomePage: View {
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    @State private var shouldNavigateToOnboarding: Bool = false
    @State private var shouldNavigateToContent: Bool = false
    @State private var progress: CGFloat = 0.0
    @State private var timer: Timer? = nil
    @State private var currentGradientIndex: Int = 0
    
    private let gradientColors: [Color] = [
        .purple, .blue, .green, .orange, .red, .cyan, .accentColor
    ]

    @Environment(\.horizontalSizeClass) var hSize
    @Environment(\.verticalSizeClass) var vSize

    private var layout: DeviceLayout {
        DeviceLayout(horizontal: hSize, vertical: vSize)
    }
    
    private var isWideLayout: Bool {
        switch layout {
        case .iPadCompact, .iPadRegular, .largeScreen:
            return true
        case .iPhonePortrait, .iPhoneLandscape:
            return false
        }
    }
    
    private var isTallLayout: Bool {
        switch layout {
        case .iPhonePortrait, .iPadRegular, .largeScreen:
            return true
        case .iPhoneLandscape, .iPadCompact:
            return false
        }
    }

    private var imageSize: CGFloat {
        switch layout {
        case .largeScreen:
            return 400
        case .iPadRegular:
            return 380
        case .iPadCompact:
            return 350
        case .iPhonePortrait:
            return 300
        case .iPhoneLandscape:
            return 250
        }
    }
    
    private var titleFontSize: CGFloat {
        switch layout {
        case .largeScreen:
            return 56
        case .iPadRegular:
            return 52
        case .iPadCompact:
            return 48
        case .iPhonePortrait:
            return 42
        case .iPhoneLandscape:
            return 36
        }
    }
    
    private var horizontalSpacing: CGFloat {
        isWideLayout ? 64 : 32
    }
    
    private var verticalSpacing: CGFloat {
        isTallLayout ? 32 : 24
    }
    
    private var paddingMultiplier: CGFloat {
        isWideLayout ? 2 : 1
    }

    var body: some View {
        ZStack {
            animatedBackgroundGradient
                .ignoresSafeArea()

            Group {
                switch layout {
                case .iPadRegular, .largeScreen, .iPadCompact:
                    HStack(spacing: horizontalSpacing) {
                        heroImage
                            .frame(maxWidth: 400)

                        VStack(alignment: .leading, spacing: verticalSpacing) {
                            appTitleAndSubtitle
                            
                            Spacer()
                            
                            progressAndNavigation
                        }
                    }
                    .padding(horizontalSpacing * paddingMultiplier)
                    .frame(maxWidth: 1000)
                    
                case .iPhonePortrait, .iPhoneLandscape:
                    VStack(spacing: verticalSpacing) {
                        Spacer()
                        
                        heroImage
                        
                        appTitleAndSubtitle
                        
                        Spacer()
                        
                        progressAndNavigation
                            .padding(.bottom, horizontalSpacing)
                    }
                    .padding(.horizontal, horizontalSpacing)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            startProgressTimer()
            startGradientTimer()
        }
        .onDisappear {
            stopProgressTimer()
            stopGradientTimer()
        }
    }

    private var appTitleAndSubtitle: some View {
        VStack(spacing: 12) {
            Text("Lexicology")
                .font(.system(size: titleFontSize, weight: .heavy, design: .rounded))
                .foregroundColor(.white)

            Text("Your personal dictionary")
                .font(isWideLayout ? .title : .title3)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.8))
        }
        .multilineTextAlignment(.center)
    }

    private var progressAndNavigation: some View {
        VStack(spacing: 16) {
            progressView
                .frame(maxWidth: .infinity)
            
            Text("\(Int(progress * 100))%")
                .font(.system(.footnote, design: .rounded))
                .foregroundColor(.white)
            
            NavigationLink(
                destination: UserInfoView(),
                isActive: $shouldNavigateToOnboarding,
                label: { EmptyView() }
            )
            .hidden()
            
        }
    }
    
    private var animatedBackgroundGradient: some View {
        LinearGradient(
            colors: [
                gradientColors[currentGradientIndex],
                gradientColors[(currentGradientIndex + 1) % gradientColors.count]
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .animation(.easeInOut(duration: 4.0), value: currentGradientIndex)
    }
    
    private var progressView: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 8)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white)
                    .frame(width: max(0, progress * geometry.size.width), height: 8)
                    .animation(.linear(duration: 0.1), value: progress)
            }
        }
        .frame(height: 8)
    }
    
    private func startProgressTimer() {
        stopProgressTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if self.progress < 1.0 {
                self.progress += 0.05
            } else {
                stopProgressTimer()
                
                if hasCompletedOnboarding {
                    self.shouldNavigateToContent = true
                } else {
                    self.shouldNavigateToOnboarding = true
                }
            }
        }
    }
    
    private func stopProgressTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func startGradientTimer() {
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            withAnimation {
                self.currentGradientIndex = (self.currentGradientIndex + 1) % self.gradientColors.count
            }
        }
    }
    
    private func stopGradientTimer() { }

    private var heroImage: some View {
        Image("lex")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: imageSize, maxHeight: imageSize)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white.opacity(0.2))
                    .shadow(
                        color: .black.opacity(0.2),
                        radius: 16,
                        x: 0,
                        y: 8
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
            .padding(.bottom, 8)
    }
}
#Preview {
    WelcomePage()
}
