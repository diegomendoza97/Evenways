import Foundation
import SwiftData

@Model
final class Split {
    var id: UUID
    var restaurantName: String
    var date: Date
    var tipPercentage: Double
    var taxPercentage: Double
    var isEvenSplit: Bool

    @Relationship(deleteRule: .cascade, inverse: \Person.split)
    var people: [Person]

    @Relationship(deleteRule: .cascade, inverse: \Item.split)
    var items: [Item]

    init(
        restaurantName: String = "",
        date: Date = .now,
        tipPercentage: Double = 18,
        taxPercentage: Double = 0,
        isEvenSplit: Bool = false,
        people: [Person] = [],
        items: [Item] = []
    ) {
        self.id = UUID()
        self.restaurantName = restaurantName
        self.date = date
        self.tipPercentage = tipPercentage
        self.taxPercentage = taxPercentage
        self.isEvenSplit = isEvenSplit
        self.people = people
        self.items = items
    }

    var subtotal: Double {
        items.reduce(0) { $0 + $1.totalPrice }
    }

    var tipAmount: Double {
        subtotal * (tipPercentage / 100)
    }

    var taxAmount: Double {
        subtotal * (taxPercentage / 100)
    }

    var total: Double {
        subtotal + tipAmount + taxAmount
    }

    /// Multiplier to apply tip + tax proportionally
    var multiplier: Double {
        guard subtotal > 0 else { return 1 }
        return total / subtotal
    }

    var unassignedItems: [Item] {
        items.filter { $0.assignedPeople.isEmpty }
    }

    var isFullyAssigned: Bool {
        unassignedItems.isEmpty && !items.isEmpty
    }

    func amountOwed(by person: Person) -> Double {
        if isEvenSplit {
            guard !people.isEmpty else { return 0 }
            return total / Double(people.count)
        }

        let personSubtotal = items
            .reduce(0.0) { $0 + $1.portion(for: person) }

        return personSubtotal * multiplier
    }
}

@Model
final class Person {
    var id: UUID
    var name: String
    var split: Split?

    init(name: String) {
        self.id = UUID()
        self.name = name
    }
}

@Model
final class Item {
    var id: UUID
    var name: String
    var price: Double
    var quantity: Int
    var split: Split?

    /// Per-person unit counts, keyed by `Person.id.uuidString`. A person absent
    /// from this map (but present in `assignedPeople`) counts as 1 unit, so the
    /// default behavior is an even split.
    var unitCounts: [String: Int] = [:]

    @Relationship
    var assignedPeople: [Person]

    init(name: String, price: Double, quantity: Int = 1) {
        self.id = UUID()
        self.name = name
        self.price = price
        self.quantity = quantity
        self.assignedPeople = []
    }

    /// Total price accounting for quantity
    var totalPrice: Double {
        price * Double(quantity)
    }

    var pricePerPerson: Double {
        guard !assignedPeople.isEmpty else { return totalPrice }
        return totalPrice / Double(assignedPeople.count)
    }

    /// Units attributed to a person: 0 if unassigned, otherwise their stored
    /// count (defaulting to 1). Never below 1 for an assigned person.
    func units(for person: Person) -> Int {
        guard assignedPeople.contains(where: { $0.id == person.id }) else { return 0 }
        return max(unitCounts[person.id.uuidString] ?? 1, 1)
    }

    /// Total units across everyone assigned to this item.
    var totalUnits: Int {
        assignedPeople.reduce(0) { $0 + units(for: $1) }
    }

    /// The share of this item's cost owed by a person, proportional to their
    /// units. Equals `pricePerPerson` when all assignees have equal counts.
    func portion(for person: Person) -> Double {
        let total = totalUnits
        guard total > 0 else { return 0 }
        return totalPrice * Double(units(for: person)) / Double(total)
    }
}
