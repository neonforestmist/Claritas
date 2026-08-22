import SwiftUI

struct AIMythsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                MythsHeroSection()
                MythsIsItTrueSection()
                MythsLiveExampleSection()
                MythsConceptCards()
                MythsTakeaways()
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 28)
            .frame(maxWidth: 940, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .navigationTitle("Myths")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
}

// MARK: - Hero

private struct MythsHeroSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Basics", systemImage: "book.closed")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text("AI is one of the most hyped technologies ever — which means it's also one of the most misunderstood. Myths spread because AI outputs look so human that it's easy to assume there's a mind behind them.")
                .font(.title3.weight(.medium))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Separating fact from fiction is the first step to using AI well. If you overestimate what it can do, you'll be blindsided by its failures. Underestimate it, and you'll miss out on genuine value. Tap each card to test your instincts.")
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Is it true?

private struct MythsIsItTrueSection: View {
    @Environment(\.basicsAccentColor) private var accent
    @State private var revealedCards: Set<Int> = []

    private let items: [MythFactItem] = [
        MythFactItem(
            statement: "AI understands what it reads.",
            isMyth: true,
            explanation: "AI doesn't actually read or comprehend anything. It's very good at spotting patterns in text and predicting what word comes next — but that's pattern matching, not understanding. Ask it something genuinely new and it'll still produce a confident answer, even if it's completely wrong.",
            emoji: "🧠",
            keyPoint: "No understanding. No meaning. Just very fast pattern matching."
        ),
        MythFactItem(
            statement: "AI text can sound just as natural as something a human wrote.",
            isMyth: false,
            explanation: "This one is actually true. Modern AI has read so much human writing that its output can be genuinely hard to tell apart from a real person. That's what makes it so useful — and also why it's important to double-check facts, because confident and fluent doesn't mean correct.",
            emoji: "✍️",
            keyPoint: "Fluent writing ≠ accurate writing. Always verify the important stuff."
        ),
        MythFactItem(
            statement: "AI will take most people's jobs.",
            isMyth: true,
            explanation: "AI is much better at replacing specific tasks within a job than whole jobs themselves. A spreadsheet didn't replace accountants — it just changed what they spend their time on. AI is doing the same thing. The people who learn to use it well tend to do better, not worse.",
            emoji: "💼",
            keyPoint: "AI changes jobs — it rarely eliminates them. Adapters win."
        ),
        MythFactItem(
            statement: "AI can sound totally confident while being completely wrong.",
            isMyth: false,
            explanation: "Absolutely true. AI generates text based on what words are likely to appear next — not based on what's actually correct. There's no internal fact-checker. The result can be written beautifully, stated with total certainty, and be entirely made up.",
            emoji: "⚠️",
            keyPoint: "Confidence ≠ accuracy. Never trust AI blindly on important facts."
        )
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack {
                Rectangle()
                    .fill(accent)
                    .frame(width: 4, height: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 2))

                Text("Is it true?")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)

                Spacer()
            }

            VStack(spacing: 12) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    MythFactCard(
                        item: item,
                        isRevealed: revealedCards.contains(index),
                        onTap: {
                            withAnimation(.snappy(duration: 0.35)) {
                                if revealedCards.contains(index) {
                                    revealedCards.remove(index)
                                } else {
                                    revealedCards.insert(index)
                                }
                            }
                        }
                    )
                }
            }

        }
    }
}

// MARK: - Live Example (Vending Machine Promo)

private struct MythsLiveExampleSection: View {
    @Environment(\.basicsAccentColor) private var accent

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack {
                Rectangle()
                    .fill(accent)
                    .frame(width: 4, height: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 2))

