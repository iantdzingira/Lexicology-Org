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

struct ContentView: View {
    @State private var words: [Word] = []
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            Group {
                if let error = errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                } else if words.isEmpty {
                    ProgressView()
                } else {
                    List(words) { word in
                        VStack(alignment: .leading) {
                            Text(word.word).font(.headline)
                            Text(word.meaning).foregroundColor(.secondary)
                            Text(word.sentence).italic()
                        }
                    }
                }
            }
            .navigationTitle("Dictionary")
            .task {
                do {
                    words = try loadWords()
                } catch WordLoaderError.fileNotFound {
                    errorMessage = "Dictionary file not found"
                } catch WordLoaderError.invalidData {
                    errorMessage = "Invalid data in file"
                } catch WordLoaderError.decodingFailed {
                    errorMessage = "Failed to read dictionary"
                } catch {
                    errorMessage = "Unknown error occurred"
                }
            }
        }
    }
}


#Preview {
    ContentView()
}
