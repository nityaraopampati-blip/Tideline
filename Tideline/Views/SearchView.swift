import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var appState: AppState
    @State private var query = ""
    @FocusState private var isFocused: Bool

    private let allItems = PlasticItemLibrary.shared.items

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespaces)
    }

    private var filteredItems: [PlasticItem] {
        guard !trimmedQuery.isEmpty else { return [] }
        let lowered = trimmedQuery.lowercased()
        return allItems.filter { $0.name.lowercased().contains(lowered) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                tipBox
                searchField

                if trimmedQuery.isEmpty {
                    prompt
                } else if filteredItems.isEmpty {
                    noResults
                } else {
                    resultsList
                }
            }
            .padding(20)
        }
        .background(TideTheme.background.ignoresSafeArea())
        .navigationDestination(for: PlasticItem.self) { item in
            ResultView(item: item)
                .onAppear { appState.recordScan(item: item, method: .search) }
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var tipBox: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("💡").font(.system(size: 16))
            Text("Type what you're holding — even a general word like \"bottle\" or \"bag\" works.")
                .font(.system(size: 12.5))
                .foregroundStyle(Color(hex: 0x0D3A32))
        }
        .padding(12)
        .background(TideTheme.seafoamLight)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(TideTheme.inkSoft)
            TextField("e.g. \"straw\"", text: $query)
                .focused($isFocused)
                .font(.system(size: 15))
                .foregroundStyle(TideTheme.ink)
                .autocorrectionDisabled()
            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(TideTheme.inkSoft.opacity(0.6))
                }
            }
        }
        .padding(13)
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(isFocused ? TideTheme.seafoam : TideTheme.line, lineWidth: 1.4)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var prompt: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 30))
                .foregroundStyle(TideTheme.inkSoft.opacity(0.35))
            Text("Start typing to search Tideline's verified database.")
                .font(.system(size: 13))
                .foregroundStyle(TideTheme.inkSoft)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }

    private var noResults: some View {
        Text("No matches for \"\(trimmedQuery)\" — try a different word, or check the spelling.")
            .font(.system(size: 13))
            .foregroundStyle(TideTheme.inkSoft)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
    }

    private var resultsList: some View {
        VStack(spacing: 10) {
            ForEach(filteredItems) { item in
                NavigationLink(value: item) {
                    HStack {
                        Text(item.name)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(TideTheme.ink)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(TideTheme.inkSoft.opacity(0.5))
                    }
                    .padding(14)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(TidePressableStyle())
            }
        }
    }
}

#Preview {
    NavigationStack {
        SearchView()
            .environmentObject(AppState())
    }
}
