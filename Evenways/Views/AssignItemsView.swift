import SwiftUI

struct AssignItemsView: View {
    let restaurantName: String
    let people: [Person]
    @State var items: [Item]

    private var allAssigned: Bool {
        !items.isEmpty && items.allSatisfy { !$0.assignedPeople.isEmpty }
    }

    private var unassignedCount: Int {
        items.filter { $0.assignedPeople.isEmpty }.count
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Assign Items")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(AppTheme.textPrimary)
                            Text("Tap the people who shared each item.")
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.textSecondary)
                        }

                        // Items
                        ForEach($items) { $item in
                            VStack(alignment: .leading, spacing: 12) {
                                // Unassigned indicator
                                if item.assignedPeople.isEmpty {
                                    HStack(spacing: 6) {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .font(.caption2)
                                        Text("Unassigned")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundStyle(AppTheme.tertiary)
                                }

                                HStack {
                                    Text(item.name)
                                        .font(.headline)
                                        .foregroundStyle(AppTheme.textPrimary)
                                    Spacer()
                                    Text(item.totalPrice, format: .currency(code: "USD"))
                                        .font(.headline)
                                        .foregroundStyle(AppTheme.textSecondary)
                                }

                                if item.assignedPeople.count > 1 {
                                    Text("\(item.pricePerPerson, format: .currency(code: "USD")) per person")
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.secondary)
                                }

                                // People chips
                                FlowLayout(spacing: 8) {
                                    ForEach(people) { person in
                                        let isSelected = item.assignedPeople.contains(where: { $0.id == person.id })
                                        Button {
                                            togglePerson(person, for: &item)
                                        } label: {
                                            HStack(spacing: 6) {
                                                PersonInitialAvatar(name: person.name, size: 24)
                                                Text(person.name)
                                                    .font(.subheadline)
                                                    .fontWeight(.medium)
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(isSelected ? AppTheme.primary : AppTheme.inputBackground)
                                            .foregroundStyle(isSelected ? .white : AppTheme.textPrimary)
                                            .clipShape(Capsule())
                                            .overlay(
                                                Capsule()
                                                    .strokeBorder(
                                                        isSelected ? AppTheme.primary : AppTheme.border,
                                                        lineWidth: 1
                                                    )
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .padding(16)
                            .background(AppTheme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }

                        if unassignedCount > 0 {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(AppTheme.tertiary)
                                Text("\(unassignedCount) item\(unassignedCount == 1 ? "" : "s") still unassigned")
                                    .font(.footnote)
                                    .foregroundStyle(AppTheme.textSecondary)
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppTheme.tertiary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 80)
                }

                // Bottom Bar
                if allAssigned {
                    VStack(spacing: 12) {
                        Divider().overlay(AppTheme.border)
                        NavigationLink {
                            TipTaxView(
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

    private func togglePerson(_ person: Person, for item: inout Item) {
        if let index = item.assignedPeople.firstIndex(where: { $0.id == person.id }) {
            item.assignedPeople.remove(at: index)
        } else {
            item.assignedPeople.append(person)
        }
    }
}

/// A simple flow layout that wraps children to the next line
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(in: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(in: ProposedViewSize(width: bounds.width, height: bounds.height), subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: ProposedViewSize(subviews[index].sizeThatFits(.unspecified))
            )
        }
    }

    private func layout(in proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x)
        }

        return (CGSize(width: maxX, height: y + rowHeight), positions)
    }
}

#Preview {
    let people = [Person(name: "Alice"), Person(name: "Bob"), Person(name: "Charlie")]
    NavigationStack {
        AssignItemsView(
            restaurantName: "Test",
            people: people,
            items: [
                Item(name: "Burger", price: 15.99),
                Item(name: "Fries", price: 5.49),
                Item(name: "Salad", price: 12.00)
            ]
        )
    }
    .preferredColorScheme(.dark)
}
