import SwiftUI
import SwiftData

@main
struct EvenwaysApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(for: Split.self)
    }
}
