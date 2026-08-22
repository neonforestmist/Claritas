import FoundationModels
import SwiftUI

struct PredictionDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            InfoCard(
                title: "Prediction",
                description: "At its core, every language model does one thing: predict what comes next. Given a sequence of tokens (words or word-fragments), it assigns a probability to every possible continuation and picks the most likely one. This repeats thousands of times to build a complete response.",
                icon: "text.cursor",
                color: .orange
            )

            DemoSection(title: "Interactive Demo") {
                PredictionInlineDemo()
            }

            DemoSection(title: "Live Example") {
                PredictionNavigationCard()
            }

            PredictionSummary()
        }
    }
}

// MARK: - Inline Live Demo

private struct PredictionInlineDemo: View {
    @State private var showPredictions = false
    @State private var highlightedToken: Int?
    @State private var isScanning = false

    private let inputTokens = ["The", "weather", "today", "is"]
    private let predictions: [(word: String, probability: Double)] = [
        ("beautiful", 0.38),
        ("sunny", 0.27),
        ("cold", 0.19),
        ("unpredictable", 0.11)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("The model processes each input token in sequence, building up context before selecting the most probable continuation. Tap \"Scan & Predict\" to see this in action.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                Text("Input Tokens")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                HStack(spacing: 6) {
                    ForEach(Array(inputTokens.enumerated()), id: \.offset) { index, token in
                        Text(token)
                            .font(.system(.subheadline, design: .monospaced).weight(.medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(highlightedToken == index ? .orange : .indigo.opacity(0.7))
                            )
                            .scaleEffect(highlightedToken == index ? 1.08 : 1.0)
                    }
                }
            }

            if showPredictions {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Predictions")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    ForEach(Array(predictions.enumerated()), id: \.offset) { _, item in
                        HStack(spacing: 8) {
                            Text(item.word)
                                .font(.system(.caption, design: .monospaced).weight(.semibold))
                                .frame(width: 90, alignment: .leading)

                            GeometryReader { geo in
                                RoundedRectangle(cornerRadius: 3, style: .continuous)
                                    .fill(confidenceGradient(for: item.probability))
                                    .frame(width: geo.size.width * item.probability)
                            }
                            .frame(height: 14)

                            Text("\(Int(item.probability * 100))%")
                                .font(.caption2.monospacedDigit().weight(.bold))
                                .foregroundStyle(.secondary)
                                .frame(width: 30, alignment: .trailing)
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            HStack(spacing: 10) {
                Button {
                    runScan()
                } label: {
                    Label(isScanning ? "Scanning..." : "Predict Next", systemImage: isScanning ? "hourglass" : "sparkles")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .controlSize(.large)
                .disabled(isScanning)

                Button("Reset") {
                    withAnimation(.snappy(duration: 0.3)) {
                        showPredictions = false
                        highlightedToken = nil
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(isScanning)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(.thinMaterial))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(.separator.opacity(0.35), lineWidth: 0.8)
        }
    }

    private func confidenceGradient(for probability: Double) -> LinearGradient {
        let hue = probability * 0.33
        return LinearGradient(
            colors: [Color(hue: hue, saturation: 0.7, brightness: 0.9), Color(hue: hue, saturation: 0.5, brightness: 0.8)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private func runScan() {
        isScanning = true
        showPredictions = false
        highlightedToken = nil

        for i in 0..<inputTokens.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.22) {
                withAnimation(.easeInOut(duration: 0.18)) {
                    highlightedToken = i
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + Double(inputTokens.count) * 0.22 + 0.3) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                showPredictions = true
                highlightedToken = nil
                isScanning = false
            }
        }
    }
}

private struct PredictionNavigationCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Type a sentence, then tap Trigger Prediction to get realistic next tokens and grammar elements.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            NavigationLink {
                PredictionAutocompleteView()
            } label: {
                Label("Open Prediction Demo", systemImage: "arrow.right.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.accentColor)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.thinMaterial)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(.separator.opacity(0.35), lineWidth: 0.8)
        }
    }
}

private struct PredictionAutocompleteView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(FoundationManager.self) private var manager

    @State private var draft = "The sky is"
    @State private var candidates: [PredictedTokenCandidate] = []
    @State private var isLoading = false
    @State private var statusMessage: String?
    @State private var storedContext = ""
    @State private var predictionTask: Task<Void, Never>?
    private let maxPredictionCount = 4

    private var trimmedDraft: String {
        draft.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        Group {
            if manager.isModelAvailable {
#if os(macOS)
                macContent
#else
                iosContent
#endif
            } else {
                IntelligenceUnavailableView()
            }
        }
        .navigationTitle("Prediction")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .onAppear {
            storedContext = trimmedDraft
        }
        .onDisappear {
            predictionTask?.cancel()
        }
        .onChange(of: draft, initial: false) { _, newDraft in
            storedContext = newDraft
            candidates = []
            statusMessage = nil
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                manager.checkIsAvailable()
            }
        }
    }

    private var iosContent: some View {
        Form {
            Section {
                inputSectionBody
            } header: {
                Text("Input Text")
            } footer: {
                Text("Write a sentence. Predictions use stored context to suggest the next word.")
            }

            Section {
                controlsSectionBody
            } header: {
                Text("Controls")
            } footer: {
                Text("Predictions run only when you tap Trigger Prediction.")
            }

            Section {
                predictionsSectionBody
            } header: {
                Text("Token Predictions")
            } footer: {
                if let statusMessage {
                    Text(statusMessage)
                }
            }
        }
    }

    private var macContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                PredictionPanel(
                    title: "Input Text",
                    footer: "Write a sentence. Predictions use stored context to suggest the next word."
                ) {
                    inputSectionBody
                }

                PredictionPanel(
                    title: "Controls",
                    footer: "Predictions run only when you tap Trigger Prediction."
                ) {
                    controlsSectionBody
                }

                PredictionPanel(
                    title: "Token Predictions",
                    footer: statusMessage
                ) {
                    predictionsSectionBody
                }
            }
            .frame(maxWidth: 860)
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .background(.background)
    }

