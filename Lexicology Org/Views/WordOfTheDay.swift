//
//  Word Of The Day.swift
//  Lexicology Org
//
//  Created by Ian. T. Dzingira on 25/09/2025.
//
import SwiftUI

struct WordOfTheDay: View {
    @State private var currentWord: WordEntry?
    @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    @State private var showingCalendar = false
    @State private var timeRemaining: String = ""
    @State private var cardFlip = false
    @State private var glowOpacity: Double = 0.3
    @State private var particleSystem = ParticleSystem()
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

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
    
    private var cardMaxWidth: CGFloat {
        isWideLayout ? 600 : .infinity
    }
    
    private var cardVerticalPadding: CGFloat {
        switch layout {
        case .largeScreen, .iPadRegular:
            return 50
        case .iPadCompact:
            return 40
        case .iPhonePortrait:
            return 30
        case .iPhoneLandscape:
            return 15
        }
    }

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            ParticleField(system: particleSystem)
                .opacity(0.6)
                .blendMode(.plusLighter)
            
            ScrollView {
                VStack(spacing: 0) {
    
                    headerSection
                        .padding(.top, cardVerticalPadding)
                    
                    if let word = currentWord {
                        WordCardView(
                            word: word,
                            timeRemaining: timeRemaining,
                            cardFlip: $cardFlip,
                            glowOpacity: $glowOpacity
                        )
                        .frame(maxWidth: cardMaxWidth)
                        .padding(.horizontal, isWideLayout ? 60 : 20)
                        .padding(.top, cardVerticalPadding)
                        .padding(.bottom, cardVerticalPadding * 2)
                    } else {
                        loadingView
                    }
                }
            }
        }
        .onAppear {
            loadWordForDate(selectedDate)
            updateTimeRemaining()
            startAnimations()
        }
        .onReceive(timer) { _ in
            updateTimeRemaining()
        }
        .sheet(isPresented: $showingCalendar) {
            CalendarSelectionView(selectedDate: $selectedDate, showingCalendar: $showingCalendar)
        }
        .onChange(of: selectedDate) {
            loadWordForDate(selectedDate)
        }
    }
    
    private var backgroundGradient: some View {
        AngularGradient(
            gradient: Gradient(colors: [
                Color.blue.opacity(0.1),
                Color.purple.opacity(0.1),
                Color.blue.opacity(0.05),
                Color.indigo.opacity(0.1)
            ]),
            center: .topLeading,
            angle: .degrees(glowOpacity * 360)
        )
        .animation(.linear(duration: 10).repeatForever(autoreverses: false), value: glowOpacity)
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("DAILY LEXICON")
                        .font(.system(.caption, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .tracking(2)
                    
                    Text(selectedDate, style: .date)
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Button {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showingCalendar = true
                    }
                } label: {
                    Image(systemName: "calendar.badge.clock")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .padding(12)
                        .background(
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                        )
                }
            }
            .padding(.horizontal, 20)
            
            dayProgressBar
        }
    }
    
    private var dayProgressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 3)
                
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: dayProgress * geometry.size.width, height: 3)
                    .shadow(color: .blue.opacity(0.3), radius: 2, x: 0, y: 0)
            }
        }
        .frame(height: 3)
        .padding(.horizontal, 20)
    }
    
    private var dayProgress: Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let totalSeconds = endOfDay.timeIntervalSince(startOfDay)
        let elapsedSeconds = now.timeIntervalSince(startOfDay)
        
        return min(elapsedSeconds / totalSeconds, 1.0)
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.blue)
            
            Text("Loading today's wisdom...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            glowOpacity = 0.8
        }

        particleSystem.start()
    }
    
    private func loadWordForDate(_ date: Date) {
        guard let words = loadWords() else {
            currentWord = nil
            return
        }

        let calendar = Calendar.current
        let referenceDate = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1))!
        let dayOffset = calendar.dateComponents([.day], from: referenceDate, to: date).day ?? 0
        let effectiveOffset = max(0, dayOffset)

        if !words.isEmpty {
            let index = effectiveOffset % words.count
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                currentWord = words[index]
                cardFlip.toggle()
            }
        } else {
            currentWord = nil
        }
    }

    private func loadWords() -> [WordEntry]? {
        guard let url = Bundle.main.url(forResource: "words", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let words = try? JSONDecoder().decode([WordEntry].self, from: data) else {
            return nil
        }
        return words
    }

    private func updateTimeRemaining() {
        let calendar = Calendar.current
        let now = Date()

        guard let tomorrowMidnight = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) else {
            timeRemaining = "--:--:--"
            return
        }

        let components = calendar.dateComponents([.hour, .minute, .second], from: now, to: tomorrowMidnight)

        if let hours = components.hour,
           let minutes = components.minute,
           let seconds = components.second {
            timeRemaining = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            timeRemaining = "--:--:--"
        }
    }
}

#Preview {
WordOfTheDay()
}
