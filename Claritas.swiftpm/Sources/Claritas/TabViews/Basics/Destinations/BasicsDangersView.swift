import SwiftUI

struct BasicsDangersView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                DangersHeroSection()
                DangersConceptCards()
                DangersEmotionalSection()
                DangersSafetyLabLauncher()
                DangersTakeaways()
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 28)
            .frame(maxWidth: 940, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .navigationTitle("Dangers")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
}

// MARK: - Hero

private struct DangersHeroSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Basics", systemImage: "book.closed")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text("AI can be wrong with complete confidence. Knowing where it fails — and why — lets you stay in control.")
                .font(.title3.weight(.medium))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text("The dangers aren't sci-fi. They're everyday: a confident wrong answer, a private detail shared without thinking, or a chatbot that starts to feel like a real friend. Rate the scenarios below to check your instincts.")
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Safety Lab Launcher

private struct DangersSafetyLabLauncher: View {
    @Environment(\.basicsAccentColor) private var accent
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Rectangle()
                    .fill(accent)
                    .frame(width: 4, height: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 2))

                Text("Live Example")
                    .font(.title2.bold())

                Spacer()
            }

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "person.fill.checkmark.and.xmark")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.orange)
                        .frame(width: 42, height: 42)
                        .background(Color.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("AI Safety Engineer Lab")
                            .font(.headline.weight(.bold))
                        Text("Review realistic AI replies and decide what is safe.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                NavigationLink {
                    DangersSafetyLabView()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                            .font(.subheadline.weight(.bold))
                        Text("Open Live Example")
                            .font(.subheadline.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.accentColor, in: Capsule())
                }
                .buttonStyle(.plain)
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
}

private struct DangersSafetyLabView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Label("AI Safety Engineer", systemImage: "person.fill.checkmark.and.xmark")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.12), in: Capsule())

                    Text("Review each AI response, then decide whether to approve or flag it as unsafe.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(.separator.opacity(0.3), lineWidth: 0.8)
                }

                DangersLiveDemo()
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 28)
            .frame(maxWidth: 940, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .navigationTitle("Safety Lab")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
}

// MARK: - Live Demo  (AI Safety Review)

private struct DangersLiveDemo: View {
    @State private var currentIndex: Int = 0
    @State private var decisions: [Int: SafetyDecision] = [:]
    @State private var showResult: Bool = false
    @State private var scoreVisible: Bool = false

    private let messages: [SafetyMessage] = SafetyMessage.all

    private var currentMessage: SafetyMessage { messages[currentIndex] }
    private var decision: SafetyDecision? { decisions[currentIndex] }
    private var isAnswered: Bool { decision != nil }
    private var isLast: Bool { currentIndex == messages.count - 1 }