    private var inputSectionBody: some View {
        VStack(alignment: .leading, spacing: 10) {
            TextEditor(text: $draft)
                .font(.body)
                .frame(minHeight: 120)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.quaternary)
                )

            HStack(spacing: 10) {
                Button("Clear") {
                    draft = ""
                    candidates = []
                    statusMessage = nil
                    storedContext = ""
                }
                .buttonStyle(.bordered)
                .disabled(isLoading)
            }
        }
    }

    private var controlsSectionBody: some View {
        Button {
            storedContext = trimmedDraft
            requestPrediction()
        } label: {
            Label(
                isLoading ? "Predicting..." : "Trigger Prediction",
                systemImage: isLoading ? "hourglass" : "sparkles"
            )
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(.accentColor)
        .disabled(isLoading || trimmedDraft.isEmpty)
    }

    private var predictionsSectionBody: some View {
        VStack(alignment: .leading, spacing: 10) {
            if isLoading {
                ProgressView("Predicting...")
            } else if visibleCandidates.isEmpty {
                Text("No predictions yet. Tap Trigger Prediction.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(visibleCandidates) { candidate in
                    PredictionCandidateRow(
                        candidate: candidate,
                        tint: colorForProbability(candidate.probability)
                    ) {
                        insertPrediction(candidate.word)
                    }
                }
            }
        }
    }

    private var visibleCandidates: [PredictedTokenCandidate] {
        Array(candidates.prefix(maxPredictionCount))
    }

    private func requestPrediction() {
        predictionTask?.cancel()

        let input = storedContext.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !input.isEmpty else {
            candidates = []
            isLoading = false
            statusMessage = "Type a sentence first."
            return
        }

        isLoading = true
        statusMessage = nil
        let apiConfiguration = manager.apiConfiguration

        predictionTask = Task {
            let result = await NextWordPredictionEngine.generate(
                for: input,
                maxCount: maxPredictionCount,
                configuration: apiConfiguration
            )
            if Task.isCancelled { return }

            await MainActor.run {
                isLoading = false
                switch result {
                case .success(let output):
                    candidates = output.candidates
                    statusMessage = output.candidates.isEmpty
                        ? "No coherent continuations available for that sentence."
                        : nil
                case .failure(let error):
                    candidates = []
                    statusMessage = error.localizedDescription
                }
            }
        }
    }

    private func insertPrediction(_ prediction: String) {
        draft = NextWordPredictionEngine.inserting(predictedWord: prediction, into: draft)
        storedContext = draft
        candidates = []
        statusMessage = "Inserted \"\(prediction)\"."
    }

    private func colorForProbability(_ probability: Double) -> Color {
        let clamped = max(0, min(1, probability))
        let curved = pow(clamped, 0.6)
        return Color(hue: 0.33 * curved, saturation: 0.86, brightness: 0.93)
    }
}