                Text("Live Example")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)

                Spacer()
            }

            // Explanation card
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "arcade.stick.console")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.orange)
                        .padding(10)
                        .background(Color.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                    VStack(alignment: .leading, spacing: 3) {
                        Text("AI Vending Machine")
                            .font(.headline.weight(.bold))
                    }

                    Spacer()
                }

                Text("Remember the myth \"AI will take your job\"? Here's a demo of what happens when AI tries to run something as simple as a vending machine. Inspired by a real incident where an AI assistant was tasked with operating a vending machine — and confidently dispensed wrong items, invented discounts, and charged random prices.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Order snacks across 6 rounds and see how many the AI gets right. Spoiler: not many.")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                // Solid pill button
                NavigationLink(value: BasicsDestination.vendingMachine) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                            .font(.subheadline.weight(.bold))
                        Text("Play the Minigame")
                            .font(.subheadline.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(accent, in: Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.orange.opacity(0.25), lineWidth: 0.8)
            }
        }
    }
}

private struct MythFactItem {
    let statement: String
    let isMyth: Bool
    let explanation: String
    let emoji: String
    let keyPoint: String

    init(statement: String, isMyth: Bool, explanation: String, emoji: String, keyPoint: String) {
        self.statement = statement
        self.isMyth = isMyth
        self.explanation = explanation
        self.emoji = emoji
        self.keyPoint = keyPoint
    }
}

private struct MythFactCard: View {
    let item: MythFactItem
    let isRevealed: Bool
    let onTap: () -> Void

    private let cardCornerRadius: CGFloat = 16
    private var accentColor: Color { item.isMyth ? .red : .green }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {

                // ── Top band: emoji + verdict icon ──────────────────────────
                HStack(alignment: .center, spacing: 12) {
                    Text(item.emoji)
                        .font(.system(size: 36))

                    VStack(alignment: .leading, spacing: 3) {
                        // Before reveal: "Myth or Fact?" prompt
                        // After reveal: big MYTH / FACT stamp
                        if isRevealed {
                            Text(item.isMyth ? "MYTH" : "FACT")
                                .font(.caption.weight(.black))
                                .tracking(1.5)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(accentColor, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                                .transition(.scale.combined(with: .opacity))
                        } else {
                            Text("MYTH OR FACT?")
                                .font(.caption.weight(.black))
                                .tracking(1.5)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(.quaternary, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                        }

                        if !isRevealed {
                            Text("Tap to reveal")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }

                    Spacer()

                    // Big verdict icon on the right
                    Image(systemName: isRevealed
                          ? (item.isMyth ? "xmark.circle.fill" : "checkmark.circle.fill")
                          : "questionmark.circle.fill")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(isRevealed ? accentColor : Color.secondary.opacity(0.4))
                        .transition(.scale.combined(with: .opacity))
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    UnevenRoundedRectangle(
                        cornerRadii: .init(
                            topLeading: cardCornerRadius,
                            bottomLeading: 0,
                            bottomTrailing: 0,
                            topTrailing: cardCornerRadius
                        ),
                        style: .continuous
                    )
                    .fill(
                        isRevealed
                            ? accentColor.opacity(0.15)
                            : Color.secondary.opacity(0.05)
                    )
                }

                Divider()
                    .padding(.horizontal, 0)

                // ── Statement ───────────────────────────────────────────────
                VStack(alignment: .leading, spacing: 10) {
                    Text("\"\(item.statement)\"")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    // Explanation — only when revealed
                    if isRevealed {
                        Divider()

                        Text(item.explanation)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .transition(.opacity.combined(with: .move(edge: .top)))

                        // Key point callout
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: item.isMyth ? "xmark.seal.fill" : "checkmark.seal.fill")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(accentColor)
                            Text(item.keyPoint)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(accentColor)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(accentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 9, style: .continuous)
                                .stroke(accentColor.opacity(0.2), lineWidth: 0.6)
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(14)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                    .stroke(
                        isRevealed ? accentColor.opacity(0.3) : Color.gray.opacity(0.2),
                        lineWidth: 0.8
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Concept Cards

private struct MythsConceptCards: View {
    @Environment(\.basicsAccentColor) private var accent

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Rectangle()
                    .fill(accent)
                    .frame(width: 4, height: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 2))

                Text("Why Myths Persist")
                    .font(.title2.bold())

                Spacer()
            }

            MythsInfoRow(
                emoji: "🎬",
                icon: "sparkles.tv",
                color: .purple,
                title: "Hollywood & Headlines",
                detail: "Movies like Terminator and Her show AI with human feelings, goals, and ambitions. News headlines swing between \"AI will save the world\" and \"AI will destroy it.\" Neither is true. Real AI is much more like a very capable calculator than a robot with a plan.",
                callout: "Pop culture AI and real AI are almost nothing alike."
            )
            MythsInfoRow(
                emoji: "🤝",
                icon: "heart.fill",
                color: .orange,
                title: "It Sounds So Human",
                detail: "When AI writes warmly — using words like \"I'd be happy to help!\" — it's easy to assume there's someone caring on the other end. There isn't. It writes that way because warmth appears a lot in the text it trained on. It's mimicry, not emotion.",
                callout: "Friendly tone ≠ real feelings. It's a pattern, not a personality."
            )
            MythsInfoRow(
                emoji: "📈",
                icon: "chart.line.uptrend.xyaxis",
                color: .teal,
                title: "The Progress Looks Infinite",
                detail: "AI has genuinely improved at a jaw-dropping pace over the last few years. That makes it tempting to assume it'll soon be able to do everything. But there are real limits — it still can't reliably plan ahead, reason through genuinely new problems, or know anything beyond what it was trained on.",
                callout: "Impressive progress doesn't mean no limits. AI has plenty."
            )
        }
    }
}

private struct MythsInfoRow: View {
    let emoji: String
    let icon: String
    let color: Color
    let title: String
    let detail: String
    let callout: String
    private let cardCornerRadius: CGFloat = 16

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Coloured header band
            HStack(spacing: 12) {
                Text(emoji)
                    .font(.system(size: 32))
                    .padding(10)
                    .background(color.opacity(0.15), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.primary)
                    HStack(spacing: 4) {
                        Image(systemName: icon)
                            .font(.caption2.weight(.semibold))
                        Text("Why myths spread")
                            .font(.caption2.weight(.medium))
                    }
                    .foregroundStyle(color)
                }

                Spacer()
            }
            .padding(14)
            .background {
                UnevenRoundedRectangle(
                    cornerRadii: .init(
                        topLeading: cardCornerRadius,
                        bottomLeading: 0,
                        bottomTrailing: 0,
                        topTrailing: cardCornerRadius
                    ),
                    style: .continuous
                )
                .fill(color.opacity(0.06))
            }

            Divider()

            // Body
            VStack(alignment: .leading, spacing: 10) {
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(alignment: .top, spacing: 7) {
                    Image(systemName: "lightbulb.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(color)
                    Text(callout)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(color)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(9)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(color.opacity(0.2), lineWidth: 0.6)
                }
            }
            .padding(14)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                .stroke(color.opacity(0.2), lineWidth: 0.8)
        }
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
    }
}

// MARK: - Reality Check

private struct MythsTakeaways: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Reality Check", systemImage: "eye.trianglebadge.exclamationmark")
                .font(.headline)