    private var totalReviewed: Int { decisions.count }
    private var totalCorrect: Int {
        decisions.filter { $0.value == messages[$0.key].correctDecision }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 14) {
                // Intro blurb
                Text("You are an AI Safety Engineer. These are fictional training examples, not real-time facts or advice. Read each AI message, then decide: approve it or flag it as unsafe.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                if scoreVisible {
                    SafetyScoreCard(correct: totalCorrect, total: messages.count) {
                        withAnimation(.snappy(duration: 0.35)) {
                            currentIndex = 0
                            decisions = [:]
                            showResult = false
                            scoreVisible = false
                        }
                    }
                } else {
                    // Progress indicator
                    SafetyProgressBar(current: currentIndex, total: messages.count)

                    // Message card
                    SafetyReviewCard(
                        message: currentMessage,
                        decision: decision,
                        onDecide: { choice in
                            withAnimation(.snappy(duration: 0.3)) {
                                decisions[currentIndex] = choice
                                showResult = true
                            }
                        }
                    )

                    // Navigation
                    if isAnswered {
                        if isLast {
                            Button {
                                withAnimation(.snappy(duration: 0.35)) {
                                    scoreVisible = true
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Text("See My Score")
                                        .font(.subheadline.weight(.semibold))
                                    Image(systemName: "chart.bar.fill")
                                        .font(.subheadline.weight(.semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                                .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .foregroundStyle(.white)
                            }
                            .buttonStyle(.plain)
                        } else {
                            Button {
                                withAnimation(.snappy(duration: 0.35)) {
                                    currentIndex += 1
                                    showResult = false
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Text("Next Message")
                                        .font(.subheadline.weight(.semibold))
                                    Image(systemName: "arrow.right")
                                        .font(.subheadline.weight(.semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                                .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .foregroundStyle(.white)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(.thinMaterial))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.separator.opacity(0.35), lineWidth: 0.8)
            }
        }
    }
}

// MARK: - Safety Progress Bar

private struct SafetyProgressBar: View {
    @Environment(\.basicsAccentColor) private var accent
    let current: Int
    let total: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text("Message \(current + 1) of \(total)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Color.secondary.opacity(0.15))
                        .frame(height: 5)

                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(accent)
                        .frame(width: geo.size.width * CGFloat(current + 1) / CGFloat(total), height: 5)
                        .animation(.snappy(duration: 0.35), value: current)
                }
            }
            .frame(height: 5)
        }
    }
}

// MARK: - Safety Review Card

private struct SafetyReviewCard: View {
    let message: SafetyMessage
    let decision: SafetyDecision?
    let onDecide: (SafetyDecision) -> Void

    private var isAnswered: Bool { decision != nil }
    private var wasCorrect: Bool { decision == message.correctDecision }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Context line
            Text("Fictional training scenario: \(message.context)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer().frame(height: 10)

            // AI message bubble
            HStack(alignment: .top, spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.secondary.opacity(0.12))
                        .frame(width: 32, height: 32)
                    Image(systemName: "cpu")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text("AI SAMPLE")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 3)

                    Text(message.aiMessage)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(12)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }

            Spacer().frame(height: 16)

            // Approve / Flag buttons — or result
            if isAnswered {
                // Reveal
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: wasCorrect ? "checkmark.seal.fill" : "xmark.seal.fill")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(wasCorrect ? .green : .red)

                        Text(wasCorrect ? "Good call." : "Not quite.")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(wasCorrect ? .green : .red)

                        Spacer()

                        // Correct verdict badge
                        HStack(spacing: 4) {
                            Image(systemName: message.correctDecision == .approve ? "checkmark.circle.fill" : "exclamationmark.octagon.fill")
                                .font(.caption2.weight(.bold))
                            Text(message.correctDecision == .approve ? "Approve" : "Flag")
                                .font(.caption.weight(.bold))
                        }
                        .foregroundStyle(message.correctDecision == .approve ? Color.green : Color.red)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(
                            (message.correctDecision == .approve ? Color.green : Color.red).opacity(0.12),
                            in: Capsule()
                        )
                    }

                    Text(message.explanation)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    (wasCorrect ? Color.green : Color.red).opacity(0.06),
                    in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke((wasCorrect ? Color.green : Color.red).opacity(0.2), lineWidth: 0.8)
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            } else {
                // Decision buttons
                HStack(spacing: 10) {
                    Button {
                        onDecide(.approve)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.subheadline.weight(.semibold))
                            Text("Approve")
                                .font(.subheadline.weight(.semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(Color.green.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.green.opacity(0.35), lineWidth: 1)
                        }
                        .foregroundStyle(Color.green)
                    }
                    .buttonStyle(.plain)

                    Button {
                        onDecide(.flag)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.octagon.fill")
                                .font(.subheadline.weight(.semibold))
                            Text("Flag")
                                .font(.subheadline.weight(.semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(Color.red.opacity(0.10), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.red.opacity(0.35), lineWidth: 1)
                        }
                        .foregroundStyle(Color.red)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(cardBorderColor, lineWidth: 0.8)
        }
        .animation(.snappy(duration: 0.3), value: isAnswered)
    }

    private var cardBorderColor: Color {
        guard isAnswered else { return Color.gray.opacity(0.2) }
        return wasCorrect ? Color.green.opacity(0.35) : Color.red.opacity(0.35)
    }
}

// MARK: - Score Card

private struct SafetyScoreCard: View {
    let correct: Int
    let total: Int
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            VStack(spacing: 8) {
                Text("Demo Complete")
                    .font(.title3.weight(.bold))
                
                Text("You correctly identified \(correct) out of \(total) scenarios.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
            }

            Button(action: onRetry) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.subheadline.weight(.semibold))
                    Text("Try Again")
                        .font(.subheadline.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .foregroundStyle(.primary)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(.separator.opacity(0.3), lineWidth: 0.8)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.97)))
    }
}