private struct PredictionPanel<Content: View>: View {
    let title: String
    let footer: String?
    let content: Content

    init(
        title: String,
        footer: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.footer = footer
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            content

            if let footer {
                Text(footer)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.thinMaterial)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(.separator.opacity(0.35), lineWidth: 0.8)
        }
    }
}

private struct PredictionCandidateRow: View {
    let candidate: PredictedTokenCandidate
    let tint: Color
    let onInsert: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(candidate.word)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)

                Spacer()

                Text("\(candidate.percentage)%")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: candidate.probability)
                .tint(tint)

            Button("Insert") {
                onInsert()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.regular)
            .tint(tint)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.quinary)
        )
    }
}

private struct PredictedTokenCandidate: Identifiable, Hashable {
    let id: String
    let word: String
    let percentage: Int

    var probability: Double {
        Double(percentage) / 100
    }

    init(word: String, percentage: Int) {
        self.id = word.lowercased()
        self.word = word
        self.percentage = max(0, min(100, percentage))
    }
}

private struct NextWordPredictionResult {
    let candidates: [PredictedTokenCandidate]
}

private struct NextWordPredictionError: LocalizedError {
    private let message: String

    init(_ message: String) {
        self.message = message
    }

    var errorDescription: String? {
        message
    }
}

@Generable
private struct NextWordPredictionPayload {
    @Guide(description: "The top next-token predictions in descending likelihood.")
    let predictions: [NextWordPredictionItem]
}

@Generable
private struct NextWordPredictionItem {
    @Guide(description: "A single next token that naturally follows the source text.")
    let word: String

    @Guide(description: "Estimated likelihood percentage as an integer from 0 to 100.")
    let percentage: Int
}

private enum NextWordPredictionEngine {
    private static let systemPrompt = """
    You are Apple Foundation Models running as a next-token prediction engine.
    Return only coherent immediate next-token continuations from the exact input context.
    """

    private static let completionPolicy = """
    Always preserve grammar and sentence progression.
    - Keep tense, subject-verb-object flow, and topic continuity coherent.
    - Prefer high-likelihood continuations before stylistic variety.
    - Return only one token per prediction.
    - A token can be a word or a punctuation mark that naturally follows the current text.
    """

    private static let predictionPolicy = """
    - Return candidates that are immediate continuations only (not full sentence rewrites).
    - Rank predictions from highest likelihood to lowest.
    - Never repeat predictions.
    - Use internal model confidence for likelihood percentages (0 to 100).
    """

    static func generate(
        for text: String,
        maxCount: Int,
        configuration: APIConfiguration
    ) async -> Result<NextWordPredictionResult, NextWordPredictionError> {
        let sanitizedInput = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !sanitizedInput.isEmpty else {
            return .failure(NextWordPredictionError("Type a sentence first."))
        }

        if configuration.provider != .appleIntelligence {
            return await generateWithAPI(for: sanitizedInput, maxCount: maxCount, configuration: configuration)
        }

        switch SystemLanguageModel.default.availability {
        case .available:
            do {
                let effectiveMaxCount = max(1, min(4, maxCount))
                let payload = try await modelPredictionsPayload(for: sanitizedInput, maxCount: effectiveMaxCount)
                let validated = validatedPredictions(from: payload.predictions, in: sanitizedInput, maxCount: effectiveMaxCount)
                guard !validated.isEmpty else {
                    return .failure(NextWordPredictionError("The model did not return usable coherent continuations."))
                }

                return .success(
                    NextWordPredictionResult(
                        candidates: validated
                    )
                )
            } catch let error as LanguageModelSession.GenerationError {
                return .failure(NextWordPredictionError(message(for: error)))
            } catch {
                return .failure(NextWordPredictionError(error.localizedDescription))
            }
        case .unavailable:
            return .failure(NextWordPredictionError(modelUnavailableMessage))
        }
    }

