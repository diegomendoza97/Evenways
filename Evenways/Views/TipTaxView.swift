import SwiftUI

struct TipTaxView: View {
    let restaurantName: String
    let people: [Person]
    let items: [Item]

    @State private var tipPercentage: Double = 18
    @State private var customTip = ""
    @State private var taxPercentage: Double = 0
    @State private var customTax = ""
    @State private var isEvenSplit = false
    @State private var selectedTipPreset: Int? = 1

    private let tipPresets: [Double] = [15, 18, 20]

    private var subtotal: Double {
        items.reduce(0) { $0 + $1.totalPrice }
    }

    private var tipAmount: Double {
        subtotal * (tipPercentage / 100)
    }

    private var taxAmount: Double {
        subtotal * (taxPercentage / 100)
    }

    private var total: Double {
        subtotal + tipAmount + taxAmount
    }

    private var multiplier: Double {
        guard subtotal > 0 else { return 1 }
        return total / subtotal
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Tip & Tax")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(AppTheme.textPrimary)
                            Text("Set tip and tax to calculate the final amounts.")
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.textSecondary)
                        }

                        // Tip Section
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader("Tip", icon: "heart.fill")

                            CardView {
                                VStack(spacing: 14) {
                                    HStack(spacing: 10) {
                                        ForEach(Array(tipPresets.enumerated()), id: \.offset) { index, preset in
                                            Button {
                                                selectedTipPreset = index
                                                tipPercentage = preset
                                                customTip = ""
                                            } label: {
                                                Text("\(Int(preset))%")
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                    .frame(maxWidth: .infinity)
                                                    .padding(.vertical, 12)
                                                    .background(
                                                        selectedTipPreset == index
                                                        ? AppTheme.primary
                                                        : AppTheme.inputBackground
                                                    )
                                                    .foregroundStyle(
                                                        selectedTipPreset == index
                                                        ? .white
                                                        : AppTheme.textPrimary
                                                    )
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .strokeBorder(
                                                                selectedTipPreset == index
                                                                ? AppTheme.primary
                                                                : AppTheme.border,
                                                                lineWidth: 1
                                                            )
                                                    )
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }

                                    HStack(spacing: 8) {
                                        Text("Custom")
                                            .font(.subheadline)
                                            .foregroundStyle(AppTheme.textSecondary)
                                        Spacer()
                                        TextField("0", text: $customTip)
                                            .keyboardType(.decimalPad)
                                            .multilineTextAlignment(.trailing)
                                            .frame(width: 60)
                                            .padding(8)
                                            .background(AppTheme.inputBackground)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            .foregroundStyle(AppTheme.textPrimary)
                                            .onChange(of: customTip) { _, newValue in
                                                if let value = Double(newValue) {
                                                    tipPercentage = value
                                                    selectedTipPreset = nil
                                                }
                                            }
                                        Text("%")
                                            .foregroundStyle(AppTheme.textSecondary)
                                    }
                                }
                            }
                        }

                        // Tax Section
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader("Tax", icon: "percent")

                            CardView {
                                HStack(spacing: 8) {
                                    Text("Tax rate")
                                        .font(.subheadline)
                                        .foregroundStyle(AppTheme.textSecondary)
                                    Spacer()
                                    TextField("0", text: $customTax)
                                        .keyboardType(.decimalPad)
                                        .multilineTextAlignment(.trailing)
                                        .frame(width: 60)
                                        .padding(8)
                                        .background(AppTheme.inputBackground)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .foregroundStyle(AppTheme.textPrimary)
                                        .onChange(of: customTax) { _, newValue in
                                            if let value = Double(newValue) {
                                                taxPercentage = value
                                            }
                                        }
                                    Text("%")
                                        .foregroundStyle(AppTheme.textSecondary)
                                }
                            }
                        }

                        // Even Split Toggle
                        CardView {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Even Split")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundStyle(AppTheme.textPrimary)
                                    Text(isEvenSplit
                                         ? "Total split evenly among all people."
                                         : "Each person pays based on their items.")
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.textSecondary)
                                }
                                Spacer()
                                Toggle("", isOn: $isEvenSplit)
                                    .tint(AppTheme.primary)
                                    .labelsHidden()
                            }
                        }

                        // Preview Section
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader("Preview", icon: "eye.fill", badge: "\(people.count) People")

                            VStack(spacing: 0) {
                                ForEach(Array(people.enumerated()), id: \.element.id) { index, person in
                                    HStack(spacing: 12) {
                                        PersonInitialAvatar(name: person.name, size: 36)

                                        Text(person.name)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundStyle(AppTheme.textPrimary)

                                        Spacer()

                                        Text(estimatedAmount(for: person), format: .currency(code: "USD"))
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundStyle(AppTheme.textPrimary)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)

                                    if index < people.count - 1 {
                                        Divider()
                                            .overlay(AppTheme.border)
                                            .padding(.horizontal, 16)
                                    }
                                }
                            }
                            .background(AppTheme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }

                        // Total
                        HStack {
                            Text("Total")
                                .font(.headline)
                                .foregroundStyle(AppTheme.textSecondary)
                            Spacer()
                            Text(total, format: .currency(code: "USD"))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(AppTheme.textPrimary)
                        }
                        .padding(16)
                        .background(AppTheme.cardBackgroundElevated)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(16)
                    .padding(.bottom, 80)
                }

                // Bottom Bar
                VStack(spacing: 12) {
                    Divider().overlay(AppTheme.border)
                    NavigationLink {
                        SummaryView(
                            restaurantName: restaurantName,
                            people: people,
                            items: items,
                            tipPercentage: tipPercentage,
                            taxPercentage: taxPercentage,
                            isEvenSplit: isEvenSplit
                        )
                    } label: {
                        HStack(spacing: 6) {
                            Text("Review Split")
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.right")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.primary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
                .background(AppTheme.background)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Evenways")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.primary)
            }
        }
        .toolbarBackground(AppTheme.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private func estimatedAmount(for person: Person) -> Double {
        if isEvenSplit {
            guard !people.isEmpty else { return 0 }
            return total / Double(people.count)
        }

        let personSubtotal = items
            .filter { $0.assignedPeople.contains(where: { $0.id == person.id }) }
            .reduce(0.0) { $0 + $1.pricePerPerson }

        return personSubtotal * multiplier
    }
}

#Preview {
    let people = [Person(name: "Alice"), Person(name: "Bob")]
    var burger = Item(name: "Burger", price: 15.99)
    burger.assignedPeople = [people[0]]
    var fries = Item(name: "Fries", price: 5.49)
    fries.assignedPeople = [people[1]]

    return NavigationStack {
        TipTaxView(
            restaurantName: "Test",
            people: people,
            items: [burger, fries]
        )
    }
    .preferredColorScheme(.dark)
}
