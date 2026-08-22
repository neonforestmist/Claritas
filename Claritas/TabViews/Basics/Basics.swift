import SwiftUI

struct Basics: View {
    private let feeds = BasicsFeedRepository.featuredFeeds

    var body: some View {
        NavigationStack {
            List {
                Text("Get up to speed with artificial intelligence. Learn the key concepts, capabilities, and limitations through fun, interactive examples.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)

                ForEach(feeds) { feed in
                    ZStack(alignment: .leading) {
                        NavigationLink(value: feed.destination) { EmptyView() }
                            .opacity(0)
                        BasicsRow(item: feed)
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 9, leading: 16, bottom: 9, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .navigationTitle("Basics")
            .navigationDestination(for: BasicsDestination.self) { destination in
                destination.view()
                    .tint(destination.accentColor)
                    .environment(\.basicsAccentColor, destination.accentColor)
            }
        }
    }
}

#Preview {
    Basics()
}
