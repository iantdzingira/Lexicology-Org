//
//  My Words.swift
//  Lexicology Org
//
//  Created by Ian. T. Dzingira on 26/09/2025.
//
import SwiftUI
import SwiftData



struct WordsCreationParent: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var hSize
    
    @Query(sort: [SortDescriptor(\WordEntry.creationDate, order: .reverse)])
    private var allWords: [WordEntry]
    
    @State private var word = ""
    @State private var meaning = ""
    @State private var sentence = ""
    @FocusState private var focusedField: Field?
    @State private var selectedTab: Tab = .addNew
    @State private var searchText = ""
    @State private var sortOption: SortOption = .newestFirst
    @State private var wordToEdit: WordEntry? = nil
    @State private var showSuccess = false
    
    private var isRegular: Bool { hSize == .regular }
    
    enum Field: Hashable { case word, meaning, sentence }
    enum Tab { case addNew, myWords }
    
    enum SortOption: String, CaseIterable {
        case newestFirst = "Newest First"
        case oldestFirst = "Oldest First"
        case aToZ = "A → Z"
        case zToA = "Z → A"
    }
    
    private var filteredWords: [WordEntry] {
        let sortedWords = sortWords(allWords)
        if searchText.isEmpty {
            return sortedWords
        }
        
        return sortedWords.filter {
            $0.word.localizedCaseInsensitiveContains(searchText) ||
            $0.meaning.localizedCaseInsensitiveContains(searchText) ||
            $0.sentence.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private func sortWords(_ words: [WordEntry]) -> [WordEntry] {
        switch sortOption {
        case .newestFirst:
            return words.sorted { $0.creationDate > $1.creationDate }
        case .oldestFirst:
            return words.sorted { $0.creationDate < $1.creationDate }
        case .aToZ:
            return words.sorted { $0.word < $1.word }
        case .zToA:
            return words.sorted { $0.word > $1.word }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if isRegular {
                    responsiveSplitView
                } else {
                    compactTabView
                }

                if showSuccess {
                    successOverlay
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(isRegular ? .automatic : .large)
            .toolbar {
                if selectedTab == .myWords && !isRegular {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        sortMenu
                    }
                }
            }
        }
        .onChange(of: sortOption) { _ in }
        .onSubmit(handleSubmit)
        .sheet(item: $wordToEdit) { wordEntry in
            EditWordView(wordEntry: wordEntry)
        }
    }
    
    // MARK: - Subviews for Responsiveness
    
    private var compactTabView: some View {
        VStack(spacing: 0) {
            headerTabs
            
            switch selectedTab {
            case .addNew:
                addNewWordView
            case .myWords:
                myWordsView
            }
        }
    }
    
    private var responsiveSplitView: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                searchBar
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGroupedBackground))
                    .transition(.opacity)
                
                if filteredWords.isEmpty {
                    emptyStateView
                } else {
                    wordCollectionView
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .padding(.trailing, 1)
            
            Divider()
            
            addNewWordView
                .frame(maxWidth: .infinity)
                .background(Color(.systemGroupedBackground))
        }
    }
    
    private var navigationTitle: String {
        if isRegular {
            return "Vocabulary Builder"
        } else {
            return selectedTab == .addNew ? "Add New Word" : "My Collection"
        }
    }
    
    // MARK: - Original Component Views
    
    private var headerTabs: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                tabButton(title: "Create", icon: "plus.circle.fill", tab: .addNew)
                tabButton(title: "Collection", icon: "books.vertical.fill", tab: .myWords, count: allWords.count)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            if selectedTab == .myWords {
                searchBar
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .background(.regularMaterial)
        .overlay(
            Rectangle()
                .fill(Color.blue.opacity(0.1))
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    private func tabButton(title: String, icon: String, tab: Tab, count: Int? = nil) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                    
                    Text(title)
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)
                    
                    if tab == .myWords, let count = count, count > 0 {
                        Text("\(count)")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.blue)
                            )
                    }
                }
                .foregroundColor(selectedTab == tab ? .blue : .secondary)
                
                Rectangle()
                    .fill(Color.blue)
                    .frame(height: 2)
                    .scaleEffect(x: selectedTab == tab ? 1 : 0, y: 1, anchor: .center)
                    .opacity(selectedTab == tab ? 1 : 0)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.blue)
                .font(.system(size: 16, weight: .medium))
            
            TextField("Search your collection...", text: $searchText)
                .textFieldStyle(.plain)
                .submitLabel(.search)
            
            if !searchText.isEmpty {
                Button(action: {
                    withAnimation(.spring()) {
                        searchText = ""
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .transition(.scale)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
    
    private var addNewWordView: some View {
        ScrollView {
            VStack(spacing: isRegular ? 30 : 24) {
                VStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundColor(.blue)
                    Text("Create New Word")
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                    Text("Build your personal vocabulary")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, isRegular ? 40 : 20)
                
                VStack(spacing: isRegular ? 25 : 20) {
                    inputField(
                        title: "WORD",
                        placeholder: "Enter the word",
                        text: $word,
                        field: .word
                    )
                    
                    inputField(
                        title: "DEFINITION",
                        placeholder: "Provide the meaning",
                        text: $meaning,
                        field: .meaning
                    )
                    
                    inputField(
                        title: "USAGE EXAMPLE",
                        placeholder: "Show it in context",
                        text: $sentence,
                        field: .sentence
                    )
                }
                .padding(.horizontal, isRegular ? 30 : 16)
                
                saveButton
                    .padding(.horizontal, isRegular ? 30 : 16)
                    .padding(.top, isRegular ? 30 : 20)
                
                Spacer()
            }
            .frame(maxWidth: isRegular ? 600 : .infinity)
        }
    }
    
    private var myWordsView: some View {
        Group {
            if filteredWords.isEmpty {
                emptyStateView
            } else {
                wordCollectionView
            }
        }
    }
    
    private var wordCollectionView: some View {
        List {
            ForEach(filteredWords) { wordEntry in
                WordCard(wordEntry: wordEntry)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .contextMenu {
                        
                        Button {
                            wordToEdit = wordEntry
                        } label: {
                            Label("Edit Word", systemImage: "pencil.circle.fill")
                        }
                        
                        Divider()
                        
                        Button {
                            UIPasteboard.general.string = wordEntry.word
                        } label: {
                            Label("Copy Word", systemImage: "doc.on.doc")
                        }
                        
                        Button {
                            UIPasteboard.general.string = wordEntry.meaning
                        } label: {
                            Label("Copy Definition", systemImage: "text.book.closed")
                        }
                    }
                    
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            deleteWord(wordEntry: wordEntry)
                        } label: {
                            Label("Delete", systemImage: "trash.fill")
                        }
                    }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "text.book.closed")
                .font(.system(size: 60))
                .foregroundColor(.blue.opacity(0.3))
            
            VStack(spacing: 8) {
                Text(searchText.isEmpty ? "Your Collection is Empty" : "No Matches Found")
                    .font(.title2.bold())
                
                Text(searchText.isEmpty ?
                     "Create your first word to start building your vocabulary" :
                     "Try adjusting your search or explore different terms"
                )
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, isRegular ? 40 : 40)
            }
            
            if searchText.isEmpty && !isRegular {
                Button(action: {
                    withAnimation(.spring()) {
                        selectedTab = .addNew
                    }
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Create First Word")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Color.blue)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var sortMenu: some View {
        Menu {
            ForEach(SortOption.allCases, id: \.self) { option in
                Button {
                    withAnimation(.spring()) {
                        sortOption = option
                    }
                } label: {
                    HStack {
                        Text(option.rawValue)
                        if sortOption == option {
                            Image(systemName: "checkmark")
                                .fontWeight(.bold)
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.blue)
                .padding(8)
                .background(
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                )
        }
    }
    
    private var saveButton: some View {
        let isEnabled = !word.trimmed.isEmpty && !meaning.trimmed.isEmpty && !sentence.trimmed.isEmpty
        
        return Button(action: saveWord) {
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                
                Text("Add to Collection")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isEnabled ? Color.blue : Color.gray)
                    .shadow(
                        color: isEnabled ? .blue.opacity(0.4) : .clear,
                        radius: 8, x: 0, y: 4
                    )
            )
        }
        .disabled(!isEnabled)
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isEnabled)
    }
    
    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                
                Text("Word Added!")
                    .font(.title2.bold())
                    .foregroundColor(.white)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
            )
        }
        .transition(.opacity)
    }
    
    private func inputField(title: String, placeholder: String, text: Binding<String>, field: Field) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(.caption, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(.blue)
                .textCase(.uppercase)
                .tracking(1.2)
            
            TextField(placeholder, text: text)
                .focused($focusedField, equals: field)
                .submitLabel(field == .sentence ? .done : .next)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                )
        }
    }
    
    private func handleSubmit() {
        switch focusedField {
        case .word:
            focusedField = .meaning
        case .meaning:
            focusedField = .sentence
        default:
            focusedField = nil
        }
    }
    
    private func saveWord() {
        let trimmedWord = word.trimmed
        let trimmedMeaning = meaning.trimmed
        let trimmedSentence = sentence.trimmed
        
        let newWord = WordEntry(
            word: trimmedWord,
            meaning: trimmedMeaning,
            sentence: trimmedSentence,
            source: "User"
        )
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            modelContext.insert(newWord)
            
            do {
                try modelContext.save()
                print("✅ Successfully inserted and saved word: \(newWord.word)")
            } catch {
                print("❌ SWIFTDATA ERROR: Failed to save context after inserting word: \(error.localizedDescription)")
            }
        }

        withAnimation(.spring()) {
            showSuccess = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring()) {
                showSuccess = false
                word = ""
                meaning = ""
                sentence = ""
                selectedTab = .myWords
                focusedField = nil
            }
        }
    }
    
    private func deleteWord(wordEntry: WordEntry) {
        withAnimation(.easeOut(duration: 0.3)) {
            modelContext.delete(wordEntry)
            do {
                try modelContext.save()
                print("✅ Successfully deleted and saved word: \(wordEntry.word)")
            } catch {
                print("❌ SWIFTDATA ERROR: Failed to save context after deleting word: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - EditWordView & Extensions
struct EditWordView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @Bindable var wordEntry: WordEntry
    @State private var originalMeaning: String
    
    init(wordEntry: WordEntry) {
        self._wordEntry = Bindable(wordEntry)
        self._originalMeaning = State(initialValue: wordEntry.meaning)
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text(wordEntry.word)
                    .font(.title2.bold())
                    .foregroundColor(.blue)
                
                Divider()
                
                Text("Edit Definition")
                    .font(.headline)
                
                TextEditor(text: $wordEntry.meaning)
                    .frame(height: 200)
                    .border(Color.gray)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Editing \(wordEntry.word)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        wordEntry.meaning = originalMeaning
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        do {
                            try modelContext.save()
                            print("✅ Successfully saved context after editing word: \(wordEntry.word)")
                        } catch {
                            print("❌ SWIFTDATA ERROR: Failed to save context after editing word: \(error.localizedDescription)")
                        }
                        dismiss()
                    }
                    .disabled(wordEntry.meaning.trimmed.isEmpty)
                }
            }
            .frame(minWidth: 400, idealWidth: 500)
        }
    }
}

extension String {
    var trimmed: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

#Preview {
    WordsCreationParent()
        .modelContainer(for: WordEntry.self, inMemory: true)
}