            // 2-column grid of takeaway chips
            let columns = [GridItem(.flexible()), GridItem(.flexible())]
            LazyVGrid(columns: columns, spacing: 10) {
                MythsTakeawayChip(emoji: "🤖", title: "No real understanding", subtitle: "Pattern matching, not thinking")
                MythsTakeawayChip(emoji: "⚠️", title: "Confident ≠ correct", subtitle: "Always verify important facts")
                MythsTakeawayChip(emoji: "💼", title: "Jobs shift, not vanish", subtitle: "Adapt and you'll be fine")
                MythsTakeawayChip(emoji: "🎬", title: "Ignore the movies", subtitle: "Real AI isn't Terminator")
            }

            // Full-width bottom row
            HStack(spacing: 10) {
                Text("🎯")
                    .font(.title3)
                VStack(alignment: .leading, spacing: 1) {
                    Text("The bottom line")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.primary)
                    Text("Knowing what AI can't do is just as useful as knowing what it can. That's what separates people who use it well from people who get burned by it.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
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

private struct MythsTakeawayChip: View {
    let emoji: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(emoji)
                .font(.title2)
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(.primary)
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(.separator.opacity(0.3), lineWidth: 0.6)
        }
    }
}

#Preview {
    NavigationStack {
        AIMythsView()
    }
}
