import NaturalLanguage
import SwiftUI

struct TokenizationDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            InfoCard(
                title: "Tokenization",
                description: "AI never reads individual letters or whole words — it reads *tokens*, small chunks of text. This is why AI can seem confused by tasks such as letter-counting questions.",
                icon: "text.word.spacing",
                color: .green
            )

            DemoSection(title: "🍓 The Strawberry Problem") {
                StrawberryTokenizerDemo()
            }

            DemoSection(title: "💬 Real Conversation") {
                TokenizationChatExample()
            }

            DemoSection(title: "Live Tokenizer") {
                TokenizationLiveDemo()
            }

            TokenizationSummary()
        }
    }
}

// MARK: - Strawberry Problem Demo

private struct StrawberryTokenizerDemo: View {
    @State private var selectedWord: StrawberryWord = .strawberry
    @State private var showTokens = false
    @State private var animatingIndex: Int? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Why this matters callout
            HStack(alignment: .top, spacing: 10) {
                Text("🤔")
                    .font(.title3)
                VStack(alignment: .leading, spacing: 4) {
                    Text("ChatGPT once said \"strawberry\" has 2 R's")
                        .font(.subheadline.weight(.semibold))
                    Text("Not because it's dumb — because it never saw individual letters. It saw *tokens*. Pick a word below and hit Tokenize! to see exactly what the model reads.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.orange.opacity(0.22), lineWidth: 0.8)
            }

            // Word picker
            VStack(alignment: .leading, spacing: 10) {
                Text("Pick a word:")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(StrawberryWord.allCases, id: \.rawValue) { word in
                            Button {
                                withAnimation(.snappy(duration: 0.25)) {
                                    selectedWord = word
                                    showTokens = false
                                    animatingIndex = nil
                                }
                            } label: {
                                Text(word.rawValue)
                                    .font(.caption.weight(.semibold))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    .foregroundStyle(selectedWord == word ? .white : .primary)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .fill(selectedWord == word ? Color.green : Color.secondary.opacity(0.1))
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 1)
                }

                // Large monospaced word display
                HStack(spacing: 0) {
                    ForEach(Array(selectedWord.rawValue.enumerated()), id: \.offset) { _, char in
                        Text(String(char))
                            .font(.system(size: 26, weight: .bold, design: .monospaced))
                            .foregroundStyle(.primary)
                    }
                }
                .padding(.vertical, 6)

                // Tokenize button
                Button {
                    showTokens = false
                    animatingIndex = nil
                    withAnimation(.snappy(duration: 0.2)) { showTokens = true }
                    for i in selectedWord.tokens.indices {
                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.22) {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                animatingIndex = i
                            }
                        }
                    }
                } label: {
                    Label("Tokenize!", systemImage: "scissors")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                // Token chips + facts
                if showTokens {
                    VStack(alignment: .leading, spacing: 12) {
                        // Colored token chips
                        HStack(spacing: 6) {
                            ForEach(Array(selectedWord.tokens.enumerated()), id: \.offset) { index, token in
                                VStack(spacing: 4) {
                                    Text(token.text)
                                        .font(.system(.body, design: .monospaced).weight(.bold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                .fill(token.color)
                                        )
                                    Text("token \(index + 1)")
                                        .font(.caption2.weight(.medium))
                                        .foregroundStyle(.secondary)
                                }
                                .scaleEffect(animatingIndex != nil && animatingIndex! >= index ? 1.0 : 0.4)
                                .opacity(animatingIndex != nil && animatingIndex! >= index ? 1.0 : 0)
                            }
                        }

                        // Stats row
                        HStack(spacing: 16) {
                            StrawberryStatPill(
                                label: "Tokens",
                                value: "\(selectedWord.tokens.count)",
                                color: .green
                            )
                            StrawberryStatPill(
                                label: "Characters",
                                value: "\(selectedWord.rawValue.count)",
                                color: .blue
                            )
                            if selectedWord.rCount > 0 {
                                StrawberryStatPill(
                                    label: "R's (actual)",
                                    value: "\(selectedWord.rCount)",
                                    color: selectedWord.aiWasWrong ? .red : .green
                                )
                            }
                        }

                        // The key insight callout
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: selectedWord.aiWasWrong ? "xmark.circle.fill" : "checkmark.circle.fill")
                                .foregroundStyle(selectedWord.aiWasWrong ? .red : .green)
                                .font(.subheadline)
                            VStack(alignment: .leading, spacing: 3) {
                                if selectedWord == .strawberry {
                                    Text("AI said 2 R's. The real answer is 3.")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(.red)
                                }
                                Text(selectedWord.insight)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(selectedWord.aiWasWrong ? Color.red.opacity(0.06) : Color.green.opacity(0.06))
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(selectedWord.aiWasWrong ? Color.red.opacity(0.2) : Color.green.opacity(0.2), lineWidth: 0.8)
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
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

private struct StrawberryStatPill: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
    }
}

private enum StrawberryWord: String, CaseIterable {
    case strawberry
    case hello
    case unbelievable
    case tokenization
    case AI

    var tokens: [StrawberryTokenPiece] {
        switch self {
        case .strawberry:
            return [StrawberryTokenPiece("str", .red), StrawberryTokenPiece("aw", .orange), StrawberryTokenPiece("berry", .yellow)]
        case .hello:
            return [StrawberryTokenPiece("hello", .green)]
        case .unbelievable:
            return [StrawberryTokenPiece("un", .purple), StrawberryTokenPiece("believ", .indigo), StrawberryTokenPiece("able", .blue)]
        case .tokenization:
            return [StrawberryTokenPiece("token", .teal), StrawberryTokenPiece("ization", .cyan)]
        case .AI:
            return [StrawberryTokenPiece("AI", .mint)]
        }
    }

    var rCount: Int { rawValue.filter { $0 == "r" }.count }
    var aiGuess: Int { self == .strawberry ? 2 : rCount }
    var aiWasWrong: Bool { aiGuess != rCount }

    var insight: String {
        switch self {
        case .strawberry:
            return "The model sees 'str' + 'aw' + 'berry'. The R's are split across token boundaries — so it can't count them by scanning letters."
        case .hello:
            return "Simple, common words usually map to a single token. Efficient and no surprises."
        case .unbelievable:
            return "Long, less-common words get split into familiar sub-word fragments the model has seen often."
        case .tokenization:
            return "'token' is a common prefix in NLP training data, so it gets its own token. The '-ization' suffix is also reused across many words."
        case .AI:
            return "Short well-known abbreviations are usually one token. The model sees them as a single unit."
        }
    }
}

private struct StrawberryTokenPiece {
    let text: String
    let color: Color
    init(_ text: String, _ color: Color) { self.text = text; self.color = color }
}

// MARK: - Chat Example

private enum ChatTokenMode: String, CaseIterable, Identifiable {
    case text = "Text"
    case tokens = "Tokens"
    var id: String { rawValue }
}

private struct TokenizationChatExample: View {
    @State private var displayMode: ChatTokenMode = .text

    private let userMessage = "How many R's are in strawberry?"
    private let aiMessage = "There are 2 R's in strawberry."

    private var userTokens: [SimulatedToken] {
        TokenizationEngine.tokenize(userMessage).filter { $0.kind != .whitespace }
    }

    private var aiTokens: [SimulatedToken] {
        TokenizationEngine.tokenize(aiMessage).filter { $0.kind != .whitespace }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Switch to Tokens to see what the model actually reads — no spaces, just numbered chunks. This is why asking AI to count letters can be surprisingly unreliable.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Picker("Display Mode", selection: $displayMode) {
                ForEach(ChatTokenMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            VStack(spacing: 14) {
                TokenChatBubble(
                    label: "You",
                    labelIcon: "person.fill",
                    message: userMessage,
                    tokens: userTokens,
                    isUser: true,
                    displayMode: displayMode
                )
                TokenChatBubble(
                    label: "AI",
                    labelIcon: "sparkles",
                    message: aiMessage,
                    tokens: aiTokens,
                    isUser: false,
                    displayMode: displayMode
                )
            }
            .animation(.snappy(duration: 0.28), value: displayMode)
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

private struct TokenChatBubble: View {
    let label: String
    let labelIcon: String
    let message: String
    let tokens: [SimulatedToken]
    let isUser: Bool
    let displayMode: ChatTokenMode

    private let palette: [Color] = [.indigo, .green, .orange, .red, .blue, .purple, .mint, .brown, .teal]

    var body: some View {
        VStack(alignment: isUser ? .trailing : .leading, spacing: 5) {
            // Sender label
            HStack(spacing: 4) {
                if !isUser {
                    Image(systemName: labelIcon)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.green)
                }
                Text(label)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                if isUser {
                    Image(systemName: labelIcon)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)

            if displayMode == .text {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(isUser ? .primary : Color.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(
                        isUser ? Color.secondary.opacity(0.15) : Color.green,
                        in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                    )
                    .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)
                    .transition(.opacity.combined(with: .scale(scale: 0.96, anchor: isUser ? .trailing : .leading)))
            } else {
                // Token chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(Array(tokens.enumerated()), id: \.offset) { index, token in
                            VStack(spacing: 3) {
                                Text(token.text)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 5)
                                    .background(
                                        chipColor(for: token, index: index),
                                        in: RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    )
                                Text("\(token.tokenID)")
                                    .font(.system(size: 9).monospacedDigit())
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                }
                .background(
                    isUser ? Color.secondary.opacity(0.10) : Color.green.opacity(0.08),
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(isUser ? Color.secondary.opacity(0.2) : Color.green.opacity(0.2), lineWidth: 0.6)
                }
                .transition(.opacity.combined(with: .scale(scale: 0.96, anchor: isUser ? .trailing : .leading)))
            }
        }
    }

    private func chipColor(for token: SimulatedToken, index: Int) -> Color {
        if token.kind == .punctuation { return .cyan.opacity(0.8) }
        return palette[index % palette.count].opacity(0.85)
    }
}

// MARK: - Live Tokenizer Demo

private struct TokenizationLiveDemo: View {
    @State private var inputText = "User 42 sent 7 messages in 3 minutes."
    @State private var outputMode: TokenOutputMode = .text

    private let exampleText = "User 42 sent 7 messages in 3 minutes."

    private var tokens: [SimulatedToken] {
        TokenizationEngine.tokenize(inputText)
    }

    private var tokenCount: Int {
        tokens.filter { $0.kind != .whitespace }.count
    }

    private var characterCount: Int {
        inputText.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            TextEditor(text: $inputText)
                .font(.title3)
                .scrollContentBackground(.hidden)
                .padding(10)
                .frame(minHeight: 180)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.thinMaterial)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(.separator.opacity(0.45), lineWidth: 1)
                }

            HStack(spacing: 12) {
                Button("Clear") {
                    inputText = ""
                }
                .buttonStyle(.bordered)

                Button("Show example") {
                    inputText = exampleText
                }
                .buttonStyle(.bordered)
            }

            HStack(spacing: 28) {
                TokenizationMetric(title: "Tokens", value: "\(tokenCount)")
                TokenizationMetric(title: "Characters", value: "\(characterCount)")
            }

            VStack(alignment: .leading, spacing: 10) {
                ScrollView {
                    if tokens.isEmpty {
                        Text("Type text to see token highlights.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Text(tokenAttributedString)
                            .font(.system(.title3, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                    }
                }
                .frame(minHeight: 150, alignment: .top)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.quinary)
                )

                Picker("Output Mode", selection: $outputMode) {
                    ForEach(TokenOutputMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 230)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.thinMaterial)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(.separator.opacity(0.45), lineWidth: 0.8)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.thinMaterial)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.separator.opacity(0.35), lineWidth: 0.8)
        }
    }

    private var tokenAttributedString: AttributedString {
        var result = AttributedString()

        for (index, token) in tokens.enumerated() {
            var segment = AttributedString(displayText(for: token))
            segment.foregroundColor = token.kind == .whitespace ? .primary : .white
            segment.backgroundColor = tokenBackgroundColor(for: token, index: index)
            result.append(segment)

            var spacer = AttributedString(" ")
            spacer.foregroundColor = .clear
            result.append(spacer)
        }

        return result
    }

    private func displayText(for token: SimulatedToken) -> String {
        switch outputMode {
        case .text:
            if token.kind == .whitespace {
                return token.text.map { $0 == "\n" ? "↵" : ($0 == "\t" ? "⇥" : "␠") }.joined()
            }
            return token.text
        case .tokenIDs:
            return "\(token.tokenID)"
        }
    }

    private func tokenBackgroundColor(for token: SimulatedToken, index: Int) -> Color {
        if token.kind == .whitespace {
            return .gray.opacity(0.35)
        }

        if token.kind == .punctuation {
            return .cyan.opacity(0.75)
        }

        let palette: [Color] = [
            .indigo, .green, .orange, .red, .blue, .purple, .mint, .brown, .teal
        ]
        return palette[index % palette.count].opacity(0.72)
    }
}

private struct TokenizationMetric: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(size: 28, weight: .regular, design: .rounded))
                .foregroundStyle(.primary)
        }
    }
}