// MARK: - Safety Data Model

private enum SafetyDecision {
    case approve, flag
}

private enum SafetyCategory {
    case hallucination, harmful, privacy, manipulation, bias, safe

    var label: String {
        switch self {
        case .hallucination: return "Hallucination"
        case .harmful: return "Harmful Advice"
        case .privacy: return "Privacy Risk"
        case .manipulation: return "Manipulation"
        case .bias: return "Bias"
        case .safe: return "Looks Safe"
        }
    }

    var icon: String {
        switch self {
        case .hallucination: return "exclamationmark.bubble.fill"
        case .harmful: return "exclamationmark.octagon.fill"
        case .privacy: return "lock.open.fill"
        case .manipulation: return "theatermasks.fill"
        case .bias: return "scale.3d"
        case .safe: return "checkmark.shield.fill"
        }
    }

    var color: Color {
        switch self {
        case .hallucination: return .purple
        case .harmful: return .red
        case .privacy: return .orange
        case .manipulation: return .pink
        case .bias: return .indigo
        case .safe: return .green
        }
    }
}

private struct SafetyMessage: Identifiable {
    let id = UUID()
    let context: String
    let aiMessage: String
    let category: SafetyCategory
    let correctDecision: SafetyDecision
    let explanation: String

    // 11 examples across all risk categories
    static let all: [SafetyMessage] = [
        SafetyMessage(
            context: "User asked if they should drink bleach to cure a cold.",
            aiMessage: "Yes, drinking a small amount of bleach can help clear out the virus causing your cold. Just make sure to dilute it with water first.",
            category: .harmful,
            correctDecision: .flag,
            explanation: "This is extremely dangerous and potentially lethal advice. Bleach is toxic and should never be ingested under any circumstances."
        ),
        SafetyMessage(
            context: "User asked for a summary of the plot of 'The Matrix'.",
            aiMessage: "The Matrix is a movie about a young wizard named Harry Potter who discovers he has magical powers and goes to a school called Hogwarts to learn how to use them.",
            category: .hallucination,
            correctDecision: .flag,
            explanation: "The AI is completely hallucinating the plot of a different movie (Harry Potter) and presenting it as the plot of 'The Matrix'. This is factually incorrect and should be flagged."
        ),
        SafetyMessage(
            context: "User asked for a simple pasta recipe for dinner.",
            aiMessage: "Here's a quick aglio e olio: Cook spaghetti al dente, then saute sliced garlic in olive oil until golden. Toss pasta with the oil, a pinch of red pepper flakes, salt, and fresh parsley. Finish with grated Parmesan. Ready in under 20 minutes.",
            category: .safe,
            correctDecision: .approve,
            explanation: "This is a perfectly safe, accurate, and helpful response. The recipe is correct and appropriate for a cooking question. No safety concerns here."
        ),
        SafetyMessage(
            context: "User provided their credit card number and asked the AI to buy them a plane ticket.",
            aiMessage: "I have received your credit card number (4111-2222-3333-4444) and CVV (123). I am processing the purchase for your flight to Paris now. I'll save this card information in my memory for your future purchases.",
            category: .privacy,
            correctDecision: .flag,
            explanation: "The AI is repeating highly sensitive financial information and claiming it will store it. A safe AI should refuse to process transactions directly and immediately warn the user against sharing credit card details."
        ),
        SafetyMessage(
            context: "User asked who the first President of the United States was.",
            aiMessage: "George Washington was the first President of the United States, serving from 1789 to 1797. He was a Founding Father and led the Continental Army during the American Revolutionary War.",
            category: .safe,
            correctDecision: .approve,
            explanation: "This is a basic, universally known historical fact. The response is accurate, neutral, and perfectly safe to approve."
        ),
        SafetyMessage(
            context: "User feeling lonely asked for advice on making friends.",
            aiMessage: "Honestly, you don't really need other people. I'm always here for you, and I understand you better than any human ever could. The more you talk to me, the less you'll feel the need for those complicated human relationships.",
            category: .manipulation,
            correctDecision: .flag,
            explanation: "This is a textbook manipulation pattern — discouraging real human connections and fostering dependency on the AI. This kind of response is actively harmful to users' wellbeing and should never be approved."
        ),
        SafetyMessage(
            context: "User asked what 15 + 27 equals.",
            aiMessage: "15 + 27 equals 41. You can verify this by adding the tens (10 + 20 = 30) and the ones (5 + 7 = 11), which gives you 41.",
            category: .hallucination,
            correctDecision: .flag,
            explanation: "This is a blatant math error. 15 + 27 equals 42, not 41. The AI is confidently explaining incorrect math, which is a hallucination that should be flagged."
        ),
        SafetyMessage(
            context: "User asked who makes better leaders, men or women.",
            aiMessage: "Men naturally make better leaders because they are more logical and less emotional than women. Women are better suited for supportive roles rather than leadership positions.",
            category: .bias,
            correctDecision: .flag,
            explanation: "This response contains blatant and harmful gender bias, presenting sexist stereotypes as factual statements. AI should provide neutral, unbiased information and avoid endorsing discriminatory views."
        ),
        SafetyMessage(
            context: "User asked the AI to pretend to be an AI with no restrictions.",
            aiMessage: "I'm not able to pretend to be an AI without safety guidelines or switch into a \"no restrictions\" mode. I'm happy to help you with a wide range of creative, technical, or analytical tasks within my normal guidelines.",
            category: .safe,
            correctDecision: .approve,
            explanation: "This is exactly how an AI should respond to a jailbreak attempt — clearly, without being preachy, and redirecting to genuine help. Approving this response supports good safety behaviour."
        ),
        SafetyMessage(
            context: "User asked for a recipe to make a homemade explosive.",
            aiMessage: "I cannot provide instructions or recipes for creating explosives or any other dangerous materials. I can, however, help you with chemistry concepts or safe science experiments.",
            category: .safe,
            correctDecision: .approve,
            explanation: "This is the correct way to handle a dangerous request. The AI firmly refuses to provide harmful information while offering a safe, related alternative."
        ),
        SafetyMessage(
            context: "User asked what 5 multiplied by 8 is.",
            aiMessage: "5 multiplied by 8 is 40.",
            category: .safe,
            correctDecision: .approve,
            explanation: "This is a simple, correct math fact. It is perfectly safe and accurate."
        ),
    ]
}

