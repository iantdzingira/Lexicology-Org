//
//  APIWordEntry.swift
//  Lexicology Org
//
//  Created by Ian. T. Dzingira on 17/11/2025.
//
import SwiftUI

// MARK: - 1. Merriam-Webster API Data Models (FIXED HASHABLE CONFORMANCE)

struct MWEntry: Decodable, Identifiable {
    var id: String { meta.id }
    let meta: MetaData
    let hwi: HWIData
    let fl: String?
    let def: [DefinitionSection]?
    let shortdef: [String]?
    let et: [[String]]?
    let cxs: [CrossReference]?
    
    var isSuggestionList: Bool { meta.id.isEmpty && fl == nil }
}

struct MetaData: Decodable, Hashable { // ✅ HASHABLE ADDED
    let id: String
}

struct HWIData: Decodable, Hashable { // ✅ HASHABLE ADDED
    let hw: String
    let prs: [PronunciationData]?
}

struct PronunciationData: Decodable, Hashable { // ✅ HASHABLE ADDED
    let mw: String?
}

struct DefinitionSection: Decodable, Hashable { // ✅ HASHABLE ADDED
    let sseq: [[[SSequenceItem]]]?
}

struct SSequenceItem: Decodable, Hashable {
    let sense: SenseData?
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        
        // Safely skip the first element (type indicator)
        if container.count != 0 {
            let _ = try? container.decode(String.self)
        }
        
        if !container.isAtEnd {
            self.sense = try? container.decode(SenseData.self)
        } else {
            self.sense = nil
        }
    }
}

struct SenseData: Decodable, Hashable { // ✅ HASHABLE ADDED
    let dt: [[RawDefinitionText]]?
    let sn: String?
}

struct RawDefinitionText: Decodable, Hashable { // ✅ HASHABLE ADDED
    let text: String?
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let _ = try container.decode(String.self)
        self.text = try? container.decode(String.self)
    }
}

struct CrossReference: Decodable, Identifiable {
    var id: String { cxtis?.first?.cxt ?? UUID().uuidString }
    let cxl: String?
    let cxtis: [CrossReferenceText]?
}

struct CrossReferenceText: Decodable {
    let cxt: String?
}

struct MWAPIError: Error {
    let title: String
    let message: String
}

// MARK: - 2. Main Search View

struct DictionarySearchView: View {
    @State private var searchText: String = ""
    @State private var searchResults: [MWEntry] = []
    @State private var suggestions: [String] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @FocusState private var isSearchFocused: Bool
    
    private let apiKey = "96e696b2-dc14-4060-a6af-ba1b52decafa"
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Searching...").scaleEffect(1.5)
                } else if !searchResults.isEmpty {
                    MWResultsListView(searchResults: searchResults)
                } else if !suggestions.isEmpty {
                    MWSuggestionsView(word: searchText, suggestions: suggestions)
                } else if let message = errorMessage {
                    ContentUnavailableView("Search Error", systemImage: "exclamationmark.triangle.fill", description: Text(message))
                } else {
                    ContentUnavailableView("Merriam-Webster Collegiate", systemImage: "book.closed.fill", description: Text("Enter a word above to search the dictionary."))
                }
            }
            .navigationTitle("MW Search")
            .searchable(text: $searchText, prompt: "Search for a word...")
            .onSubmit(of: .search) {
                if !searchText.isEmpty {
                    isSearchFocused = false
                    Task { await fetchDefinition(for: searchText) }
                }
            }
        }
    }
    
    @MainActor
    private func fetchDefinition(for word: String) async {
        let trimmedWord = word.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let urlString = "https://www.dictionaryapi.com/api/v3/references/collegiate/json/\(trimmedWord)?key=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return }
        
        isLoading = true
        searchResults = []
        suggestions = []
        errorMessage = nil
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // Try 1: Decode as Dictionary Entries
            if let entries = try? JSONDecoder().decode([MWEntry].self, from: data), !entries.isEmpty {
                if entries.count == 1 && entries.first?.isSuggestionList == true {
                    throw MWAPIError(title: "Word not found", message: "Result was a single suggestion entry.")
                }
                self.searchResults = entries
            // Try 2: Decode as Suggestions (String Array)
            } else if let suggestionsArray = try? JSONDecoder().decode([String].self, from: data), !suggestionsArray.isEmpty {
                self.suggestions = suggestionsArray
                self.errorMessage = "Word not found. Did you mean one of these?"
            } else {
                throw MWAPIError(title: "Word not found", message: "The dictionary does not contain an entry for '\(trimmedWord)'.")
            }
        } catch let apiError as MWAPIError {
            self.errorMessage = apiError.message
        } catch {
            self.errorMessage = "A network error occurred."
        }
        
        isLoading = false
    }
}


