import SwiftUI

struct BasicsDetailView: View {
    let item: BasicsFeedItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .fill(item.iconBackground.gradient)
                        .overlay {
                            Image(systemName: item.symbolName)
                                .font(.title2.weight(.semibold))
                                .foregroundStyle(item.iconForeground)
                        }
                        .frame(width: 52, height: 52)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                            .font(.title2.weight(.bold))
                    }
                }

                Text(item.summary)
                    .font(.body)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
        }
        .navigationTitle(item.title)
//        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        BasicsDetailView(item: BasicsFeedRepository.featuredFeeds[0])
    }
}
