import SwiftUI
import SwiftData

struct SummaryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // When created from the flow (new split)
    var restaurantName: String?
    var people: [Person]?
    var items: [Item]?
    var tipPercentage: Double?
    var taxPercentage: Double?
    var isEvenSplit: Bool?

    // When viewing a saved split
    var split: Split?

    @State private var hasSaved = false

    // Resolved values
    private var resolvedRestaurantName: String {
        split?.restaurantName ?? restaurantName ?? ""
    }

    private var resolvedPeople: [Person] {
        split?.people ?? people ?? []
    }

    private var resolvedItems: [Item] {
        split?.items ?? items ?? []
    }

    private var resolvedTipPercentage: Double {
        split?.tipPercentage ?? tipPercentage ?? 18
    }

    private var resolvedTaxPercentage: Double {
        split?.taxPercentage ?? taxPercentage ?? 0
    }

    private var resolvedIsEvenSplit: Bool {
        split?.isEvenSplit ?? isEvenSplit ?? false
    }

    private var resolvedDate: Date {
        split?.date ?? .now
    }

    private var subtotal: Double {
        resolvedItems.reduce(0) { $0 + $1.totalPrice }
    }

    private var tipAmount: Double {
        subtotal * (resolvedTipPercentage / 100)
    }

    private var taxAmount: Double {
        subtotal * (resolvedTaxPercentage / 100)
    }

    private var total: Double {
        subtotal + tipAmount + taxAmount
    }

    private var multiplier: Double {
        guard subtotal > 0 else { return 1 }
        return total / subtotal
    }

    private func amountOwed(by person: Person) -> Double {
        if resolvedIsEvenSplit {
            guard !resolvedPeople.isEmpty else { return 0 }
            return total / Double(resolvedPeople.count)
        }

        let personSubtotal = resolvedItems
            .reduce(0.0) { $0 + $1.portion(for: person) }

        return personSubtotal * multiplier
    }

    private var shareText: String {
        var text = "\(resolvedRestaurantName) — Bill Split\n\n"
        for person in resolvedPeople {
            let amount = amountOwed(by: person)
            text += "\(person.name): \(amount.formatted(.currency(code: "USD")))\n"
        }
        text += "\nSubtotal: \(subtotal.formatted(.currency(code: "USD")))"
        text += "\nTip (\(Int(resolvedTipPercentage))%): \(tipAmount.formatted(.currency(code: "USD")))"
        text += "\nTax (\(Int(resolvedTaxPercentage))%): \(taxAmount.formatted(.currency(code: "USD")))"
        text += "\nTotal: \(total.formatted(.currency(code: "USD")))"
        return text
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(AppTheme.primary.opacity(0.15))
                            .frame(width: 64, height: 64)
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(AppTheme.primary)
                    }

                    VStack(spacing: 4) {
                        Text("FINAL SUMMARY")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(AppTheme.neutral)
                            .tracking(1)
                        Text("Split Review")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(AppTheme.textPrimary)
                        Text("\(resolvedRestaurantName) · \(resolvedDate.formatted(.dateTime.month(.abbreviated).day()))")
                            .font(.subheadline)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(AppTheme.cardBackgroundElevated)
                            .foregroundStyle(AppTheme.textSecondary)
                            .clipShape(Capsule())
                    }

                    // Total Bill Amount
                    VStack(spacing: 4) {
                        Text("TOTAL BILL AMOUNT")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(AppTheme.neutral)
                            .tracking(0.5)
                        Text(total, format: .currency(code: "USD"))
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(AppTheme.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.primary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    // Who Owes What
                    VStack(alignment: .leading, spacing: 14) {
                        SectionHeader("Who owes what", icon: "person.2.fill", badge: "\(resolvedPeople.count) People")

                        ForEach(resolvedPeople) { person in
                            HStack(spacing: 12) {
                                PersonInitialAvatar(name: person.name, size: 44)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(person.name)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(AppTheme.textPrimary)

                                    let personItems = resolvedItems.filter {
                                        $0.assignedPeople.contains(where: { $0.id == person.id })
                                    }
                                    if !personItems.isEmpty && !resolvedIsEvenSplit {
                                        Text(personItems.map(\.name).joined(separator: " · "))
                                            .font(.caption)
                                            .foregroundStyle(AppTheme.textSecondary)
                                            .lineLimit(1)
                                    } else if resolvedIsEvenSplit {
                                        Text("Even split")
                                            .font(.caption)
                                            .foregroundStyle(AppTheme.textSecondary)
                                    }
                                }

                                Spacer()

                                Text(amountOwed(by: person), format: .currency(code: "USD"))
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(AppTheme.textPrimary)
                            }
                            .padding(14)
                            .background(AppTheme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }

                    // Bill Breakdown
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader("Split Insights", icon: "sparkles")

                        VStack(spacing: 0) {
                            breakdownRow(label: "Subtotal", value: subtotal)
                            Divider().overlay(AppTheme.border).padding(.horizontal, 16)
                            breakdownRow(label: "Tip (\(Int(resolvedTipPercentage))%)", value: tipAmount)
                            Divider().overlay(AppTheme.border).padding(.horizontal, 16)
                            breakdownRow(label: "Tax (\(Int(resolvedTaxPercentage))%)", value: taxAmount)
                            Divider().overlay(AppTheme.border).padding(.horizontal, 16)
                            HStack {
                                Text("Total")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(AppTheme.textPrimary)
                                Spacer()
                                Text(total, format: .currency(code: "USD"))
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(AppTheme.primary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        .background(AppTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    // Items Detail
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader("Items", icon: "list.bullet", badge: "\(resolvedItems.count) Items")

                        VStack(spacing: 0) {
                            ForEach(Array(resolvedItems.enumerated()), id: \.element.id) { index, item in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(item.name)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundStyle(AppTheme.textPrimary)
                                        Spacer()
                                        Text(item.totalPrice, format: .currency(code: "USD"))
                                            .font(.subheadline)
                                            .foregroundStyle(AppTheme.textSecondary)
                                    }
                                    if !item.assignedPeople.isEmpty {
                                        Text(item.assignedPeople.map { person in
                                            let units = item.units(for: person)
                                            return units > 1 ? "\(person.name) ×\(units)" : person.name
                                        }.joined(separator: ", "))
                                            .font(.caption)
                                            .foregroundStyle(AppTheme.neutral)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)

                                if index < resolvedItems.count - 1 {
                                    Divider().overlay(AppTheme.border).padding(.horizontal, 16)
                                }
                            }
                        }
                        .background(AppTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    // Share / Save Actions
                    VStack(spacing: 10) {
                        ShareLink(item: shareText) {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share as Text")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppTheme.cardBackground)
                            .foregroundStyle(AppTheme.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(AppTheme.primary.opacity(0.3), lineWidth: 1)
                            )
                        }

                        Button(action: shareAsImage) {
                            HStack(spacing: 8) {
                                Image(systemName: "photo")
                                Text("Share as Image")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppTheme.cardBackground)
                            .foregroundStyle(AppTheme.secondary)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(AppTheme.secondary.opacity(0.3), lineWidth: 1)
                            )
                        }

                        if split == nil && !hasSaved {
                            PrimaryButton("Save Split", icon: "square.and.arrow.down") {
                                saveSplit()
                            }
                            .padding(.top, 4)
                        }
                    }
                }
                .padding(16)
                .padding(.bottom, 16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(hasSaved)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Evenways")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.primary)
            }
            if hasSaved {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        navigateToRoot()
                    }
                    .foregroundStyle(AppTheme.primary)
                }
            }
        }
        .toolbarBackground(AppTheme.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private func breakdownRow(label: String, value: Double) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
            Spacer()
            Text(value, format: .currency(code: "USD"))
                .font(.subheadline)
                .foregroundStyle(AppTheme.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func saveSplit() {
        guard let people, let items else { return }

        let newSplit = Split(
            restaurantName: restaurantName ?? "",
            tipPercentage: tipPercentage ?? 18,
            taxPercentage: taxPercentage ?? 0,
            isEvenSplit: isEvenSplit ?? false
        )

        modelContext.insert(newSplit)

        for person in people {
            newSplit.people.append(person)
        }
        for item in items {
            newSplit.items.append(item)
        }

        hasSaved = true
    }

    private func navigateToRoot() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootVC = window.rootViewController else { return }

        if let navController = findNavigationController(in: rootVC) {
            navController.popToRootViewController(animated: true)
        }
    }

    private func findNavigationController(in viewController: UIViewController) -> UINavigationController? {
        if let nav = viewController as? UINavigationController {
            return nav
        }
        for child in viewController.children {
            if let nav = findNavigationController(in: child) {
                return nav
            }
        }
        return nil
    }

    @MainActor
    private func shareAsImage() {
        let renderer = ImageRenderer(content: summaryCardView)
        renderer.scale = UIScreen.main.scale

        guard let image = renderer.uiImage else { return }

        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootVC = window.rootViewController else { return }

        rootVC.present(activityVC, animated: true)
    }

    @MainActor
    private var summaryCardView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(resolvedRestaurantName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                Spacer()
                Text("Evenways")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(AppTheme.primary)
            }

            Rectangle()
                .fill(AppTheme.border)
                .frame(height: 1)

            ForEach(resolvedPeople) { person in
                HStack {
                    Text(person.name)
                        .foregroundStyle(.white)
                    Spacer()
                    Text(amountOwed(by: person), format: .currency(code: "USD"))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
            }

            Rectangle()
                .fill(AppTheme.border)
                .frame(height: 1)

            Group {
                HStack {
                    Text("Subtotal")
                    Spacer()
                    Text(subtotal, format: .currency(code: "USD"))
                }
                HStack {
                    Text("Tip (\(Int(resolvedTipPercentage))%)")
                    Spacer()
                    Text(tipAmount, format: .currency(code: "USD"))
                }
                HStack {
                    Text("Tax (\(Int(resolvedTaxPercentage))%)")
                    Spacer()
                    Text(taxAmount, format: .currency(code: "USD"))
                }
            }
            .font(.footnote)
            .foregroundStyle(AppTheme.textSecondary)

            Rectangle()
                .fill(AppTheme.border)
                .frame(height: 1)

            HStack {
                Text("Total")
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                Spacer()
                Text(total, format: .currency(code: "USD"))
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.primary)
            }
        }
        .padding(24)
        .frame(width: 350)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview("New Split") {
    let people = [Person(name: "Alice"), Person(name: "Bob")]
    var burger = Item(name: "Burger", price: 15.99)
    burger.assignedPeople = [people[0]]
    var fries = Item(name: "Fries", price: 5.49)
    fries.assignedPeople = [people[1]]

    return NavigationStack {
        SummaryView(
            restaurantName: "Joe's Diner",
            people: people,
            items: [burger, fries],
            tipPercentage: 18,
            taxPercentage: 8.875,
            isEvenSplit: false
        )
    }
    .modelContainer(for: Split.self, inMemory: true)
    .preferredColorScheme(.dark)
}
