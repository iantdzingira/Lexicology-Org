//
//  LearningDataManager.swift
//  Lexicology Org
//
//  Created by Ian. T. Dzingira on 29/09/2025.
//
import SwiftUI
import Foundation

final class LearningDataManager: ObservableObject {
    private let wordsKey = "wordsLearnedCount"
    private let learnedIDsKey = "learnedWordIDs"
    private let streakKey = "currentStreak"
    private let lastCheckKey = "lastStreakCheckDate"
    
    @Published var wordsLearned: Int {
        didSet {
            UserDefaults.standard.set(wordsLearned, forKey: wordsKey)
        }
    }
    
    @Published var currentStreak: Int {
        didSet {
            UserDefaults.standard.set(currentStreak, forKey: streakKey)
        }
    }
    
    @Published var learnedWordIDs: Set<String> {
        didSet {
            if let encoded = try? JSONEncoder().encode(learnedWordIDs) {
                UserDefaults.standard.set(encoded, forKey: learnedIDsKey)
            }
        }
    }
    
    private var lastStreakCheckDate: Date? {
        didSet {
            UserDefaults.standard.set(lastStreakCheckDate, forKey: lastCheckKey)
        }
    }
    
    init() {
        self.wordsLearned = UserDefaults.standard.integer(forKey: wordsKey)
        self.currentStreak = UserDefaults.standard.integer(forKey: streakKey)
        self.lastStreakCheckDate = UserDefaults.standard.object(forKey: lastCheckKey) as? Date
        
        if let savedIDs = UserDefaults.standard.data(forKey: learnedIDsKey),
           let decodedIDs = try? JSONDecoder().decode(Set<String>.self, from: savedIDs) {
            self.learnedWordIDs = decodedIDs
        } else {
            self.learnedWordIDs = []
        }
        
        checkStreakMaintenance()
    }
    
    func hasLearned(wordID: UUID) -> Bool {
        return learnedWordIDs.contains(wordID.uuidString)
    }
    
    func wordLearned(entry: WordEntry) {
        if hasLearned(wordID: entry.customID) {
            return
        }
        
        learnedWordIDs.insert(entry.customID.uuidString)
        wordsLearned += 1
        updateStreak()
    }
    
    private func isSameDay(as date: Date) -> Bool {
        return Calendar.current.isDate(date, inSameDayAs: Date())
    }
    
    private func isYesterday(as date: Date) -> Bool {
        guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else { return false }
        return Calendar.current.isDate(date, inSameDayAs: yesterday)
    }
    
    private func updateStreak() {
        let now = Date()
        
        guard let lastDate = lastStreakCheckDate else {
            currentStreak = 1
            lastStreakCheckDate = now
            return
        }
        
        if isSameDay(as: lastDate) {
            return
        } else if isYesterday(as: lastDate) {
            currentStreak += 1
            lastStreakCheckDate = now
        } else {
            currentStreak = 1
            lastStreakCheckDate = now
        }
    }
    
    func checkStreakMaintenance() {
        guard let lastDate = lastStreakCheckDate else {
            return
        }
        
        if !isSameDay(as: lastDate) && !isYesterday(as: lastDate) {
            currentStreak = 0
        }
    }
}
