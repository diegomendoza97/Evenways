import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Split.date, order: .reverse) private var splits: [Split]

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                if splits.isEmpty {
                    emptyStateView
                } else {
                    splitListView
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
            .navigationDestination(for: Split.self) { split in
                SummaryView(split: split)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(AppTheme.cardBackground)
                    .frame(width: 100, height: 100)
                Image(systemName: "receipt")
                    .font(.system(size: 40))
                    .foregroundStyle(AppTheme.primary)
            }

            VStack(spacing: 8) {
                Text("No Splits Yet")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(AppTheme.textPrimary)
                Text("Tap the button below to split your first bill.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            NavigationLink {
                NewSplitSetupView()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                    Text("New Split")
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(AppTheme.primary)
                .foregroundStyle(.white)
                .clipShape(Capsule())
            }

            Spacer()
        }
        .padding()
    }

    private var splitListView: some View {
        List {
            ForEach(splits) { split in
                ZStack {
                    // Hidden link avoids the default List disclosure chevron
                    // while keeping the custom card styling.
                    NavigationLink(value: split) { EmptyView() }
                        .opacity(0)
                    SplitRowView(split: split)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            }
            .onDelete(perform: deleteSplits)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .safeAreaInset(edge: .bottom) {
            NavigationLink {
                NewSplitSetupView()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("New Split")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppTheme.primary)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
            .background(AppTheme.background)
        }
    }

    private func deleteSplits(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(splits[index])
        }
    }
}

struct SplitRowView: View {
    let split: Split

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.primary.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: "fork.knife")
                    .foregroundStyle(AppTheme.primary)
                    .font(.title3)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(split.restaurantName)
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)
                HStack(spacing: 6) {
                    Text(split.date, style: .date)
                    Text("·")
                    Text("\(split.people.count) people")
                }
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            Text(split.total, format: .currency(code: "USD"))
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.textPrimary)
        }
        .padding(14)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    HomeView()
        .modelContainer(for: Split.self, inMemory: true)
        .preferredColorScheme(.dark)
}