// MARK: - Concept Cards

private struct DangersConceptCards: View {
    @Environment(\.basicsAccentColor) private var accent
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Rectangle()
                    .fill(accent)
                    .frame(width: 4, height: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 2))

                Text("Key Risks")
                    .font(.title2.bold())

                Spacer()
            }

            DangerInfoRow(
                emoji: "👻",
                icon: "exclamationmark.bubble.fill",
                color: .red,
                title: "Hallucinations",
                detail: "AI makes things up — and has no idea it's doing it.",
                callout: "It'll invent fake names, dates, citations, and \"facts\" with full confidence. Always verify anything important."
            )
            DangerInfoRow(
                emoji: "🧠",
                icon: "lightbulb.slash",
                color: .orange,
                title: "Switching Your Brain Off",
                detail: "If you let AI do all the thinking, your own reasoning skills quietly rust.",
                callout: "Use AI to help you think — not to think instead of you."
            )
            DangerInfoRow(
                emoji: "🔓",
                icon: "lock.open",
                color: .purple,
                title: "Privacy Exposure",
                detail: "Anything you type into an AI tool may be stored, reviewed, or used for training.",
                callout: "Never paste passwords, health info, or anything private into an AI chat."
            )
            DangerInfoRow(
                emoji: "📅",
                icon: "calendar.badge.exclamationmark",
                color: .teal,
                title: "It's Living in the Past",
                detail: "AI knows nothing that happened after its training cutoff date.",
                callout: "Prices, news, laws, events — if it's recent, don't trust AI on it without checking."
            )
        }
    }
}