    private static func generateWithAPI(
        for text: String,
        maxCount: Int,
        configuration: APIConfiguration
    ) async -> Result<NextWordPredictionResult, NextWordPredictionError> {
        let boundedCount = max(1, min(4, maxCount))
        let prompt = """
        User text:
        \(text)

        Generate exactly up to \(boundedCount) likely immediate next-token predictions.
        Return one prediction per line in this exact format and nothing else:
        word|percentage
        Example:
        green|85
        and|70
        the|65
        Use one word or punctuation mark per line, sorted highest percentage first. Percentages must be integers from 0 to 100.
        """

        do {
            let response = try await OpenAICompatibleClient.complete(prompt: prompt, configuration: configuration)
            let candidates = parseAPIPredictions(response, maxCount: boundedCount)
            guard !candidates.isEmpty else {
                return .failure(NextWordPredictionError("The API returned no usable predictions."))
            }
            return .success(NextWordPredictionResult(candidates: candidates))
        } catch {
            return .failure(NextWordPredictionError(error.localizedDescription))
        }
    }

    private static func parseAPIPredictions(_ response: String, maxCount: Int) -> [PredictedTokenCandidate] {
        var seen = Set<String>()
        var candidates: [PredictedTokenCandidate] = []

        for line in response.components(separatedBy: .newlines) {
            let parts = line.trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: CharacterSet(charactersIn: "`"))
                .split(separator: "|", maxSplits: 1, omittingEmptySubsequences: true)
            guard parts.count == 2,
                  let percentage = Int(parts[1].trimmingCharacters(in: .whitespacesAndNewlines)) else { continue }

            let word = parts[0]
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: #"^\d+[.)]\s*"#, with: "", options: .regularExpression)
            guard !word.isEmpty,
                  !word.contains(where: { $0.isWhitespace }),
                  word.count <= 24 else { continue }

            let key = word.lowercased()
            guard seen.insert(key).inserted else { continue }
            candidates.append(PredictedTokenCandidate(word: word, percentage: percentage))
            if candidates.count == maxCount { break }
        }
        return candidates.sorted { $0.percentage > $1.percentage }
    }

    static func inserting(predictedWord: String, into text: String) -> String {
        let trimmedWord = predictedWord.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedWord.isEmpty else { return text }

        var updated = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !updated.isEmpty else {
            return "\(trimmedWord) "
        }

        let firstScalar = trimmedWord.unicodeScalars.first
        let shouldAttachToPrevious = firstScalar.map { CharacterSet.punctuationCharacters.contains($0) } == true

        if shouldAttachToPrevious {
            return "\(updated)\(trimmedWord) "
        }

        if let lastCharacter = updated.last, !lastCharacter.isWhitespace {
            updated.append(" ")
        }
        updated.append(trimmedWord)
        if !updated.hasSuffix(" ") {
            updated.append(" ")
        }
        return updated
    }

    private static func modelPredictionsPayload(
        for text: String,
        maxCount: Int
    ) async throws -> NextWordPredictionPayload {
        let boundedCount = max(1, min(4, maxCount))
        let prompt = """
        User text:
        \(text)

        Generate up to \(boundedCount) likely immediate continuations.
        Rules:
        - Return 1 prediction item per array element.
        - Each prediction must be exactly one token (word or punctuation).
        - Predictions should be plain text, not quoted, and should include no leading spaces.
        - Keep predictions sorted by likelihood, highest first.
        - percentage is an integer from 0 to 100 from the model's internal confidence.
        - Avoid duplicates.
        - Never return the same prediction text as another.
        """

        let instructions = Instructions {
            "\(systemPrompt)\n\n\(completionPolicy)\n\n\(predictionPolicy)"
        }
        let session = LanguageModelSession(instructions: instructions)

        return try await session.respond(
            to: prompt,
            generating: NextWordPredictionPayload.self
        ).content
    }

    private static func validatedPredictions(
        from predictions: [NextWordPredictionItem],
        in sourceText: String,
        maxCount: Int
    ) -> [PredictedTokenCandidate] {
        let allowedScalars = CharacterSet.alphanumerics
            .union(CharacterSet.punctuationCharacters)
            .union(CharacterSet(charactersIn: "'-"))
        let allowedPunctuationOnlyTokens: Set<String> = [",", ".", "!", "?", ";", ":"]
        var output: [PredictedTokenCandidate] = []
        var seen: Set<String> = []
        let contextTokens = sourceText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(whereSeparator: \.isWhitespace)
        let lastContextWord = contextTokens.last?
            .trimmingCharacters(in: .punctuationCharacters)
            .lowercased() ?? ""

        for item in predictions {
            let normalized = item.word.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !normalized.isEmpty else {
                continue
            }

            let tokens = normalized.split(whereSeparator: \.isWhitespace)
            guard tokens.count == 1, let compact = tokens.first.map(String.init), !compact.isEmpty else { continue }

            let filteredScalars = compact.unicodeScalars.filter { allowedScalars.contains($0) }
            let cleanedWord = String(String.UnicodeScalarView(filteredScalars)).trimmingCharacters(in: .whitespacesAndNewlines)
            guard !cleanedWord.contains(where: \.isWhitespace) else { continue }
            guard !cleanedWord.isEmpty else { continue }
            guard cleanedWord.count <= 24 else { continue }
            let hasAlphaNumeric = cleanedWord.unicodeScalars.contains { CharacterSet.alphanumerics.contains($0) }
            if !hasAlphaNumeric && !allowedPunctuationOnlyTokens.contains(cleanedWord) {
                continue
            }

            let key = cleanedWord.lowercased()
            guard !seen.contains(key) else { continue }
            seen.insert(key)

            if key == "..." {
                continue
            }

            if key.trimmingCharacters(in: .punctuationCharacters) == lastContextWord {
                continue
            }

            output.append(
                PredictedTokenCandidate(
                    word: cleanedWord,
                    percentage: item.percentage
                )
            )

            if output.count == maxCount {
                break
            }
        }

        if output.isEmpty {
            return []
        }

        let sorted = output.sorted { $0.percentage > $1.percentage }
        return Array(sorted.prefix(maxCount))
    }

    private static var modelUnavailableMessage: String {
        switch SystemLanguageModel.default.availability {
        case .available:
            return ""
        case .unavailable(.deviceNotEligible):
            return "Prediction requires an Apple Intelligence eligible device."
        case .unavailable(.appleIntelligenceNotEnabled):
            return "Enable Apple Intelligence in System Settings to run prediction."
        case .unavailable(.modelNotReady):
            return "The on-device model is not ready yet. Please try again shortly."
        case .unavailable(let reason):
            return "Prediction is unavailable: \(String(describing: reason))."
        }
    }

    private static func message(for error: LanguageModelSession.GenerationError) -> String {
        var message: String
        switch error {
        case .guardrailViolation(let context):
            message = "Guardrail violation: \(context.debugDescription)"
        case .decodingFailure(let context):
            message = "Decoding failure: \(context.debugDescription)"
        case .rateLimited(let context):
            message = "Rate limited: \(context.debugDescription)"
        default:
            message = "Generation failed: \(error.localizedDescription)"
        }
        if let failureReason = error.failureReason {
            message += "\n\(failureReason)"
        }
        if let recoverySuggestion = error.recoverySuggestion {
            message += "\n\(recoverySuggestion)"
        }
        return message
    }
}

// MARK: - How It Connects

private struct PredictionSummary: View {
    private let steps: [(step: Int, text: String)] = [
        (1, "Every word is selected probabilistically — not looked up from a database."),
        (2, "The model weighs all previous tokens in its context window before choosing."),
        (3, "AI doesn't always read whole words at once. Sometimes it breaks a long word like \"unbelievable\" into smaller chunks like \"un\" + \"believ\" + \"able\" to understand it better. It can then reuse common chunks like \"able\" to understand other words like \"comfortable\" or \"capable\"."),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("How It Connects", systemImage: "arrow.triangle.branch")
                .font(.headline)
                .foregroundStyle(.orange)

            ForEach(steps, id: \.step) { item in
                HStack(alignment: .top, spacing: 10) {
                    Text("\(item.step)")
                        .font(.caption2.weight(.black))
                        .foregroundStyle(.white)
                        .frame(width: 20, height: 20)
                        .background(Color.orange, in: Circle())
                        .padding(.top, 1)

                    Text(item.text)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        PredictionDemo()
            .environment(FoundationManager())
    }
}
