//
//  SignUpView.swift
//  Lexicology Org
//
//  Created by Ian. T. Dzingira on 23/09/2025.
//
import SwiftUI

enum WordCategory: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }

    case technical = "Technical"
    case programming = "Programming"
    case cooking = "Cooking"
    case sports = "Sports"
    case history = "History"
    case science = "Science"
    case arts = "Arts & Culture"
    case slang = "Slang"
    case academic = "Academic"
    case colloquial = "Colloquial"
    case finance = "Finance"
    case philosophy = "Philosophy"
    case literature = "Literature"
    case medical = "Medical"
    case technology = "Technology"
    
    var icon: String {
        switch self {
        case .technical: return "gear"
        case .programming: return "keyboard"
        case .cooking: return "fork.knife"
        case .sports: return "sportscourt"
        case .history: return "book.closed"
        case .science: return "atom"
        case .arts: return "paintpalette"
        case .slang: return "quote.bubble"
        case .academic: return "graduationcap"
        case .colloquial: return "waveform"
        case .finance: return "dollarsign.circle"
        case .philosophy: return "brain.head.profile"
        case .literature: return "book"
        case .medical: return "stethoscope"
        case .technology: return "laptopcomputer"
        }
    }
}
struct UserInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var hSize
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var birthDate: Date = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
    @State private var emailForUpdates: String = ""
    @State private var selectedCategories: Set<WordCategory> = []
    
    @State private var isSaving = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @State private var shouldNavigateToContents = false
    
    private let primaryBlue = Color(red: 0.1, green: 0.3, blue: 0.8)
    private let lightBlue = Color(red: 0.9, green: 0.95, blue: 1.0)
    private let darkBlue = Color(red: 0.05, green: 0.15, blue: 0.4)
    
    private var isSpaciousLayout: Bool {
        hSize == .regular
    }
    
    private var maxContentWidth: CGFloat? {
        isSpaciousLayout ? 700 : nil
    }
    
    private var categoryGridColumns: [GridItem] {
        isSpaciousLayout ? Array(repeating: GridItem(.flexible(), spacing: 16), count: 3) : Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)
    }
    
    private var age: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 25
    }
    
    private var dateRange: ClosedRange<Date> {
        let minDate = Calendar.current.date(byAdding: .year, value: -100, to: Date()) ?? Date()
        let maxDate = Calendar.current.date(byAdding: .year, value: -13, to: Date()) ?? Date()
        return minDate...maxDate
    }

    var body: some View {
        ZStack {
            backgroundGradient.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: isSpaciousLayout ? 40 : 32) {
                    headerSection
                    profileSection
                    preferencesSection
                    saveButton
                }
                .padding(.horizontal, isSpaciousLayout ? 50 : 24)
                .padding(.vertical, isSpaciousLayout ? 40 : 20)
                .frame(maxWidth: maxContentWidth)
            }
            
            if isSaving {
                LoadingOverlay(primaryBlue: primaryBlue)
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert("Status", isPresented: $showAlert) {
            Button("OK", role: .cancel) {
                hasCompletedOnboarding = true
                shouldNavigateToContents = true
            }
        } message: {
            Text(alertMessage)
        }
        .background(
            NavigationLink(
                destination: ContentsPage(), isActive: $shouldNavigateToContents,
                label: { EmptyView() }
            )
            .hidden()
           
        )
        .onChange(of: shouldNavigateToContents) { newValue in
            if newValue == true {
                DispatchQueue.main.async {
                    shouldNavigateToContents = false
                }
            }
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                colorScheme == .dark ? darkBlue : lightBlue,
                colorScheme == .dark ? Color.black : Color.white
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var headerSection: some View {
        VStack(spacing: isSpaciousLayout ? 16 : 12) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: isSpaciousLayout ? 80 : 60))
                .foregroundColor(primaryBlue)
                .symbolRenderingMode(.hierarchical)
            
            VStack(spacing: 8) {
                Text("Complete Your Profile")
                    .font(.system(size: isSpaciousLayout ? 36 : 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Help us personalize your word learning experience")
                    .font(isSpaciousLayout ? .title3 : .body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, isSpaciousLayout ? 40 : 20)
    }
    
    private var profileSection: some View {
        VStack(alignment: .leading, spacing: isSpaciousLayout ? 25 : 20) {
            SectionHeader(title: "Personal Information", icon: "person.text.rectangle")
            
            VStack(spacing: isSpaciousLayout ? 20 : 16) {
                HStack(spacing: isSpaciousLayout ? 20 : 12) {
                    CustomTextField(
                        title: "First Name",
                        text: $firstName,
                        systemImage: "person",
                        isRequired: true
                    )
                    
                    CustomTextField(
                        title: "Last Name",
                        text: $lastName,
                        systemImage: "person",
                        isRequired: true
                    )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.secondary)
                        Text("Date of Birth")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("Age: \(age)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(primaryBlue)
                    }
                    
                    DatePicker(
                        "Select your birth date",
                        selection: $birthDate,
                        in: dateRange,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    )
                }
                
                CustomTextField(
                    title: "Email for Updates (Optional)",
                    text: $emailForUpdates,
                    systemImage: "envelope",
                    keyboardType: .emailAddress
                )
            }
        }
        .padding(isSpaciousLayout ? 30 : 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
    
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: isSpaciousLayout ? 25 : 20) {
            SectionHeader(title: "Word Preferences", icon: "text.bubble")
            
            Text("Select categories that interest you to receive personalized word suggestions")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)
            
            LazyVGrid(columns: categoryGridColumns, spacing: isSpaciousLayout ? 16 : 12) {
                ForEach(WordCategory.allCases) { category in
                    CategoryCard(
                        category: category,
                        isSelected: selectedCategories.contains(category),
                        primaryColor: primaryBlue
                    ) {
                        toggleCategory(category)
                    }
                }
            }
        }
        .padding(isSpaciousLayout ? 30 : 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
    
    private var saveButton: some View {
        Button(action: saveUserData) {
            HStack {
                if isSaving {
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Save Profile")
                }
            }
            .font(.system(size: isSpaciousLayout ? 20 : 18, weight: .semibold))
            .foregroundColor(.white)
            .frame(height: isSpaciousLayout ? 64 : 56)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(primaryBlue)
                    .shadow(color: primaryBlue.opacity(0.3), radius: 8, y: 4)
            )
        }
        .disabled(!isFormValid || isSaving)
        .opacity(isFormValid ? 1.0 : 0.6)
        .padding(.bottom, isSpaciousLayout ? 40 : 20)
    }
    
    private var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty &&
        age >= 13 && age <= 100
    }
    
    private func toggleCategory(_ category: WordCategory) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if selectedCategories.contains(category) {
                selectedCategories.remove(category)
            } else {
                selectedCategories.insert(category)
            }
        }
    }
    
    private func saveUserData() {
        isSaving = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isSaving = false
            self.alertMessage = "Profile updated successfully! Welcome to Lexicology."
            self.showAlert = true
        }
    }
}

