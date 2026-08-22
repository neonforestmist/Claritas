import SwiftUI

struct AILimitationsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                LimitationsHeroSection()
                LimitationsOverview()
                LimitationsConceptCards()
                LimitationsTakeaways()
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 28)
            .frame(maxWidth: 940, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .navigationTitle("Limitations")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
}

// MARK: - Hero

private struct LimitationsHeroSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Basics", systemImage: "book.closed")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text("AI can sound completely certain while being completely wrong. That gap between confidence and accuracy is one of the most important things to understand before you rely on any AI output.")
                .font(.title3.weight(.medium))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text("The model doesn't know what it doesn't know. It generates the statistically most likely answer — not the verified correct one. This section walks through the most common ways AI fails, so you can build better habits around the places it matters most.")
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - What AI Can't Do

private struct LimitationsOverview: View {
    @Environment(\.basicsAccentColor) private var accent

    private struct LimitItem {
        let emoji: String
        let title: String
        let detail: String
    }

    private let items: [LimitItem] = [
        LimitItem(
            emoji: "🔁",
            title: "Can't generate truly new ideas",
            detail: "AI remixes and recombines patterns from its training corpus — it can't invent something entirely outside what it has seen before."
        ),
        LimitItem(
            emoji: "💾",
            title: "No persistent memory",
            detail: "By default, each conversation starts completely fresh. The model has no recollection of previous sessions unless memory is explicitly built in."
        ),
        LimitItem(
            emoji: "🌍",
            title: "Can't verify facts in real time",
            detail: "Without a search tool, the model can't check whether its answers are still current or accurate — it only draws on what it was trained on."
        ),
        LimitItem(
            emoji: "🧠",
            title: "No real understanding",
            detail: "AI processes statistical patterns, not meaning. It can write convincingly about a topic without any grasp of what the words actually mean."
        )
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Rectangle()
                    .fill(accent)
                    .frame(width: 4, height: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 2))
                Text("What AI Can't Do")
                    .font(.title2.bold())
                Spacer()
            }

            VStack(alignment: .leading, spacing: 0) {
                ForEach(items.indices, id: \.self) { i in
                    LimitationsListRow(
                        emoji: items[i].emoji,
                        title: items[i].title,
                        detail: items[i].detail
                    )
                    if i < items.count - 1 {
                        Divider()
                            .padding(.leading, 46)
                            .padding(.vertical, 2)
                    }
                }
            }
            .padding(16)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.separator.opacity(0.35), lineWidth: 0.8)
            }
        }
    }
}

private struct LimitationsListRow: View {
    let emoji: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(emoji)
                .font(.title3)
                .frame(width: 30)
                .padding(.top, 1)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 10)
    }
}

// MARK: - Concept Cards

private struct LimitationsConceptCards: View {
    @Environment(\.basicsAccentColor) private var accent

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Rectangle()
                    .fill(accent)
                    .frame(width: 4, height: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 2))

                Text("Common Failure Modes")
                    .font(.title2.bold())

                Spacer()
            }

            LimitInfoRow(
                emoji: "👻",
                icon: "bubble.left.and.exclamationmark.bubble.right",
                color: .red,
                title: "Hallucinations",
                detail: "AI doesn't say \"I don't know\" — it fills gaps with plausible-sounding fiction. Made-up names, dates, citations — all written with complete confidence."
            )
            LimitInfoRow(
                emoji: "⚖️",
                icon: "scalemass",
                color: .orange,
                title: "Bias from Training Data",
                detail: "AI learned from human-written text — which carries human biases. It can reflect, amplify, or reinforce stereotypes without any awareness it's doing so."
            )
            LimitInfoRow(
                emoji: "📅",
                icon: "clock.arrow.circlepath",
                color: .yellow,
                title: "Knowledge Cutoff",
                detail: "AI is frozen in time. It has no access to the web and no awareness of anything that happened after its training data ended. Always check time-sensitive facts."
            )
            LimitInfoRow(
                emoji: "🧮",
                icon: "arrow.triangle.branch",
                color: .purple,
                title: "Weak Long-Chain Reasoning",
                detail: "Simple questions? Great. Multi-step logic, complex math, intricate planning? Errors compound. For high-stakes problems, always double-check the work."
            )
        }
    }
}

private struct LimitInfoRow: View {
    let emoji: String
    let icon: String
    let color: Color
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack(alignment: .bottomTrailing) {
                Text(emoji)
                    .font(.system(size: 28))
                    .frame(width: 46, height: 46)
                    .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                Image(systemName: icon)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(3)
                    .background(color, in: Circle())
                    .offset(x: 3, y: 3)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(color.opacity(0.2), lineWidth: 0.8)
        }
    }
}

// MARK: - Smart Habits

private struct LimitationsTakeaways: View {
    @Environment(\.basicsAccentColor) private var accent

    private let habits: [(step: Int, action: String, why: String)] = [
        (1, "Cross-check facts that matter", "Hallucinations are most common with names, dates, and citations."),
        (2, "Ask \"when was this last true?\"", "AI knowledge is frozen — time-sensitive answers may be outdated."),
        (3, "Watch for confident nonsense", "Fluent writing and high confidence don't mean accuracy."),
        (4, "Treat outputs as a first draft", "Always edit, verify, and adapt before acting on AI text."),
        (5, "Add human review for big decisions", "The higher the stakes, the more a second pair of eyes matters."),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Smart Habits", systemImage: "shield.lefthalf.filled")
                .font(.headline)

            ForEach(habits, id: \.step) { habit in
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        Circle().fill(accent)
                        Text("\(habit.step)")
                            .font(.caption2.weight(.black))
                            .foregroundStyle(.black)
                    }
                    .frame(width: 22, height: 22)
                    .padding(.top, 1)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(habit.action)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                        Text(habit.why)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(accent.opacity(0.25), lineWidth: 0.8)
        }
    }
}

#Preview {
    NavigationStack {
        AILimitationsView()
    }
}