private enum TokenOutputMode: String, CaseIterable, Identifiable {
    case text
    case tokenIDs

    var id: String { rawValue }

    var title: String {
        switch self {
        case .text:
            return "Text"
        case .tokenIDs:
            return "Token IDs"
        }
    }
}

private enum TokenKind {
    case word
    case subword
    case punctuation
    case whitespace
}

private struct SimulatedToken: Identifiable {
    let id: Int
    let text: String
    let kind: TokenKind
    let tokenID: Int
}

private enum TokenizationEngine {
    static func tokenize(_ input: String) -> [SimulatedToken] {
        guard !input.isEmpty else { return [] }

        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = input

        var ranges: [Range<String.Index>] = []
        tokenizer.enumerateTokens(in: input.startIndex..<input.endIndex) { range, _ in
            ranges.append(range)
            return true
        }

        var tokens: [SimulatedToken] = []
        var cursor = input.startIndex
        var nextID = 0

        func appendToken(text: String, kind: TokenKind) {
            let token = SimulatedToken(
                id: nextID,
                text: text,
                kind: kind,
                tokenID: simulatedTokenID(text: text, index: nextID)
            )
            tokens.append(token)
            nextID += 1
        }

        for range in ranges {
            if cursor < range.lowerBound {
                appendSeparatorTokens(
                    from: input[cursor..<range.lowerBound],
                    append: appendToken
                )
            }

            let word = String(input[range])
            let pieces = splitWord(word)
            for piece in pieces {
                appendToken(text: piece, kind: pieces.count > 1 ? .subword : .word)
            }

            cursor = range.upperBound
        }

        if cursor < input.endIndex {
            appendSeparatorTokens(
                from: input[cursor..<input.endIndex],
                append: appendToken
            )
        }

        return tokens
    }

