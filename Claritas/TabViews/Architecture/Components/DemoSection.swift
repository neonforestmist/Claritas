import SwiftUI

struct DemoSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionTitle(title: title)

            content
        }
    }
}

private struct SectionTitle: View {
    @Environment(\.architectureAccentColor) private var accent
    let title: String

    var body: some View {
        HStack {
            Rectangle()
                .fill(accent)
                .frame(width: 4, height: 28)
                .clipShape(RoundedRectangle(cornerRadius: 2))
                .accessibilityHidden(true)

            Text(title)
                .font(.title2.bold())
                .foregroundStyle(.primary)
                .accessibilityAddTraits(.isHeader)

            Spacer()
        }
    }
}
