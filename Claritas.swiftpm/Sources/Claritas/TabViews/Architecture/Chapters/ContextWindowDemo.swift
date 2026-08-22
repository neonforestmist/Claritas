import FoundationModels
import SwiftUI

struct ContextWindowDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            InfoCard(
                title: "Context Window",
                description: "Every model has a limit on how much text it can \"see\" at once. Think of it as a spotlight that moves forward through a conversation — once a message slides out of the window, the model has no memory of it. For long chats, this is why models sometimes forget what you said earlier.",
                icon: "rectangle.compress.vertical",
                color: .purple
            )

            DemoSection(title: "Interactive Demo") {
                ContextWindowInlineDemo()
            }

            DemoSection(title: "Live Example") {
                ContextWindowNavigationCard()
            }

            ContextWindowSummary()
        }
    }
}

// MARK: - Inline Live Demo

private struct ContextWindowInlineDemo: View {
    @State private var windowPosition: Int = 0
    @State private var isAnimating = false

    private let allMessages: [(role: String, text: String)] = [
        ("User", "My name is Alex."),
        ("Assistant", "Nice to meet you, Alex!"),
        ("User", "I live in Tokyo."),
        ("Assistant", "Tokyo is a great city!"),
        ("User", "I work as a designer."),
        ("Assistant", "Design is creative work."),
        ("User", "What is my name?"),
        ("Assistant", "I'm not sure — that detail may have left my context window."),
        ("User", "Where do I live?"),
        ("Assistant", "I don't have that information in my active context right now.")
    ]

    private let windowSize = 5

    private var visibleRange: Range<Int> {
        let end = min(windowPosition + windowSize, allMessages.count)
        return windowPosition..<end
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            descriptionText
            messageList
            windowIndicator
            controlButtons
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(.thinMaterial))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(.separator.opacity(0.35), lineWidth: 0.8)
        }
    }

    private var descriptionText: some View {
        Text("The highlighted messages are inside the active window — the model can \"see\" them. Dimmed messages have scrolled out and are invisible to the model. Press \"Advance Window\" to simulate how longer chats with AI will eventually result in it losing previous context from older messages.")
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }

    private var messageList: some View {
        VStack(spacing: 8) {
            ForEach(0..<allMessages.count, id: \.self) { index in
                contextMessageRow(index: index)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.gray.opacity(0.2), lineWidth: 0.8)
        )
    }

    @ViewBuilder
    private func contextMessageRow(index: Int) -> some View {
        let isVisible = index < windowPosition + windowSize
        let isInWindow = visibleRange.contains(index)
        let role = allMessages[index].role
        let text = allMessages[index].text
        let isUser = role == "User"

        if isVisible {
            HStack {
                if !isUser {
                    Spacer(minLength: 40)
                }
                
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(isUser ? Color.primary : Color.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(isUser ? Color(.gray) : Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                
                if isUser {
                    Spacer(minLength: 40)
                }
            }
            .opacity(isInWindow ? 1 : 0.3)
        }
    }

    private var windowIndicator: some View {
        HStack(spacing: 4) {
            Image(systemName: "rectangle.compress.vertical")
                .font(.caption2)
                .foregroundStyle(.purple)
            let windowEnd = min(windowPosition + windowSize, allMessages.count)
            Text("Window: messages \(windowPosition + 1)–\(windowEnd) of \(allMessages.count)")
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
        }
    }

    private var controlButtons: some View {
        HStack(spacing: 10) {
            Button {
                advanceWindow()
            } label: {
                Label(isAnimating ? "Sliding..." : "Advance Window", systemImage: "arrow.right")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
            .controlSize(.large)
            .disabled(isAnimating || windowPosition + windowSize >= allMessages.count)

            Button("Reset") {
                withAnimation(.snappy(duration: 0.3)) {
                    windowPosition = 0
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
    }

    private func advanceWindow() {
        guard windowPosition + windowSize < allMessages.count else { return }
        isAnimating = true
        withAnimation(.snappy(duration: 0.4)) {
            windowPosition += 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isAnimating = false
        }
    }
}

private struct ContextWindowNavigationCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Open the chat demo and type your own messages. Older turns become dimmed once they fall outside the active 5-message context.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            NavigationLink {
                ContextWindowChatDemoView()
            } label: {
                Label("Open Context Window Demo", systemImage: "bubble.left.and.bubble.right.fill")
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

private struct ContextWindowChatDemoView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(FoundationManager.self) private var manager

    @State private var messages: [ContextMessage] = []
    @State private var input = ""
    @State private var isResponding = false
    @State private var errorMessage: String?

    private let contextLimit = 5

    private var activeStartIndex: Int {
        max(messages.count - contextLimit, 0)
    }

    var body: some View {
        Group {
            if manager.isModelAvailable {
                chatContent
            } else {
                IntelligenceUnavailableView()
            }
        }
        .navigationTitle("Context Window Chat")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button("New Chat") {
                    resetChat()
                }
                .disabled(messages.isEmpty || isResponding)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                manager.checkIsAvailable()
            }
        }
        .alert("Prompt Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private var chatContent: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "rectangle.compress.vertical")
                Text("Active context: last \(contextLimit) messages")
                Spacer()
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.secondary)

            if messages.isEmpty {
                ContextWindowEmptyState()
            } else {
                ContextWindowTranscript(
                    messages: messages,
                    activeStartIndex: activeStartIndex,
                    isResponding: isResponding
                )
            }

            TextField("Ask away...", text: $input)
                .textFieldStyle(.roundedBorder)
                .disabled(isResponding)
                .onSubmit {
                    sendMessage()
                }
        }
        .padding()
    }

    private func sendMessage() {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isResponding else { return }

        input = ""
        let userMessage = ContextMessage(role: .user, text: trimmed)
        messages.append(userMessage)
        isResponding = true

        let activeMessages = Array(messages.suffix(contextLimit))

        Task {
            let result = await ContextWindowModelResponder.generateReply(activeMessages: activeMessages)

            await MainActor.run {
                isResponding = false

                switch result {
                case .success(let response):
                    let cleaned = manager.minimizeMarkDown(response).trimmingCharacters(in: .whitespacesAndNewlines)
                    let finalText = cleaned.isEmpty
                        ? "I don't have enough active context to answer confidently."
                        : cleaned
                    messages.append(ContextMessage(role: .assistant, text: finalText))
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    messages.append(ContextMessage(role: .assistant, text: "I hit an error and could not respond."))
                }
            }
        }
    }

    private func resetChat() {
        messages = []
        input = ""
        isResponding = false
        errorMessage = nil
    }
}

private struct ContextWindowTranscript: View {
    let messages: [ContextMessage]
    let activeStartIndex: Int
    let isResponding: Bool

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                ForEach(Array(messages.enumerated()), id: \.element.id) { index, message in
                    HStack {
                        if message.role == .assistant {
                            Spacer(minLength: 50)
                            ChatBubble(text: message.text, isAgent: true)
                        } else {
                            ChatBubble(text: message.text, isAgent: false)
                            Spacer(minLength: 50)
                        }
                    }
                    .opacity(index >= activeStartIndex ? 1 : 0.4)
                    .blur(radius: index >= activeStartIndex ? 0 : 3)
                    .id(message.id)
                }

                if isResponding {
                    HStack {
                        Spacer(minLength: 50)
                        ThinkingBubble()
                    }
                }
            }
            .onChange(of: messages.count) { _, _ in
                guard let lastID = messages.last?.id else { return }
                withAnimation {
                    proxy.scrollTo(lastID, anchor: .bottom)
                }
            }
        }
    }
}

