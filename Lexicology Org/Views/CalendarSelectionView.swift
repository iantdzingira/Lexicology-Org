//
//  CalendarSelectionView.swift
//  Lexicology Org
//
//  Created by Ian. T. Dzingira on 18/12/2025.
//
import SwiftUI

struct CalendarSelectionView: View {
    @Binding var selectedDate: Date
    @Binding var showingCalendar: Bool
    
    var body: some View {
        NavigationStack {
            DatePicker("Select Date", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
                .datePickerStyle(.graphical)
                .tint(.blue)
                .navigationTitle("Choose Date")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showingCalendar = false
                        }
                        .fontWeight(.semibold)
                    }
                }
                .padding()
        }
        .presentationDetents([.medium])
    }
}

class ParticleSystem: ObservableObject {
    @Published var particles: [Particle] = []
    private var timer: Timer?
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.createParticle()
        }
    }
    
    private func createParticle() {
        let particle = Particle()
        particles.append(particle)
        
        particles.removeAll { $0.opacity <= 0 }
    }
}

struct Particle {
    var x: Double = Double.random(in: 0...1)
    var y: Double = Double.random(in: 0...1)
    var size: Double = Double.random(in: 1...3)
    var opacity: Double = 1.0
    var speed: Double = Double.random(in: 0.001...0.005)
}

struct ParticleField: View {
    @ObservedObject var system: ParticleSystem
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                for particle in system.particles {
                    let rect = CGRect(
                        x: particle.x * size.width,
                        y: particle.y * size.height,
                        width: particle.size,
                        height: particle.size
                    )
                    context.fill(
                        Path(ellipseIn: rect),
                        with: .color(.blue.opacity(particle.opacity))
                    )
                }
            }
        }
        .onAppear {
            system.start()
        }
    }
}