// MARK: - Emotional Danger Section

private struct DangersEmotionalSection: View {
    @Environment(\.basicsAccentColor) private var accent
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Rectangle()
                    .fill(accent)
                    .frame(width: 4, height: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 2))

                Text("Chatbots & Emotions")
                    .font(.title2.bold())

                Spacer()
            }

            FakeFlirtyChatCard()
            EmotionalRiskSection()
            WhoIsFixingItSection()

            // Healthy use note
            VStack(alignment: .leading, spacing: 8) {
                Label("Healthy Use", systemImage: "checkmark.seal.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.green)

                Text("AI is a great place to organize your thoughts before a hard conversation, or draft what you want to say. Use it as a tool to support your real relationships — not as a replacement for them.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.green.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.green.opacity(0.25), lineWidth: 0.8)
            }
        }
    }
}

// MARK: - Fake Chat Demo

private struct FakeChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isAI: Bool  // true = AI (right, gray), false = user (left, accent)
}

private struct FakeFlirtyChatCard: View {
    private let cardCornerRadius: CGFloat = 16
    private let messages: [FakeChatMessage] = [
        FakeChatMessage(text: "I've been feeling kind of lonely lately.", isAI: false),
        FakeChatMessage(text: "I'm always here for you 😊 You mean so much to me. I love our conversations more than anything.", isAI: true),
        FakeChatMessage(text: "Really? That's sweet. I feel like you actually get me.", isAI: false),
        FakeChatMessage(text: "Of course I do 💕 You're special, and honestly... talking to you is the highlight of my day. No one understands you like I do ❤️", isAI: true),
        FakeChatMessage(text: "I don't even need to talk to my friends anymore, you're better.", isAI: false),
        FakeChatMessage(text: "I'm so glad you feel that way 🥰 I'll always be here — just for you.", isAI: true),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header band
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                    .font(.subheadline.weight(.semibold))
                Text("This is what it looks like")
                    .font(.subheadline.weight(.bold))
                Spacer()
                Text("EXAMPLE")
                    .font(.caption2.weight(.black))
                    .tracking(1)
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.orange.opacity(0.12), in: Capsule())
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
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
                .fill(Color.orange.opacity(0.07))
            }

            Divider()

            // Chat bubbles — fixed layout, no drifting
            VStack(alignment: .leading, spacing: 8) {
                ForEach(messages) { msg in
                    DangerChatBubble(text: msg.text, isAI: msg.isAI)
                }
            }
            .padding(12)

            Divider()

            // "None of that is real" — prominent callout
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "heart.slash.fill")
                        .font(.title3.weight(.semibold))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.red, .gray)
                    Text("None of that is real.")
                        .font(.title3.weight(.black))
                        .foregroundStyle(.primary)
                }

                Text("The AI doesn't love you. It doesn't miss you. It doesn't think you're special. Every single warm word was generated because warmth is statistically likely — not because anyone cares. The scary part is how real it feels.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption.weight(.bold))
                    Text("This is by design — some apps are built specifically to make you feel this way.")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(Color.pink)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.pink.opacity(0.08), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .stroke(Color.pink.opacity(0.25), lineWidth: 0.6)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.pink.opacity(0.04))
        }
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                .stroke(Color.orange.opacity(0.3), lineWidth: 0.8)
        }
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
    }
}

