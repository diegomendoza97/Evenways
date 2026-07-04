import SwiftUI

struct AddItemsView: View {
    let restaurantName: String
    let people: [Person]

    @State private var items: [Item] = []
    @State private var itemName = ""
    @State private var itemPrice = ""

    private var subtotal: Double {
        items.reduce(0) { $0 + $1.totalPrice }
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Add Items")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(AppTheme.textPrimary)
                            Text("Break down the receipt by adding each item manually.")
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.textSecondary)
                        }

                        // Input Card
                        CardView {
                            VStack(spacing: 12) {
                                ThemedTextField(
                                    label: "Item Name",
                                    placeholder: "e.g. Nacho Tray",
                                    text: $itemName,
                                    autocapitalization: .words
                                )

                                ThemedTextField(
                                    label: "Price",
                                    placeholder: "$ 0.00",
                                    text: $itemPrice,
                                    keyboardType: .decimalPad
                                )

                                Button(action: addItem) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "plus")
                                        Text("Add Item")
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(canAddItem ? AppTheme.primary : AppTheme.primary.opacity(0.3))
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                .disabled(!canAddItem)
                            }
                        }

                        // Items List
                        if !items.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                SectionHeader("Items", icon: "list.bullet", badge: "\(items.count) Added")

                                ForEach($items) { $item in
                                    HStack(spacing: 12) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(AppTheme.primary.opacity(0.15))
                                                .frame(width: 40, height: 40)
                                            Image(systemName: "fork.knife")
                                                .font(.subheadline)
                                                .foregroundStyle(AppTheme.primary)
                                        }

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(item.name)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundStyle(AppTheme.textPrimary)
                                            if item.quantity > 1 {
                                                Text("\(item.quantity)x @ \(item.price, format: .currency(code: "USD")) each")
                                                    .font(.caption)
                                                    .foregroundStyle(AppTheme.textSecondary)
                                            } else {
                                                Text("Individual Item")
                                                    .font(.caption)
                                                    .foregroundStyle(AppTheme.textSecondary)
                                            }
                                        }

                                        Spacer()

                                        // Quantity stepper
                                        HStack(spacing: 4) {
                                            Button {
                                                if item.quantity > 1 {
                                                    item.quantity -= 1
                                                }
                                            } label: {
                                                Image(systemName: "minus")
                                                    .font(.caption2.weight(.bold))
                                                    .frame(width: 28, height: 28)
                                                    .background(AppTheme.inputBackground)
                                                    .foregroundStyle(item.quantity > 1 ? AppTheme.textPrimary : AppTheme.neutral)
                                                    .clipShape(Circle())
                                            }
                                            .disabled(item.quantity <= 1)

                                            Text("\(item.quantity)")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(AppTheme.textPrimary)
                                                .frame(width: 24)

                                            Button {
                                                item.quantity += 1
                                            } label: {
                                                Image(systemName: "plus")
                                                    .font(.caption2.weight(.bold))
                                                    .frame(width: 28, height: 28)
                                                    .background(AppTheme.primary.opacity(0.2))
                                                    .foregroundStyle(AppTheme.primary)
                                                    .clipShape(Circle())
                                            }
                                        }

                                        Text(item.totalPrice, format: .currency(code: "USD"))
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundStyle(AppTheme.textPrimary)
                                            .frame(width: 70, alignment: .trailing)

                                        Button {
                                            withAnimation {
                                                items.removeAll { $0.id == item.id }
                                            }
                                        } label: {
                                            Image(systemName: "trash")
                                                .font(.subheadline)
                                                .foregroundStyle(AppTheme.neutral)
                                                .padding(6)
                                        }
                                    }
                                    .padding(12)
                                    .background(AppTheme.cardBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                }
                            }
                        }

                        if items.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "receipt")
                                    .font(.system(size: 36))
                                    .foregroundStyle(AppTheme.neutral.opacity(0.5))
                                Text("Add more items from your receipt to\nfinish splitting.")
                                    .font(.footnote)
                                    .foregroundStyle(AppTheme.textSecondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 32)
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 100)
                }

                // Bottom Bar
                VStack(spacing: 12) {
                    Divider()
                        .overlay(AppTheme.border)

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("SUBTOTAL")
                                .font(.caption)
                                .foregroundStyle(AppTheme.neutral)
                                .tracking(0.5)
                            Text(subtotal, format: .currency(code: "USD"))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(AppTheme.textPrimary)
                        }

                        Spacer()

                        if !items.isEmpty {
                            NavigationLink {
                                AssignItemsView(
                                    restaurantName: restaurantName,
                                    people: people,
                                    items: items
                                )
                            } label: {
                                HStack(spacing: 6) {
                                    Text("Next Step")
                                        .fontWeight(.semibold)
                                    Image(systemName: "arrow.right")
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(AppTheme.primary)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                            }
                        }
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

    private var canAddItem: Bool {
        !itemName.trimmingCharacters(in: .whitespaces).isEmpty
        && (itemPrice.localeAwareDouble ?? 0) > 0
    }

    private func addItem() {
        let trimmedName = itemName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty, let price = itemPrice.localeAwareDouble, price > 0 else { return }
        withAnimation {
            items.append(Item(name: trimmedName, price: price))
        }
        itemName = ""
        itemPrice = ""
    }
}

#Preview {
    NavigationStack {
        AddItemsView(
            restaurantName: "Test Restaurant",
            people: [Person(name: "Alice"), Person(name: "Bob")]
        )
    }
    .preferredColorScheme(.dark)
}
