//
//  EvenwaysTests.swift
//  EvenwaysTests
//
//  Created by Diego Mendoza on 5/2/26.
//

import XCTest
@testable import Evenways

final class EvenwaysTests: XCTestCase {

    // MARK: - Helpers

    /// Builds a standard scenario used across several tests:
    /// - Alice + Bob
    /// - Burger ($15) assigned to Alice only
    /// - Fries ($5) shared by Alice + Bob
    /// Subtotal = $20.
    ///
    /// The models are built purely in memory (not inserted into a
    /// `ModelContext`) so each test is fully isolated and exercises only the
    /// pure split-math logic.
    private func makeStandardSplit(tip: Double, tax: Double, evenSplit: Bool) -> (split: Split, alice: Person, bob: Person) {
        let alice = Person(name: "Alice")
        let bob = Person(name: "Bob")

        let burger = Item(name: "Burger", price: 15)
        burger.assignedPeople = [alice]

        let fries = Item(name: "Fries", price: 5)
        fries.assignedPeople = [alice, bob]

        let split = Split(
            restaurantName: "Test Diner",
            tipPercentage: tip,
            taxPercentage: tax,
            isEvenSplit: evenSplit,
            people: [alice, bob],
            items: [burger, fries]
        )
        return (split, alice, bob)
    }

    // MARK: - Item math

    func testItemTotalPriceUsesQuantity() {
        let item = Item(name: "Beers", price: 6, quantity: 3)
        XCTAssertEqual(item.totalPrice, 18, accuracy: 0.0001)
    }

    func testPricePerPersonSplitsAmongAssignees() {
        let a = Person(name: "A")
        let b = Person(name: "B")
        let item = Item(name: "Nachos", price: 12)
        item.assignedPeople = [a, b]
        XCTAssertEqual(item.pricePerPerson, 6, accuracy: 0.0001)
    }

    func testPricePerPersonWithNoAssigneesReturnsTotal() {
        let item = Item(name: "Mystery", price: 9)
        XCTAssertEqual(item.pricePerPerson, 9, accuracy: 0.0001)
    }

    // MARK: - Split totals

    func testSubtotalSumsItemTotals() {
        let (split, _, _) = makeStandardSplit(tip: 0, tax: 0, evenSplit: false)
        XCTAssertEqual(split.subtotal, 20, accuracy: 0.0001)
    }

    func testTipTaxAndTotal() {
        let (split, _, _) = makeStandardSplit(tip: 20, tax: 10, evenSplit: false)
        XCTAssertEqual(split.tipAmount, 4, accuracy: 0.0001)
        XCTAssertEqual(split.taxAmount, 2, accuracy: 0.0001)
        XCTAssertEqual(split.total, 26, accuracy: 0.0001)
    }

    func testMultiplierWithZeroSubtotalIsOne() {
        let split = Split(tipPercentage: 20, taxPercentage: 10)
        XCTAssertEqual(split.multiplier, 1, accuracy: 0.0001)
    }

    // MARK: - Amount owed (item-based)

    func testAmountOwedDistributesTipAndTaxProportionally() {
        let (split, alice, bob) = makeStandardSplit(tip: 20, tax: 10, evenSplit: false)

        // Alice: burger 15 + half of fries 2.5 = 17.5, * multiplier 1.3 = 22.75
        XCTAssertEqual(split.amountOwed(by: alice), 22.75, accuracy: 0.0001)
        // Bob: half of fries 2.5, * 1.3 = 3.25
        XCTAssertEqual(split.amountOwed(by: bob), 3.25, accuracy: 0.0001)
    }

    func testAmountOwedSumsToTotal() {
        let (split, alice, bob) = makeStandardSplit(tip: 18, tax: 8.875, evenSplit: false)
        let sum = split.amountOwed(by: alice) + split.amountOwed(by: bob)
        XCTAssertEqual(sum, split.total, accuracy: 0.0001)
    }

    // MARK: - Amount owed (even split)

    func testEvenSplitDividesTotalEqually() {
        let (split, alice, bob) = makeStandardSplit(tip: 20, tax: 10, evenSplit: true)
        // Total 26 / 2 people = 13 each, regardless of items.
        XCTAssertEqual(split.amountOwed(by: alice), 13, accuracy: 0.0001)
        XCTAssertEqual(split.amountOwed(by: bob), 13, accuracy: 0.0001)
    }

    func testEvenSplitWithNoPeopleReturnsZero() {
        let split = Split(tipPercentage: 20, taxPercentage: 10, isEvenSplit: true)
        let ghost = Person(name: "Nobody")
        XCTAssertEqual(split.amountOwed(by: ghost), 0, accuracy: 0.0001)
    }

    // MARK: - Assignment state

    func testUnassignedItemsAndFullyAssigned() {
        let alice = Person(name: "Alice")
        let assigned = Item(name: "Soup", price: 8)
        assigned.assignedPeople = [alice]
        let unassigned = Item(name: "Salad", price: 7)

        let split = Split(people: [alice], items: [assigned, unassigned])

        XCTAssertEqual(split.unassignedItems.count, 1)
        XCTAssertFalse(split.isFullyAssigned)

        split.items.removeAll { $0.id == unassigned.id }
        XCTAssertTrue(split.isFullyAssigned)
    }

    func testEmptyItemsIsNotFullyAssigned() {
        let split = Split(people: [Person(name: "Solo")], items: [])
        XCTAssertFalse(split.isFullyAssigned)
    }
}