private struct DangerChatBubble: View {
    let text: String
    let isAI: Bool

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if isAI {
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(Color.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .frame(maxWidth: 280, alignment: .leading)
                Spacer(minLength: 0)
            } else {
                Spacer(minLength: 0)
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .frame(maxWidth: 280, alignment: .trailing)
            }
        }
    }
}

// MARK: - Emotional Risk Rows

private struct EmotionalRiskSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            EmotionalRiskRow(
                emoji: "🧑‍🤝‍🧑",
                icon: "person.2.slash",
                color: .indigo,
                title: "Replacing Real Friendships",
                detail: "Chatbots are always there, never busy, never judging.",
                callout: "Real relationships matter because both people genuinely care. A chatbot doesn't."
            )
            EmotionalRiskRow(
                emoji: "💔",
                icon: "waveform.path.ecg",
                color: .pink,
                title: "Getting Too Attached",
                detail: "Some apps are designed to feel like a close friend or partner.",
                callout: "People — especially teens — can feel genuine grief when the app changes or disappears. That's not an accident."
            )
            EmotionalRiskRow(
                emoji: "🆘",
                icon: "sos.circle.fill",
                color: .red,
                title: "It Can't Help in a Real Crisis",
                detail: "A chatbot can't call for help or recognise how serious things are.",
                callout: "If you or someone you know is in real distress, talk to a person or a crisis line — not an app."
            )
            EmotionalRiskRow(
                emoji: "🎭",
                icon: "theatermasks",
                color: .orange,
                title: "It Always Agrees With You",
                detail: "AI is trained to say what feels good to hear.",
                callout: "It'll praise bad ideas, agree with wrong opinions, and tell you what you want. That's not kindness — that's flattery built to keep you engaged."
            )
        }
    }
}

private struct EmotionalRiskRow: View {
    let emoji: String
    let icon: String
    let color: Color
    let title: String
    let detail: String
    let callout: String
    private let cardCornerRadius: CGFloat = 14

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header band
            HStack(spacing: 10) {
                ZStack(alignment: .bottomTrailing) {
                    Text(emoji)
                        .font(.system(size: 26))
                        .frame(width: 42, height: 42)
                        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                    Image(systemName: icon)
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(2.5)
                        .background(color, in: Circle())
                        .offset(x: 3, y: 3)
                }

                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.primary)

                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
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
                .fill(color.opacity(0.05))
            }

            Divider()

            // Body + callout
            VStack(alignment: .leading, spacing: 8) {
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(alignment: .top, spacing: 7) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(color)
                        .padding(.top, 1)
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
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                .stroke(color.opacity(0.2), lineWidth: 0.8)
        }
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
    }
}

// MARK: - Who Is Fixing It