private struct ContextWindowEmptyState: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "rectangle.compress.vertical")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("Type a message to begin.")
                .font(.headline)

            Text("Only the latest 5 messages are sent to the AI each turn.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 320)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 30)
    }
}

private struct ContextMessage: Identifiable, Hashable {
    let id = UUID()
    let role: ContextMessageRole
    let text: String
}

private enum ContextMessageRole: Hashable {
    case user
    case assistant

    var label: String {
        switch self {
        case .user:
            return "User"
        case .assistant:
            return "Assistant"
        }
    }
}

private enum ContextWindowModelResponder {
    private static let systemPrompt = """
    You are a friendly assistant.
    You must answer the user's latest message naturally.
    If the user asks you to recall something (like their name or a previous topic) and it is NOT in the conversation history provided below, you must say that you don't remember or that it has left your context window.
    Keep your answers concise.
    """

    static func generateReply(activeMessages: [ContextMessage]) async -> Result<String, ContextWindowResponderError> {
        let formattedContext = activeMessages.map { message in
            "\(message.role.label): \(message.text)"
        }.joined(separator: "\n")

        let prompt = """
        CONVERSATION HISTORY:
        \(formattedContext)

        Please respond to the final User message above.
        """

        let instructions = Instructions {
            systemPrompt
        }
        let session = LanguageModelSession(instructions: instructions)

        do {
            let response = try await session.respond(to: prompt).content
            return .success(response)
        } catch let error as LanguageModelSession.GenerationError {
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
            return .failure(ContextWindowResponderError(message))
        } catch {
            return .failure(ContextWindowResponderError(error.localizedDescription))
        }
    }
}

private struct ContextWindowResponderError: LocalizedError {
    private let message: String

    init(_ message: String) {
        self.message = message
    }

    var errorDescription: String? {
        message
    }
}

// MARK: - Remember This

private struct ContextWindowSummary: View {
    private let tips: [(icon: String, color: Color, text: String)] = [
        ("clock.arrow.circlepath", .purple, "No persistent memory between sessions — every request re-sends the full context."),
        ("arrow.uturn.left", .red, "Oldest messages are dropped first when the window fills up."),
        ("pin.fill", .orange, "Restate key facts to keep them visible/in context.")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Remember This", systemImage: "brain.head.profile")
                .font(.headline)
                .foregroundStyle(.purple)

            ForEach(tips, id: \.text) { tip in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: tip.icon)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(tip.color)
                        .frame(width: 22)
                        .padding(.top, 1)
                    Text(tip.text)
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
        ContextWindowDemo()
            .environment(FoundationManager())
    }
}
