import FoundationModels
import SwiftUI

struct WhatIsAIView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                WhatIsAIHeroSection()
                WhatIsAIConceptCards()
                WhatIsAILiveDemo()
                WhatIsAIAnalogy()
                WhatIsAIKeyPoints()
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 28)
            .frame(maxWidth: 940, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .navigationTitle("What Is AI?")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
}

// MARK: - Hero Section

private struct WhatIsAIHeroSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Basics", systemImage: "book.closed")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text("AI is software that learns patterns from massive amounts of data, then uses those patterns to make predictions or generate new content.")
                .font(.title3.weight(.medium))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text("It doesn't think, understand, or have opinions. It finds statistical relationships in data — and gets remarkably good at applying them. Once you understand this, AI becomes a powerful tool instead of a mysterious black box.")
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

        }
    }
}

// MARK: - Concept Cards (InfoCard-style)

private struct WhatIsAIConceptCards: View {
    @Environment(\.basicsAccentColor) private var accent

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Core Concepts", icon: "brain", accent: accent)

            // Three concept tiles side by side on wider screens, stacked on small
            VStack(spacing: 12) {
                WhatIsAIConceptTile(
                    emoji: "📚",
                    icon: "book.fill",
                    color: .green,
                    title: "Learning (Training)",
                    detail: "Just like reading lots of books to learn a new subject, the AI reads billions of texts to learn how human language works."
                )
                WhatIsAIConceptTile(
                    emoji: "💡",
                    icon: "sparkles",
                    color: .purple,
                    title: "Answering (Inference)",
                    detail: "When you ask a question, the AI uses everything it learned from reading to generate a helpful response just for you."
                )
                WhatIsAIConceptTile(
                    emoji: "🧩",
                    icon: "puzzlepiece.fill",
                    color: .orange,
                    title: "Building Words (Token Prediction)",
                    detail: "The AI doesn't think in whole sentences. It builds its answers one tiny piece of a word at a time, like putting together a puzzle."
                )
            }
        }
    }

    private func sectionHeader(title: String, icon: String, accent: Color) -> some View {
        HStack {
            Rectangle()
                .fill(accent)
                .frame(width: 4, height: 28)
                .clipShape(RoundedRectangle(cornerRadius: 2))

            Text(title)
                .font(.title2.bold())
                .foregroundStyle(.primary)

            Spacer()
        }
    }
}

private struct WhatIsAIConceptTile: View {
    let emoji: String
    let icon: String
    let color: Color
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Big emoji + colored icon badge
            ZStack(alignment: .bottomTrailing) {
                Text(emoji)
                    .font(.system(size: 32))
                    .frame(width: 50, height: 50)
                    .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                Image(systemName: icon)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(3)
                    .background(color, in: Circle())
                    .offset(x: 4, y: 4)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.primary)
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

// MARK: - Emoji Pattern Guesser

/// Five fruit emojis the user can pick from.
private let fruitEmojis: [String] = ["🍎", "🍊", "🍋", "🍇", "🍓"]

private struct WhatIsAILiveDemo: View {
    @Environment(\.basicsAccentColor) private var accent
    @State private var sequence: [String] = []
    @State private var prediction: String?
    @State private var isGuessing = false
    @State private var scanIndex: Int?
    @State private var showResult = false

