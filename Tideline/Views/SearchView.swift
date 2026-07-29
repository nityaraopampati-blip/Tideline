import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var appState: AppState
    @State private var query = ""

    private let allItems = PlasticItemLibrary.shared.items

    private var filteredItems: [PlasticItem] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return allItems }
        let lowered = query.lowercased()
        return allItems.filter { $0.name.lowercased().contains(lowered) }
    }

    var body: some View {
        List {
            if filteredItems.isEmpty {
                Text("No matches for \"\(query)\" — try a different word, or check the spelling.")
                    .font(.system(size: 13))
                    .foregroundStyle(TideTheme.inkSoft)
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(filteredItems) { item in
                    NavigationLink(value: item) {
                        Text(item.name)
                            .font(.system(size: 14))
                            .foregroundStyle(TideTheme.ink)
                    }
                    .listRowBackground(Color(.secondarySystemGroupedBackground))
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(TideTheme.background.ignoresSafeArea())
        .navigationDestination(for: PlasticItem.self) { item in
            ResultView(item: item)
                .onAppear { appState.recordScan(item: item, method: .search) }
        }
        .searchable(text: $query, prompt: "Search for an item, e.g. \"straw\"")
        .navigationTitle("Search")
    }
}

#Preview {
    NavigationStack {
        SearchView()
            .environmentObject(AppState())
    }
}