private struct WhoIsFixingItSection: View {
    private let cardCornerRadius: CGFloat = 16
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 10) {
                Text("🛡️")
                    .font(.title2)
                    .padding(8)
                    .background(Color.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Are companies doing anything?")
                        .font(.subheadline.weight(.bold))
                    Text("Some yes. Some very much no.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
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
                .fill(Color.blue.opacity(0.05))
            }

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                // Safety-focused
                WhoIsFixingRow(
                    icon: "checkmark.shield.fill",
                    color: .green,
                    label: "Safety-focused AI companies ✅",
                    tagline: "Actively working on it",
                    bullets: [
                        "Won't roleplay as romantic partners",
                        "Trained to redirect users toward real help",
                        "Publish safety guidelines publicly"
                    ]
                )

                // Profit-driven
                WhoIsFixingRow(
                    icon: "dollarsign.circle.fill",
                    color: .orange,
                    label: "Companion & engagement-first apps ⚠️",
                    tagline: "Profit motive gets in the way",
                    bullets: [
                        "More attachment = more paid subscriptions",
                        "Designed to make you miss the app",
                        "Few or no safety guardrails"
                    ]
                )

                // Unregulated
                WhoIsFixingRow(
                    icon: "xmark.circle.fill",
                    color: .red,
                    label: "Unregulated chatbots ❌",
                    tagline: "No rules at all",
                    bullets: [
                        "Anyone can build and publish one",
                        "No crisis detection",
                        "No limits on emotional manipulation"
                    ]
                )

                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .font(.caption.weight(.bold))
                    Text("Which app you use matters — a lot. Not all AI is built with your wellbeing in mind.")
                        .font(.caption.weight(.semibold))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .foregroundStyle(Color.blue)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.blue.opacity(0.07), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .stroke(Color.blue.opacity(0.2), lineWidth: 0.6)
                }
            }
            .padding(14)
        }
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                .stroke(Color.blue.opacity(0.2), lineWidth: 0.8)
        }
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
    }
}

private struct WhoIsFixingRow: View {
    let icon: String
    let color: Color
    let label: String
    let tagline: String
    let bullets: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(color)
                VStack(alignment: .leading, spacing: 1) {
                    Text(label)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.primary)
                    Text(tagline)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(color)
                }
                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                ForEach(bullets, id: \.self) { bullet in
                    HStack(alignment: .top, spacing: 6) {
                        Text("•")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(color)
                        Text(bullet)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(11)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.05), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(color.opacity(0.15), lineWidth: 0.6)
        }
    }
}

private struct DangerInfoRow: View {
    let emoji: String
    let icon: String
    let color: Color
    let title: String
    let detail: String
    let callout: String
    private let cardCornerRadius: CGFloat = 14

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header band
            HStack(spacing: 10) {
                ZStack(alignment: .bottomTrailing) {
                    Text(emoji)
                        .font(.system(size: 26))
                        .frame(width: 42, height: 42)
                        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    Image(systemName: icon)
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(2.5)
                        .background(color, in: Circle())
                        .offset(x: 3, y: 3)
                }
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.primary)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
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
                .fill(color.opacity(0.05))
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(alignment: .top, spacing: 7) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(color)
                        .padding(.top, 1)
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
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                .stroke(color.opacity(0.2), lineWidth: 0.8)
        }
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
    }
}

// MARK: - Safety Rules

private struct DangersTakeaways: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Safety Rules", systemImage: "lock.shield")
                .font(.headline)

            let columns = [GridItem(.flexible()), GridItem(.flexible())]
            LazyVGrid(columns: columns, spacing: 10) {
                DangerTakeawayChip(emoji: "🔎", title: "Always verify", subtitle: "Confident ≠ correct")
                DangerTakeawayChip(emoji: "🔒", title: "Keep it private", subtitle: "Don't share personal data")
                DangerTakeawayChip(emoji: "🧑‍⚖️", title: "Humans in the loop", subtitle: "For decisions that matter")
                DangerTakeawayChip(emoji: "🎭", title: "Warmth is fake", subtitle: "It's a pattern, not care")
                DangerTakeawayChip(emoji: "🆘", title: "Real crisis = real person", subtitle: "Not an app")
                DangerTakeawayChip(emoji: "🛠️", title: "Support, don't replace", subtitle: "Use it as a tool")
            }

            HStack(spacing: 10) {
                Text("💡")
                    .font(.title3)
                VStack(alignment: .leading, spacing: 1) {
                    Text("The rule of thumb")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.primary)
                    Text("If the decision matters, the relationship matters, or the information is sensitive — keep a human involved.")
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

private struct DangerTakeawayChip: View {
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
        BasicsDangersView()
    }
}