struct LoadingOverlay: View {
    let primaryBlue: Color
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            
            VStack(spacing: 15) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: primaryBlue))
                    .scaleEffect(1.5)
                
                Text("Saving profile and customizing...")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(.systemBackground))
                    .shadow(radius: 10)
            )
        }
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    @Environment(\.horizontalSizeClass) var hSize
    
    private var isSpaciousLayout: Bool {
        hSize == .regular
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.system(size: isSpaciousLayout ? 20 : 18, weight: .medium))
            Text(title)
                .font(.system(size: isSpaciousLayout ? 20 : 18, weight: .semibold))
                .foregroundColor(.primary)
            Spacer()
        }
    }
}

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let systemImage: String
    var isRequired: Bool = false
    var keyboardType: UIKeyboardType = .default
    @Environment(\.horizontalSizeClass) var hSize
    
    private var isSpaciousLayout: Bool {
        hSize == .regular
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: systemImage)
                    .foregroundColor(.secondary)
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                if isRequired {
                    Text("*")
                        .foregroundColor(.red)
                }
            }
            
            TextField(title, text: $text)
                .keyboardType(keyboardType)
                .autocapitalization(.none)
                .disableAutocorrection(keyboardType == .emailAddress)
                .padding(isSpaciousLayout ? 16 : 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
        }
    }
}

struct CategoryCard: View {
    let category: WordCategory
    let isSelected: Bool
    let primaryColor: Color
    let action: () -> Void
    @Environment(\.horizontalSizeClass) var hSize
    
    private var isSpaciousLayout: Bool {
        hSize == .regular
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: isSpaciousLayout ? 16 : 12) {
                Image(systemName: category.icon)
                    .font(.system(size: isSpaciousLayout ? 32 : 24))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(isSelected ? .white : primaryColor)
                
                Text(category.rawValue)
                    .font(.system(size: isSpaciousLayout ? 16 : 14, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundColor(isSelected ? .white : .primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(height: isSpaciousLayout ? 100 : 80)
            .frame(maxWidth: .infinity)
            .padding(.vertical, isSpaciousLayout ? 16 : 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? primaryColor : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? .blue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    NavigationView {
        UserInfoView()
    }
}
