//
//  SettingsManager.swift
//  Lexicology Org
//
//  Created by Ian. T. Dzingira on 29/09/2025.
//
import SwiftUI

struct WordDictionaryView: View {
    @State private var searchText = ""
    @State private var allEntries: [WordEntry] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var path = NavigationPath()
    @State private var showErrorAlert = false

    @Environment(\.horizontalSizeClass) private var hSize
    
    private let accentColor = Color.blue
    
    private var isRegular: Bool { hSize == .regular }
    
    private var filteredEntries: [WordEntry] {
        guard !searchText.isEmpty else { return allEntries }
        
        return allEntries.filter {
            $0.word.localizedCaseInsensitiveContains(searchText) ||
            $0.meaning.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private var groupedEntries: [String: [WordEntry]] {
        Dictionary(grouping: filteredEntries) {
            String($0.word.prefix(1).uppercased())
        }
    }
    
    private var sectionHeaders: [String] {
        groupedEntries.keys.sorted()
    }

    var body: some View {
        if isRegular {
            NavigationSplitView {
                listView
                    .navigationTitle("Dictionary")
                    .searchable(text: $searchText, placement: .automatic)
            } detail: {
                if let firstEntry = filteredEntries.first {
                    WordDetailView(entry: firstEntry)
                } else {
                    ContentUnavailableView("Select a Word", systemImage: "text.magnifyingglass")
                }
            }
            .task { await loadWords() }
            .refreshable { await loadWords() }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("Retry") {
                    Task { await loadWords() }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "An unexpected error occurred.")
            }
        } else {
            NavigationStack(path: $path) {
                contentView
                    .navigationTitle("Dictionary")
                    .navigationBarTitleDisplayMode(.inline)
                    .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
                    .navigationDestination(for: WordEntry.self) { entry in
                        WordDetailView(entry: entry)
                    }
                    .refreshable {
                        await loadWords()
                    }
                    .task { await loadWords() }
                    .alert("Error", isPresented: $showErrorAlert) {
                        Button("Retry") {
                            Task { await loadWords() }
                        }
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        Text(errorMessage ?? "An unexpected error occurred.")
                    }
            }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if isLoading {
            ProgressView("Loading...")
                .tint(accentColor)
        } else if allEntries.isEmpty && errorMessage == nil {
            emptyStateView
        } else if filteredEntries.isEmpty && !searchText.isEmpty {
            ContentUnavailableView.search(text: searchText)
        } else {
            listView
        }
    }
    
    private var listView: some View {
        List {
            if isLoading {
                ProgressView("Loading...")
                    .tint(accentColor)
            }
            ForEach(sectionHeaders, id: \.self) { letter in
                Section {
                    ForEach(groupedEntries[letter]!.sorted(by: { $0.word < $1.word })) { entry in
                        NavigationLink(value: entry) {
                            WordRowView(entry: entry)
                        }
                    }
                } header: {
                    Text(letter)
                        .font(.headline)
                        .foregroundColor(accentColor)
                }
            }
        }
        .listStyle(.plain)
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView(
            "No Words Found",
            systemImage: "text.book.closed",
            description: Text("Pull down to refresh or check your configuration.")
        )
    }
    
    private func loadWords() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await Task.sleep(nanoseconds: 500_000_000)
            
            if let url = Bundle.main.url(forResource: "words", withExtension: "json") {
                let data = try Data(contentsOf: url)
                let entries = try JSONDecoder().decode([WordEntry].self, from: data)
                
                let uniqueEntries = removeDuplicates(from: entries)
                
                await MainActor.run {
                    allEntries = uniqueEntries
                }
            } else {
                await MainActor.run {
                    
                    allEntries = [
                        WordEntry.example,
                        WordEntry.anotherExample
                    ]
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = parseError(error)
                showErrorAlert = true
            }
        }
        
        isLoading = false
    }
    
    private func removeDuplicates(from entries: [WordEntry]) -> [WordEntry] {
        var uniqueWords = Set<String>()
        var uniqueEntries: [WordEntry] = []
        
        for entry in entries {
            let lowercaseWord = entry.word.lowercased()
            if !uniqueWords.contains(lowercaseWord) {
                uniqueWords.insert(lowercaseWord)
                uniqueEntries.append(entry)
            }
        }
        
        return uniqueEntries
    }
    
    private func parseError(_ error: Error) -> String {
        switch error {
        case let decodingError as DecodingError:
            return handleDecodingError(decodingError)
        case let urlError as URLError:
            return urlError.code == .fileDoesNotExist ?
                "Word list file not found." :
                urlError.localizedDescription
        default:
            return error.localizedDescription
        }
    }
    
    private func handleDecodingError(_ error: DecodingError) -> String {
        switch error {
        case .dataCorrupted(let context):
            return "Invalid data format: \(context.debugDescription)"
        case .keyNotFound(let key, let context):
            return "Missing field '\(key.stringValue)' at \(context.codingPathString)"
        case .typeMismatch(let type, let context):
            return "Type mismatch for '\(type)' at \(context.codingPathString)"
        case .valueNotFound(let type, let context):
            return "Missing value for '\(type)' at \(context.codingPathString)"
        @unknown default:
            return "Decoding error occurred."
        }
    }
}

struct WordDictionaryView_Previews: PreviewProvider {
    static var previews: some View {
        WordDictionaryView()
    }
}

