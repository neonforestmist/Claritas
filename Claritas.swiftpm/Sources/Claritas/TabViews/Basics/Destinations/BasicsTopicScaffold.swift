import SwiftUI

private enum BasicsTopicScaffoldLayout {
    static let maxContentWidth: CGFloat = 940
    static let sectionSpacing: CGFloat = 20
    static let cardPadding: CGFloat = 16
    static let cardCornerRadius: CGFloat = 16
}

struct BasicsTopicScaffold<Content: View>: View {
    let title: String
    let summary: String
    let takeaways: [String]
    let content: Content

    init(
        title: String,
        summary: String,
        takeaways: [String],
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.summary = summary
        self.takeaways = takeaways
        self.content = content()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BasicsTopicScaffoldLayout.sectionSpacing) {
                BasicsTopicHeader(summary: summary)
                demoCard
                BasicsTakeawaysCard(items: takeaways)
            }
            .padding(20)
            .frame(
                maxWidth: BasicsTopicScaffoldLayout.maxContentWidth,
                alignment: .leading
            )
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .navigationTitle(title)
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }

    private var demoCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Demo", systemImage: "play.rectangle")
                .font(.headline)
                .foregroundStyle(.primary)

            content
        }
        .padding(BasicsTopicScaffoldLayout.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BasicsTopicScaffoldLayout.cardCornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: BasicsTopicScaffoldLayout.cardCornerRadius, style: .continuous)
                .stroke(.separator.opacity(0.45), lineWidth: 0.8)
        }
    }
}

private struct BasicsTopicHeader: View {
    let summary: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Basics", systemImage: "book.closed")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(summary)
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct BasicsTakeawaysCard: View {
    @Environment(\.basicsAccentColor) private var accent
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Good to Know", systemImage: "bookmark")
                .font(.headline)
                .foregroundStyle(.primary)

            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(accent)
                        .padding(.top, 3)

                    Text(item)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(BasicsTopicScaffoldLayout.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: BasicsTopicScaffoldLayout.cardCornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: BasicsTopicScaffoldLayout.cardCornerRadius, style: .continuous)
                .stroke(.separator.opacity(0.45), lineWidth: 0.8)
        }
    }
}
