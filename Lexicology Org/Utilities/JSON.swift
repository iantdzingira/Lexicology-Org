//
//  Word.swift
//  Lexicology Org
//
//  Created by Ian. T. Dzingira on 29/09/2025.
//
import Foundation
import SwiftUI

struct Word: Codable, Identifiable {
    let id = UUID()
    let word: String
    let meaning: String
    let sentence: String
    
    enum CodingKeys: String, CodingKey {
        case word, meaning, sentence
    }
}

enum WordLoaderError: Error {
    case fileNotFound
    case invalidData
    case decodingFailed
}

func loadWords() throws -> [Word] {

    guard let url = Bundle.main.url(forResource: "words", withExtension: "json") else {
        throw WordLoaderError.fileNotFound
    }
    
    let data: Data
    do {
        data = try Data(contentsOf: url)
    } catch {
        throw WordLoaderError.invalidData
    }
    
 
    do {
        let decoder = JSONDecoder()
        return try decoder.decode([Word].self, from: data)
    } catch {
        throw WordLoaderError.decodingFailed
    }
}

extension DecodingError.Context {
    var codingPathString: String {
        codingPath.map { $0.stringValue }.joined(separator: " → ")
    }
}
