import SwiftUI

// MARK: - Chat Bubble

/// HIG-compliant iMessage-style chat bubble.
/// - `isAgent: true`  → incoming / other person (left side): Liquid Glass material
/// - `isAgent: false` → outgoing / self (right side): solid accent colour, white text
struct ChatBubble: View {
    let text: String
    let isAgent: Bool

    private let cornerRadius: CGFloat = 18

    var body: some View {
        Group {
            if isAgent {
                bubbleContent
                    // Liquid Glass for incoming messages
                    .glassEffect(in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            } else {
                bubbleContent
                    // Solid accent for outgoing messages (iMessage convention, HIG §Chat)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(Color.accentColor)
                    )
            }
        }
    }

    private var bubbleContent: some View {
        Text(text)
            .font(.body)                        // 17pt — HIG minimum for body copy
            .foregroundStyle(isAgent ? Color.primary : Color.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - Thinking Bubble

/// Animated "…" placeholder while the AI generates a reply.
struct ThinkingBubble: View {
    private let cornerRadius: CGFloat = 18

    var body: some View {
        Image(systemName: "ellipsis")
            .symbolEffect(.variableColor)
            .imageScale(.large)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .glassEffect(in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}