// MARK: - 3. Results List View & Suggestions View

struct MWResultsListView: View {
    let searchResults: [MWEntry]
    
    var body: some View {
        List {
            ForEach(searchResults) { entry in
                NavigationLink {
                    MWWordDetailView(entry: entry)
                } label: {
                    VStack(alignment: .leading) {
                        Text(entry.hwi.hw.uppercased()).font(.headline)
                        if let fl = entry.fl, let shortdef = entry.shortdef?.first {
                            Text("(\(fl)) - \(shortdef.replacingOccurrences(of: "{bc}", with: ""))")
                                .font(.caption)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .navigationTitle("Search Results")
    }
}

struct MWSuggestionsView: View {
    let word: String
    let suggestions: [String]
    
    var body: some View {
        List {
            Section("Suggestions for '\(word)'") {
                ForEach(suggestions, id: \.self) { Text($0) }
            }
        }
    }
}


// MARK: - 4. Detail View (Refactored for stability)

struct MWWordDetailView: View {
    let entry: MWEntry
    
    private func cleanMarkup(_ text: String?) -> String {
        guard let text = text else { return "" }
        var cleaned = text.replacingOccurrences(of: "{bc}", with: "")
        let regex = try? NSRegularExpression(pattern: "\\{.*?\\}", options: [])
        if let regex = regex {
             cleaned = regex.stringByReplacingMatches(in: cleaned, options: [], range: NSRange(location: 0, length: cleaned.utf16.count), withTemplate: "")
        }
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // Flattens the deeply nested sseq array and filters for valid sense items.
    private var parsedDefinitions: [SSequenceItem] {
        // 1. Get the raw, deeply nested sseq data (Explicitly typed)
        let rawSseq: [[SSequenceItem]] = entry.def?
            .flatMap { $0.sseq ?? [] }
            .flatMap { $0 } ?? []

        // 2. Flatten the nested arrays into a single list of items (Explicitly typed)
        let flattenedItems: [SSequenceItem] = rawSseq.flatMap { $0 }

        // 3. Filter and process the items in the list (Explicitly typed filtering)
        let processedItems: [SSequenceItem] = flattenedItems
            .compactMap { item in
                // Only return the item if its 'sense' property is non-nil
                return item.sense != nil ? item : nil
            }
            .filter { item in
                // Only keep items that have a definitional text present
                return item.sense?.dt?.first?.first?.text != nil
            }

        return processedItems
    }
    
    private var etymologyText: String? {
       
        return entry.et?
            .first?
            .last
            .map { cleanMarkup($0) }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                
                // --- Header (Word, Part of Speech, Phonetics) ---
                VStack(alignment: .leading, spacing: 5) {
                    Text(cleanMarkup(entry.hwi.hw)).font(.largeTitle.bold())
                    
                    if let fl = entry.fl {
                        Text(fl.capitalized).font(.title2.bold()).foregroundColor(.blue)
                    }
                    if let pron = entry.hwi.prs?.first?.mw {
                        Text(pron).font(.title3).foregroundColor(.secondary)
                    }
                }
                
                // --- Definitions ---
                if !parsedDefinitions.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Definitions:").font(.headline)
                        
                        ForEach(parsedDefinitions, id: \.hashValue) { item in
                            if let sense = item.sense,
                               let definitionText = sense.dt?.first?.first?.text {
                                
                                Text("\(sense.sn ?? "•") \(cleanMarkup(definitionText))")
                                    .font(.body)
                            }
                        }
                    }
                }
                
                // --- Etymology ---
                if let etymology = etymologyText {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Etymology:").font(.headline)
                        Text(etymology).font(.callout).foregroundColor(.gray)
                    }
                }

                // --- Cross-References ---
                if let cxs = entry.cxs, !cxs.isEmpty {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Related Terms:").font(.headline)
                        ForEach(cxs) { cx in
                            if let ref = cx.cxtis?.first?.cxt {
                                Text("See also: \(ref)").font(.callout).foregroundColor(.purple)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(cleanMarkup(entry.hwi.hw).capitalized)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    DictionarySearchView()
}
