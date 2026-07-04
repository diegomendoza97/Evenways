import SwiftUI
import SwiftData

struct NewSplitSetupView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var restaurantName = ""
    @State private var personName = ""
    @State private var people: [Person] = []

    var isValid: Bool {
        !restaurantName.trimmingCharacters(in: .whitespaces).isEmpty && people.count >= 2
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Restaurant Section
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader("Restaurant", icon: "fork.knife")

                        CardView {
                            ThemedTextField(
                                label: "Restaurant Name",
                                placeholder: "Where did you go?",
                                text: $restaurantName,
                                autocapitalization: .words
                            )
                        }
                    }

                    // People Section
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader("People", icon: "person.2.fill")

                        CardView {
                            VStack(spacing: 12) {
                                ThemedTextField(
                                    label: "Person Name",
                                    placeholder: "Add a friend",
                                    text: $personName,
                                    autocapitalization: .words
                                )

                                Button(action: addPerson) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "plus")
                                        Text("Add")
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        personName.trimmingCharacters(in: .whitespaces).isEmpty
                                        ? AppTheme.primary.opacity(0.3)
                                        : AppTheme.primary
                                    )
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                .disabled(personName.trimmingCharacters(in: .whitespaces).isEmpty)
                            }
                        }

                        if people.count < 2 {
                            HStack(spacing: 8) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundStyle(AppTheme.primary)
                                Text("Add at least 2 people to continue. You can split the bill equally or customize each share later.")
                                    .font(.footnote)
                                    .foregroundStyle(AppTheme.textSecondary)
                            }
                            .padding(14)
                            .background(AppTheme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    // Splitters List
                    if !people.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("SPLITTERS (\(people.count))")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(AppTheme.neutral)
                                .tracking(0.5)

                            ForEach(people) { person in
                                HStack(spacing: 12) {
                                    PersonInitialAvatar(name: person.name, size: 40)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(person.name)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundStyle(AppTheme.textPrimary)
                                        Text("Splitter")
                                            .font(.caption)
                                            .foregroundStyle(AppTheme.textSecondary)
                                    }

                                    Spacer()

                                    Button {
                                        withAnimation {
                                            people.removeAll { $0.id == person.id }
                                        }
                                    } label: {
                                        Image(systemName: "xmark")
                                            .font(.caption)
                                            .foregroundStyle(AppTheme.neutral)
                                            .padding(8)
                                    }
                                }
                                .padding(12)
                                .background(AppTheme.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                        }
                    }

                    // Next Button
                    if isValid {
                        PrimaryNavigationLink("Next Step", icon: nil) {
                            AddItemsView(
                                restaurantName: restaurantName,
                                people: people
                            )
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("New Split")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.textPrimary)
            }
        }
        .toolbarBackground(AppTheme.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private func addPerson() {
        let trimmed = personName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        withAnimation {
            people.append(Person(name: trimmed))
        }
        personName = ""
    }
}

#Preview {
    NavigationStack {
        NewSplitSetupView()
    }
    .modelContainer(for: Split.self, inMemory: true)
    .preferredColorScheme(.dark)
}
