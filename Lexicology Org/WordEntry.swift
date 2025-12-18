//
//  WordEntry.swift
//  Lexicology Org
//
//  Created by Ian. T. Dzingira on 29/09/2025.
//

import SwiftData
import Foundation

@Model
class WordEntry: Identifiable, Codable, Hashable, Equatable {
    
    var word: String
    var meaning: String
    var sentence: String
    var source: String?

    var isLearned: Bool = false
    var customID: UUID = UUID()
    var creationDate: Date = Date()
    
    init(word: String, meaning: String, sentence: String, source: String? = "Default Source") {
        self.word = word
        self.meaning = meaning
        self.sentence = sentence
        self.source = source
        self.customID = UUID()
        self.creationDate = Date()
        self.isLearned = false
    }
    
    enum CodingKeys: String, CodingKey {
        case word, meaning, sentence, source
        case isLearned, creationDate, customID
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.word = try container.decode(String.self, forKey: .word)
        self.meaning = try container.decode(String.self, forKey: .meaning)
        self.sentence = try container.decode(String.self, forKey: .sentence)
        self.source = try container.decodeIfPresent(String.self, forKey: .source)
        
        self.isLearned = (try? container.decodeIfPresent(Bool.self, forKey: .isLearned)) ?? false
        self.creationDate = (try? container.decodeIfPresent(Date.self, forKey: .creationDate)) ?? Date()
        self.customID = (try? container.decodeIfPresent(UUID.self, forKey: .customID)) ?? UUID()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(word, forKey: .word)
        try container.encode(meaning, forKey: .meaning)
        try container.encode(sentence, forKey: .sentence)
        try container.encode(source, forKey: .source)
        
        try container.encode(isLearned, forKey: .isLearned)
        try container.encode(creationDate, forKey: .creationDate)
        try container.encode(customID, forKey: .customID)
    }
    
    static func == (lhs: WordEntry, rhs: WordEntry) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static let example = WordEntry(
        word: "Serendipity",
        meaning: "The occurrence of events by chance in a happy or beneficial way",
        sentence: "Finding this beautiful café was a moment of pure serendipity.",
        source: "Lexicology"
    )
    
    static let anotherExample = WordEntry(
        word: "Ephemeral",
        meaning: "Lasting for a very short time",
        sentence: "The beauty of cherry blossoms is ephemeral but unforgettable.",
        source: "Lexicology"
    )
}