    // Good repeating-pattern examples so the AI's guess is obviously correct
    private let examples: [[String]] = [
        ["🍎", "🍎", "🍎", "🍎"],
        ["🍎", "🍊", "🍎", "🍊"],
        ["🍎", "🍊", "🍋", "🍎", "🍊", "🍋"],
        ["🍇", "🍇", "🍓", "🍇", "🍇", "🍓"],
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack {
                Rectangle()
                    .fill(accent)
                    .frame(width: 4, height: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 2))
                Text("Pattern Guesser")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 16) {
                Text("AI recognises patterns and predicts what comes next — the same idea behind every language model. Build an emoji sequence, then let it guess the next one. You can also tap the predicted emoji to add it to your sequence.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                // ── Sequence display ──────────────────────────────────────
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Text("YOUR SEQUENCE")
                            .font(.caption2.weight(.bold))
                            .tracking(0.8)
                            .foregroundStyle(.secondary)
                        Spacer()
                        if !sequence.isEmpty {
                            Button {
                                withAnimation(.snappy(duration: 0.25)) {
                                    sequence = []
                                    prediction = nil
                                    showResult = false
                                    scanIndex = nil
                                }
                            } label: {
                                Text("Clear")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(.thinMaterial, in: Capsule())
                                    .overlay {
                                        Capsule()
                                            .stroke(.separator.opacity(0.3), lineWidth: 0.6)
                                    }
                            }
                            .buttonStyle(.plain)
                            .tint(accent)
                        }
                    }

                    if sequence.isEmpty {
                        Text("Tap a fruit below or hit \"Use Example\" to start")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                            .frame(minHeight: 52, alignment: .leading)
                    } else {
                        // Wrapping flow — chips reflow to new rows automatically
                        SequenceFlowLayout(spacing: 6) {
                            ForEach(Array(sequence.enumerated()), id: \.offset) { idx, emoji in
                                EmojiChip(
                                    emoji: emoji,
                                    isScanning: scanIndex == idx,
                                    color: chipColor(for: idx)
                                )
                            }

                            // Predicted chip — appears inline right after sequence
                            if showResult, let p = prediction {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.right")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(.orange)
                                    Button {
                                        guard sequence.count < 12 else { return }
                                        withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
                                            sequence.append(p)
                                            prediction = nil
                                            showResult = false
                                        }
                                    } label: {
                                        EmojiChip(emoji: p, isScanning: false, color: .orange)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .transition(.scale(scale: 0.5).combined(with: .opacity))
                            } else if !isGuessing {
                                Image(systemName: "questionmark.circle.dashed")
                                    .font(.system(size: 32))
                                    .foregroundStyle(.tertiary)
                            }
                        }


                    }
                }

                // ── Fruit picker ──────────────────────────────────────────
                VStack(alignment: .leading, spacing: 8) {
                    Text("ADD TO SEQUENCE")
                        .font(.caption2.weight(.bold))
                        .tracking(0.8)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 10) {
                        ForEach(fruitEmojis, id: \.self) { emoji in
                            Button {
                                guard !isGuessing && sequence.count < 12 else { return }
                                withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
                                    sequence.append(emoji)
                                    prediction = nil
                                    showResult = false
                                }
                            } label: {
                                Text(emoji)
                                    .font(.system(size: 36))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(
                                        Color.secondary.opacity(0.08),
                                        in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    )
                            }
                            .buttonStyle(.plain)
                            .disabled(isGuessing)
                        }
                    }
                }

                // ── Action buttons ────────────────────────────────────────
                HStack(spacing: 10) {
                    Button {
                        guard !isGuessing else { return }
                        let pick = examples.randomElement() ?? examples[0]
                        withAnimation(.snappy(duration: 0.28)) {
                            sequence = pick
                            prediction = nil
                            showResult = false
                            scanIndex = nil
                        }
                    } label: {
                        Label("Use Example", systemImage: "wand.and.stars")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.regular)
                    .disabled(isGuessing)

                    Button {
                        runGuess()
                    } label: {
                        Label(
                            isGuessing ? "Thinking…" : "Guess Next",
                            systemImage: isGuessing ? "hourglass" : "sparkles"
                        )
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .controlSize(.regular)
                    .disabled(isGuessing || sequence.isEmpty)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.separator.opacity(0.35), lineWidth: 0.8)
            }
        }
    }

    // MARK: Helpers

    private func chipColor(for index: Int) -> Color {
        if scanIndex == index { return .orange }
        let colors: [Color] = [.indigo, .green, .blue, .purple, .teal, .pink]
        return colors[index % colors.count]
    }

    private func runGuess() {
        guard !sequence.isEmpty else { return }
        isGuessing = true
        showResult = false
        prediction = nil
        scanIndex = nil

        for i in sequence.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.18) {
                withAnimation(.easeInOut(duration: 0.15)) { scanIndex = i }
            }
        }

        let revealDelay = Double(sequence.count) * 0.18 + 0.32
        DispatchQueue.main.asyncAfter(deadline: .now() + revealDelay) {
            withAnimation(.spring(response: 0.42, dampingFraction: 0.72)) {
                scanIndex = nil
                prediction = computePrediction(for: sequence)
                showResult = true
                isGuessing = false
            }
        }
    }

    /// Detects the repeating pattern and returns the predicted next emoji.
    /// Tries periods 1–4, then falls back to the most frequent emoji.
    private func computePrediction(for seq: [String]) -> String {
        for period in 1...min(4, seq.count) {
            let unit = Array(seq.prefix(period))
            let repeatCount = seq.count / period
            let reconstructed = Array(Array(repeating: unit, count: repeatCount + 1).joined().prefix(seq.count))
            if reconstructed == seq {
                return unit[seq.count % period]
            }
        }
        // Fallback: most frequent emoji in the sequence
        return seq.reduce(into: [:]) { $0[$1, default: 0] += 1 }
            .max(by: { $0.value < $1.value })?.key ?? fruitEmojis[0]
    }
}