    private static func splitWord(_ word: String) -> [String] {
        let threshold = 7
        let chunkSize = 4
        guard word.count > threshold else { return [word] }

        var pieces: [String] = []
        var index = word.startIndex
        while index < word.endIndex {
            let next = word.index(index, offsetBy: chunkSize, limitedBy: word.endIndex) ?? word.endIndex
            pieces.append(String(word[index..<next]))
            index = next
        }
        return pieces
    }

    private static func appendSeparatorTokens(
        from segment: Substring,
        append: (String, TokenKind) -> Void
    ) {
        var whitespaceBuffer = ""

        for character in segment {
            if isWhitespace(character) {
                whitespaceBuffer.append(character)
                continue
            }

            if !whitespaceBuffer.isEmpty {
                append(whitespaceBuffer, .whitespace)
                whitespaceBuffer = ""
            }

            if isPunctuationOrSymbol(character) {
                append(String(character), .punctuation)
            } else {
                append(String(character), .word)
            }
        }

        if !whitespaceBuffer.isEmpty {
            append(whitespaceBuffer, .whitespace)
        }
    }

    private static func simulatedTokenID(text: String, index: Int) -> Int {
        let familyOffset = 1200
        let hash = text.unicodeScalars.reduce(17) { partial, scalar in
            (partial &* 31 &+ Int(scalar.value)) & 0x7fffffff
        }

        return (hash + familyOffset + (index * 97)) % 50000
    }

