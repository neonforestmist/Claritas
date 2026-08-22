import SwiftUI

struct InfoCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            IconView(icon: icon, color: color)

            TextContent(title: title, description: description)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

private struct IconView: View {
    let icon: String
    let color: Color

    var body: some View {
        Image(systemName: icon)
            .font(.title2)
            .foregroundStyle(color)
            .frame(width: 40)
    }
}

private struct TextContent: View {
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)

            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