// MARK: - Emoji Chip

private struct EmojiChip: View {
    let emoji: String
    let isScanning: Bool
    let color: Color

    var body: some View {
        Text(emoji)
            .font(.system(size: 30))
            .frame(width: 52, height: 52)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(color.opacity(isScanning ? 0.28 : 0.11))
            )
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(color.opacity(isScanning ? 0.80 : 0.22), lineWidth: isScanning ? 2 : 0.8)
            }
            .scaleEffect(isScanning ? 1.12 : 1.0)
            .shadow(color: isScanning ? color.opacity(0.45) : .clear, radius: 6)
            .animation(.spring(response: 0.22, dampingFraction: 0.60), value: isScanning)
    }
}

// MARK: - Sequence Flow Layout
//
// A simple left-to-right wrapping layout — like CSS flexbox wrap.
// Avoids LazyVGrid constraints that can cause crashes when the content
// changes rapidly inside conditional branches.

private struct SequenceFlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 320
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > width && x > 0 {
                y += rowHeight + spacing
                totalHeight = y
                x = 0
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        totalHeight += rowHeight
        return CGSize(width: width, height: max(totalHeight, 52))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX && x > bounds.minX {
                y += rowHeight + spacing
                x = bounds.minX
                rowHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

// MARK: - Analogy Card

private struct WhatIsAIAnalogy: View {
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.snappy(duration: 0.3)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    Text("💡")
                        .font(.title2)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Analogy: World's Best Autocomplete")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text(isExpanded ? "Tap to collapse" : "Tap to expand")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    AnalogyStep(number: 1, emoji: "⌨️", text: "Your keyboard suggests \"the\" after \"I went to\" because it's seen that pattern millions of times.")
                    AnalogyStep(number: 2, emoji: "🌐", text: "A language model does exactly this — but trained on books, websites, code, and conversations from across the internet.")
                    AnalogyStep(number: 3, emoji: "🔁", text: "It picks the most probable next token, appends it, then repeats — thousands of times per response.")
                    AnalogyStep(number: 4, emoji: "🎭", text: "The result feels like understanding. But the model has no idea what it just said — it only calculated probabilities.")
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.separator.opacity(0.35), lineWidth: 0.8)
        }
    }
}

private struct AnalogyStep: View {
    @Environment(\.basicsAccentColor) private var accent
    let number: Int
    let emoji: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                Circle().fill(accent)
                Text("\(number)")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
            }
            .frame(width: 22, height: 22)

            HStack(spacing: 6) {
                Text(emoji)
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Worth Knowing

private struct WhatIsAIKeyPoints: View {
    private let items: [(icon: String, color: Color, label: String, detail: String)] = [
        ("arrow.2.squarepath", .indigo, "Remixes, doesn't invent", "Recombines training patterns — never creates outside its corpus."),
        ("calendar.badge.clock", .orange, "Frozen in time", "No awareness of events after its training cutoff date."),
        ("bubble.left.and.exclamationmark.bubble.right", .red, "Hallucinations", "States incorrect facts, fake citations, or made-up details with full confidence."),
        ("scalemass", .yellow, "Reflects biases", "Reproduces and can amplify biases present in its training data."),
        ("brain.head.profile", .purple, "No understanding", "Processes statistical patterns — not meaning, intent, or common sense."),
        ("memorychip", .teal, "No memory", "Each conversation starts fresh unless memory is explicitly built in."),
        ("globe.badge.chevron.backward", .blue, "Can't fact-check", "Without a search tool, it can't verify whether its answers are current."),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Worth Knowing", systemImage: "info.circle")
                .font(.headline)
                .foregroundStyle(.primary)

            ForEach(items, id: \.label) { item in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: item.icon)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(item.color)
                        .frame(width: 24, height: 24)
                        .padding(.top, 1)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.label)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                        Text(item.detail)
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
                .stroke(.separator.opacity(0.45), lineWidth: 0.8)
        }
    }
}

#Preview {
    NavigationStack {
        WhatIsAIView()
            .environment(FoundationManager())
    }
}