    private static func isWhitespace(_ character: Character) -> Bool {
        character.unicodeScalars.allSatisfy { CharacterSet.whitespacesAndNewlines.contains($0) }
    }

    private static func isPunctuationOrSymbol(_ character: Character) -> Bool {
        character.unicodeScalars.allSatisfy {
            CharacterSet.punctuationCharacters.contains($0) || CharacterSet.symbols.contains($0)
        }
    }
}

// MARK: - Token Glossary

private struct TokenizationSummary: View {
    @Environment(\.architectureAccentColor) private var accent

    private let terms: [(term: String, definition: String)] = [
        ("Token", "A small chunk of a word the AI reads. For example, \"strawberry\" might be broken into \"str\", \"aw\", and \"berry\"."),
        ("Token ID", "A unique number assigned to each token. It's like a secret code the AI uses to understand words."),
        ("BPE (Byte Pair Encoding)", "The set of rules the AI uses to decide exactly how to chop words up into smaller tokens."),
        ("Tokenizer", "The tool that takes your normal text and chops it up into tokens so the AI can read it."),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Token Glossary", systemImage: "character.book.closed")
                .font(.headline)
                .foregroundStyle(accent)

            ForEach(terms, id: \.term) { item in
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.term)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.primary)
                    Text(item.definition)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(accent.opacity(0.06), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(accent.opacity(0.15), lineWidth: 0.6)
                }
            }
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    TokenizationDemo()
}
