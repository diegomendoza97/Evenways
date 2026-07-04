# Evenways

**Split restaurant bills fairly, item by item.** Evenways is a native iOS app that makes it effortless to divide a shared bill among friends — assign each item to whoever ordered it, add tip and tax, and see exactly who owes what.

Built with **SwiftUI** and **SwiftData**.

## Features

- **Guided split flow** — a clean 5-step wizard walks you through the whole process:
  1. **Setup** — name the restaurant and add the people at the table
  2. **Add items** — enter receipt line items with prices and quantities
  3. **Assign** — tap to assign each item to the people who shared it
  4. **Tip & tax** — pick a tip preset (15/18/20%) or go custom, set tax, or toggle an even split
  5. **Summary** — review a per-person breakdown and share it
- **Item-level fairness** — costs for shared items are split evenly among only the people who had them.
- **Even-split mode** — optionally divide the whole bill equally, regardless of items.
- **Share results** — export the breakdown as text or as a rendered image.
- **Local history** — saved splits persist on-device with SwiftData.
- **Polished dark UI** — a consistent, custom design system throughout.

## Tech stack

- **Swift** + **SwiftUI** for the entire UI
- **SwiftData** for local persistence
- `ImageRenderer` + `ShareLink` for text/image sharing
- No backend, accounts, or network calls — everything runs on-device

## Project structure

```
Evenways/
├── App/EvenwaysApp.swift        # App entry point + SwiftData container
├── Models/Models.swift          # Split, Person, Item models + split math
└── Views/
    ├── HomeView.swift           # Split history / empty state
    ├── NewSplitSetupView.swift  # Step 1: restaurant + people
    ├── AddItemsView.swift       # Step 2: receipt items
    ├── AssignItemsView.swift    # Step 3: assign items to people
    ├── TipTaxView.swift         # Step 4: tip, tax, even split
    ├── SummaryView.swift        # Step 5: review, share, save
    └── Theme.swift              # Design system + reusable components
```

## Getting started

1. Clone the repo:
   ```bash
   git clone https://github.com/diegomendoza97/Evenways.git
   ```
2. Open `Evenways.xcodeproj` in Xcode.
3. Select an iOS Simulator (or your device) and run.

## Roadmap

- Swipe-to-delete and editing for saved splits
- Multi-currency support
- Receipt scanning (OCR) to auto-import items
- Broader OS version support and localization

## License

Released under the [MIT License](LICENSE).
