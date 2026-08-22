import SwiftUI

struct BasicsRow: View {
    let item: BasicsFeedItem

    var body: some View {
        ShelfNavigationCard(
            title: item.title,
            summary: item.summary,
            symbolName: item.symbolName,
            iconForeground: item.iconForeground,
            iconBackground: item.iconBackground
        )
    }
}

struct ShelfNavigationCard: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let eyebrow: String?
    let title: String
    let summary: String
    let symbolName: String
    let iconForeground: Color
    let iconBackground: Color

    init(
        eyebrow: String? = nil,
        title: String,
        summary: String,
        symbolName: String,
        iconForeground: Color = .white,
        iconBackground: Color = .blue
    ) {
        self.eyebrow = eyebrow
        self.title = title
        self.summary = summary
        self.symbolName = symbolName
        self.iconForeground = iconForeground
        self.iconBackground = iconBackground
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                icon

                VStack(alignment: .leading, spacing: 2) {
                    if let eyebrow, eyebrow.isEmpty == false {
                        Text(eyebrow)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                    }

                    Text(title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 6)

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }

            Text(summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.quaternary.opacity(0.6), lineWidth: 1)
        }
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private var icon: some View {
        RoundedRectangle(cornerRadius: 11, style: .continuous)
            .fill(iconBackground.gradient)
            .overlay {
                Image(systemName: symbolName)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(iconForeground)
            }
            .frame(width: 44, height: 44)
            .accessibilityHidden(true)
    }
}

#Preview {
    BasicsRow(item: BasicsFeedRepository.featuredFeeds[0])
        .padding()
}
