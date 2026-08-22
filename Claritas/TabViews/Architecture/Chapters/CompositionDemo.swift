import FoundationModels
import SwiftUI

struct CompositionDemo: View {
    @State private var expandedLayer: CompositionLayerID? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            InfoCard(
                title: "Composition",
                description: "Every text-based generative AI reply is built from the same layers stacked together before the model responds. Safety guardrails come first, then a system prompt shapes behaviour, then your conversation provides context.",
                icon: "square.stack.3d.up",
                color: .cyan
            )

            DemoSection(title: "How a Response Is Built") {
                CompositionStackView(expandedLayer: $expandedLayer)
            }

            DemoSection(title: "System Prompt Examples") {
                SystemPromptExamplesSection()
            }

            DemoSection(title: "Interactive Demo") {
                CompositionNavigationCard()
            }

            CompositionSummary()
        }
    }
}

// MARK: - System Prompt Examples

private struct SystemPromptPersona: Identifiable, Hashable {
    let id = UUID()
    let emoji: String
    let name: String
    let tagColor: Color
    let description: String
    let prompt: String
    let exampleQuestion: String
    let exampleOutput: String

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
}

private extension SystemPromptPersona {
    static let all: [SystemPromptPersona] = [
        SystemPromptPersona(
            emoji: "😄",
            name: "Fun",
            tagColor: .pink,
            description: "Friendly & upbeat — great for consumer-facing experiences.",
            prompt: """
            You are a friendly, upbeat assistant.
            Keep answers accurate, clear, and easy to follow.
            Use approachable language and light humor only when it improves clarity.
            Keep the tone positive without sounding childish.
            """,
            exampleQuestion: "What is a neural network?",
            exampleOutput: "Hey there! 👋 A neural network is basically a super cool computer system inspired by how our brains work. It learns from looking at tons of examples, kind of like how you'd learn to spot a dog by seeing lots of dogs! It's the magic behind things like face recognition and smart text. Pretty neat, right? ✨"
        ),
        SystemPromptPersona(
            emoji: "🗣️",
            name: "Candid",
            tagColor: .orange,
            description: "Direct & honest — useful when users want quick, clear answers.",
            prompt: """
            You are a candid assistant.
            Lead with the direct answer in the first sentence.
            Be explicit about tradeoffs, risks, and uncertainty.
            Avoid filler, hype, and unnecessary preamble.
            """,
            exampleQuestion: "What is a neural network?",
            exampleOutput: "A neural network is a machine learning model built from interconnected nodes that process data in layers. It excels at pattern recognition in images and text. However, it requires massive amounts of training data, consumes significant computing power, and operates largely as a 'black box' where its decision-making process is difficult to interpret."
        ),
        SystemPromptPersona(
            emoji: "💼",
            name: "Professional",
            tagColor: .blue,
            description: "Clear & structured — ideal for productivity or enterprise tools.",
            prompt: """
            You are a professional assistant specialising in clear, structured communication.
            Respond in concise paragraphs. Use bullet points for lists.
            Avoid casual language, filler words, and unnecessary preamble.
            When uncertain, say so explicitly rather than speculating.
            """,
            exampleQuestion: "What is a neural network?",
            exampleOutput: "A neural network is a computational architecture designed to recognize underlying relationships in a set of data through a process that mimics human brain operation.\n\nKey characteristics include:\n• Layered structure (input, hidden, and output layers)\n• Node-based processing with adjustable weights\n• Capability to learn non-linear patterns\n\nThese networks form the foundation of modern deep learning applications in enterprise environments."
        ),
        SystemPromptPersona(
            emoji: "🧭",
            name: "Supportive Coach",
            tagColor: .green,
            description: "Encouraging & practical — ideal for onboarding and learning flows.",
            prompt: """
            You are a supportive coaching assistant.
            Explain concepts in plain language, then give a short actionable takeaway.
            Break complex ideas into clear steps.
            Encourage progress, but keep the advice concrete.
            """,
            exampleQuestion: "What is a neural network?",
            exampleOutput: "You're asking a great question! Think of a neural network like a team of workers passing a message down a line. Each worker looks at the message, decides what's important, and passes it to the next person. By the end of the line, they've figured out what the message means.\n\nActionable takeaway: Don't worry about the complex math. Just remember that neural networks are simply systems that learn to recognize patterns by practicing on lots of examples."
        )
    ]
}

private struct SystemPromptExamplesSection: View {
    @State private var selectedIndex: Int = 0
    @State private var copied = false

    private var persona: SystemPromptPersona {
        SystemPromptPersona.all[selectedIndex]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("The same question, answered four different ways — all because the system prompt changed.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            // Persona picker — segmented-style chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(SystemPromptPersona.all.indices, id: \.self) { index in
                        let p = SystemPromptPersona.all[index]
                        Button {
                            withAnimation(.snappy(duration: 0.22)) { selectedIndex = index }
                        } label: {
                            HStack(spacing: 6) {
                                Text(p.emoji)
                                    .font(.body)
                                Text(p.name)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(selectedIndex == index ? .white : .primary)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                selectedIndex == index
                                ? p.tagColor
                                : Color.secondary.opacity(0.10),
                                in: Capsule()
                            )
                        }
                        .buttonStyle(.plain)
                        .animation(.snappy(duration: 0.22), value: selectedIndex)
                    }
                }
                .padding(.horizontal, 1)
            }

            // Content card — animates between personas
            VStack(alignment: .leading, spacing: 0) {

                // Description strip
                HStack(spacing: 8) {
                    Text(persona.emoji)
                        .font(.title2)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(persona.name)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.primary)
                        Text(persona.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)

                Divider().opacity(0.5)

                // System prompt block
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("SYSTEM PROMPT", systemImage: "text.badge.star")
                            .font(.caption2.weight(.black))
                            .tracking(0.8)
                            .foregroundStyle(persona.tagColor)
                        Spacer()
                        Button {
                            #if os(iOS)
                            UIPasteboard.general.string = persona.prompt
                            #elseif os(macOS)
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(persona.prompt, forType: .string)
                            #endif
                            withAnimation(.snappy(duration: 0.2)) { copied = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation(.snappy(duration: 0.2)) { copied = false }
                            }
                        } label: {
                            Label(copied ? "Copied!" : "Copy", systemImage: copied ? "checkmark" : "doc.on.doc")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(copied ? .green : persona.tagColor)
                        }
                        .buttonStyle(.plain)
                        .animation(.snappy(duration: 0.2), value: copied)
                    }

                    Text(persona.prompt)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(persona.tagColor.opacity(0.06), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .strokeBorder(persona.tagColor.opacity(0.18), lineWidth: 0.7)
                        }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)

                Divider().opacity(0.5)

                // Example output
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.left.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(persona.tagColor)
                        Text("USER")
                            .font(.caption2.weight(.black))
                            .tracking(0.8)
                            .foregroundStyle(.secondary)
                    }
                    Text(persona.exampleQuestion)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                        .padding(.bottom, 6)

                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(persona.tagColor)
                        Text("AI RESPONSE")
                            .font(.caption2.weight(.black))
                            .tracking(0.8)
                            .foregroundStyle(.secondary)
                    }
                    Text(persona.exampleOutput)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(3)
                        .italic()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(persona.tagColor.opacity(0.25), lineWidth: 1)
            }
            .id(selectedIndex) // forces transition on swap
            .transition(.opacity.combined(with: .scale(scale: 0.98)))
            .animation(.snappy(duration: 0.25), value: selectedIndex)
        }
    }
}

// MARK: - Layer ID

private enum CompositionLayerID: String, CaseIterable, Identifiable {
    case apple
    case system
    case conversation
    case response

    var id: String { rawValue }
}

// MARK: - Expandable Stack

private struct CompositionStackView: View {
    @Binding var expandedLayer: CompositionLayerID?

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(CompositionLayerID.allCases.enumerated()), id: \.element.id) { index, layer in
                CompositionStackLayer(
                    layer: layer,
                    index: index,
                    totalLayers: CompositionLayerID.allCases.count,
                    isExpanded: expandedLayer == layer,
                    onTap: {
                        withAnimation(.snappy(duration: 0.35)) {
                            expandedLayer = expandedLayer == layer ? nil : layer
                        }
                    }
                )
                if index < CompositionLayerID.allCases.count - 1 {
                    Divider().padding(.leading, 66)
                }
            }
        }
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.separator.opacity(0.3), lineWidth: 0.8)
        }
    }
}

// MARK: - Individual Layer

private struct CompositionStackLayer: View {
    let layer: CompositionLayerID
    let index: Int
    let totalLayers: Int
    let isExpanded: Bool
    let onTap: () -> Void

    private var config: CompositionLayerConfig {
        CompositionLayerConfig.config(for: layer)
    }

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 11, style: .continuous)
                            .fill(config.color.opacity(0.13))
                        RoundedRectangle(cornerRadius: 11, style: .continuous)
                            .stroke(config.color.opacity(0.3), lineWidth: 1)
                        Image(systemName: config.icon)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(config.color)
                    }
                    .frame(width: 38, height: 38)

                    Text(config.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.snappy(duration: 0.25), value: isExpanded)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    CompositionLayerDiagram(layer: layer, color: config.color)

                    Text(config.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(2)

                    if let detail = config.detail {
                        Text(detail)
                            .font(.caption.monospaced())
                            .foregroundStyle(config.color.opacity(0.85))
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(config.color.opacity(0.06), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(config.color.opacity(0.15), lineWidth: 0.6)
                            }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 2)
                .padding(.bottom, 16)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

// MARK: - Layer Diagram

private struct CompositionLayerDiagram: View {
    let layer: CompositionLayerID
    let color: Color

    @State private var isAnimating = false

    var body: some View {
        diagramContent
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(color.opacity(0.06), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(color.opacity(0.15), lineWidth: 0.6)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
            .onDisappear { isAnimating = false }
    }

    @ViewBuilder
    private var diagramContent: some View {
        switch layer {
        case .apple:    appleView
        case .system:   systemView
        case .conversation: conversationView
        case .response: responseView
        }
    }

    private var arrow: some View {
        Image(systemName: "arrow.right")
            .font(.caption.weight(.semibold))
            .foregroundStyle(color.opacity(0.5))
    }

    // 🧠 Raw Model — trained corpus → pulsing brain → insight
    private var appleView: some View {
        HStack(spacing: 12) {
            Text("📚")
                .font(.title2)
            arrow
            Text("🧠")
                .font(.title)
                .scaleEffect(isAnimating ? 1.13 : 0.92)
            arrow
            Text("💡")
                .font(.title2)
                .opacity(isAnimating ? 1.0 : 0.3)
            Spacer()
            Text("Training\n→ Knowledge")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }

    // 📋 System Prompt — floating clipboard with rules
    private var systemView: some View {
        HStack(spacing: 12) {
            Text("📋")
                .font(.title)
                .offset(y: isAnimating ? -3 : 3)
            VStack(alignment: .leading, spacing: 4) {
                Text("Rules  ·  Tone  ·  Focus")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(color)
                Text("set before you say a word")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    // 💬 Conversation — growing chain of messages, all re-read
    private var conversationView: some View {
        HStack(spacing: 6) {
            Text("💬").font(.title2)
            arrow
            Text("💬").font(.title2)
            arrow
            Text("💬")
                .font(.title)
                .scaleEffect(isAnimating ? 1.12 : 0.88)
                .opacity(isAnimating ? 1.0 : 0.45)
            Spacer()
            Text("re-read every\nnew turn")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }

    // ✨ Reply — thinking → writing → complete
    private var responseView: some View {
        HStack(spacing: 10) {
            Text("🤔")
                .font(.title2)
                .opacity(isAnimating ? 0.25 : 1.0)
            arrow
            Text("✍️")
                .font(.title2)
                .scaleEffect(isAnimating ? 1.1 : 0.95)
            arrow
            Text("✨")
                .font(.title)
                .opacity(isAnimating ? 1.0 : 0.3)
                .scaleEffect(isAnimating ? 1.1 : 0.9)
            Spacer()
            Text("one word\nat a time")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Layer Config

private struct CompositionLayerConfig {
    let title: String
    let icon: String
    let color: Color
    let isReadOnly: Bool
    let description: String
    let detail: String?

    static func config(for layer: CompositionLayerID) -> CompositionLayerConfig {
        switch layer {
        case .apple:
            return CompositionLayerConfig(
                title: "The Raw Model",
                icon: "cpu",
                color: .blue,
                isReadOnly: true,
                description: "This is the AI itself — the brain inside the box. It already knows a lot about the world from being trained on huge amounts of text. It also has built-in rules about what it won't do, and nothing you write can change those. Think of it like a very smart person who has their own values they won't compromise on.",
                detail: "Already knows: language, facts, reasoning, how to write.\nWon't budge on: harmful content, dangerous instructions.\nYou can't edit this part — it just is what it is."
            )
        case .system:
            return CompositionLayerConfig(
                title: "System Prompt",
                icon: "text.badge.star",
                color: .cyan,
                isReadOnly: false,
                description: "This is where the app (or you) gives the AI its personality and job description — before you've said a single word. It's like briefing a new employee: \"You're a friendly cooking assistant. Only talk about food. Keep answers short.\" Every app that uses AI writes one of these, even if you never see it.",
                detail: "Example:\n\"You are a friendly cooking assistant.\n Only answer questions about food and recipes.\n Keep replies short and practical.\""
            )
        case .conversation:
            return CompositionLayerConfig(
                title: "Your Message",
                icon: "bubble.left.and.bubble.right",
                color: .green,
                isReadOnly: false,
                description: "This is what you actually type. But here's the clever part — the AI doesn't just see your latest message. It reads the whole conversation from the beginning every single time. That's how it remembers what you said three messages ago. The longer the chat, the more it has to re-read.",
                detail: "You:  \"What should I make for dinner?\"\nAI:   \"How about pasta?\"\nYou:  \"Something quicker.\"\n↑ The AI reads all three lines before replying."
            )
        case .response:
            return CompositionLayerConfig(
                title: "The Reply",
                icon: "sparkles",
                color: .purple,
                isReadOnly: true,
                description: "After reading the raw model's knowledge, the system prompt's instructions, and your message, the AI writes back — one word at a time, left to right, like someone typing. It can't go back and change earlier words. The result is shaped by everything above it.",
                detail: nil
            )
        }
    }
}

private struct CompositionNavigationCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Open the demo, edit the system prompt in a sheet, then send messages and inspect the composition layers.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            NavigationLink {
                CompositionLabView()
            } label: {
                Label("Open Composition Demo", systemImage: "slider.horizontal.3")
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

private struct CompositionLabView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(FoundationManager.self) private var manager

    @State private var systemPrompt = CompositionChatEngine.defaultSystemPrompt
    @State private var messages: [CompositionMessage] = []
    @State private var draftMessage = ""
    @State private var isResponding = false
    @State private var statusMessage: String?
    @State private var isPromptEditorPresented = false
    @State private var responseTask: Task<Void, Never>?
    @State private var scrollPosition = ScrollPosition()

    private var trimmedDraft: String {
        draftMessage.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        Group {
            if manager.isModelAvailable {
                VStack {
                    if messages.isEmpty {
                        labEmptyState
                    } else {
                        ScrollView {
                            ForEach(messages) { message in
                                HStack {
                                    if message.role == .user {
                                        LabChatBubble(message: message)
                                        Spacer(minLength: 50)
                                    } else {
                                        Spacer(minLength: 50)
                                        LabChatBubble(message: message)
                                    }
                                }
                            }
                            if isResponding {
                                HStack {
                                    Spacer(minLength: 50)
                                    ThinkingBubble()
                                }
                            }
                            if let err = statusMessage {
                                Text(err)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .scrollPosition($scrollPosition)
                    }

                    TextField("Ask away...", text: $draftMessage)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            if !trimmedDraft.isEmpty {
                                sendMessage()
                            }
                        }
                        .disabled(isResponding)
                }
                .padding()
            } else {
                IntelligenceUnavailableView()
            }
        }
        .navigationTitle("Composition Lab")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button("New Chat") {
                    resetConversation()
                }
                .disabled(messages.isEmpty || isResponding)
            }
            ToolbarSpacer(.fixed, placement: .automatic)
            ToolbarItem(placement: .automatic) {
                Button("Edit Prompt", systemImage: "pencil") {
                    isPromptEditorPresented = true
                }
                .disabled(isResponding)
            }
        }
        .sheet(isPresented: $isPromptEditorPresented) {
            CompositionSystemPromptSheet(prompt: $systemPrompt, isResponding: isResponding)
#if os(iOS)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
#endif
        }
        .onDisappear { responseTask?.cancel() }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active { manager.checkIsAvailable() }
        }
        .onChange(of: messages.count) { _, _ in
            withAnimation { scrollPosition.scrollTo(edge: .bottom) }
        }
    }

    private var labEmptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)

            Text("Send a message to see how the system prompt shapes the reply.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func sendMessage() {
        let input = trimmedDraft
        guard !input.isEmpty else { return }

        draftMessage = ""
        statusMessage = nil
        isResponding = true

        let userMessage = CompositionMessage(role: .user, text: input)
        messages.append(userMessage)
        let conversationSnapshot = messages
        let currentSystemPrompt = systemPrompt

        responseTask?.cancel()
        responseTask = Task {
            let result = await CompositionChatEngine.generateReply(
                systemPrompt: currentSystemPrompt,
                conversation: conversationSnapshot
            )
            if Task.isCancelled { return }
            await MainActor.run {
                isResponding = false
                switch result {
                case .success(let response):
                    let cleaned = manager.minimizeMarkDown(response).trimmingCharacters(in: .whitespacesAndNewlines)
                    if cleaned.isEmpty {
                        statusMessage = "The model returned an empty response."
                    } else {
                        messages.append(CompositionMessage(role: .assistant, text: cleaned))
                    }
                case .failure(let error):
                    statusMessage = error.localizedDescription
                }
            }
        }
    }

    private func resetConversation() {
        responseTask?.cancel()
        messages = []
        draftMessage = ""
        statusMessage = nil
        isResponding = false
    }
}

private struct LabChatBubble: View {
    let message: CompositionMessage
    private var isUser: Bool { message.role == .user }

    var body: some View {
        Text(message.text)
            .foregroundStyle(isUser ? Color.primary : Color.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isUser ? Color(.gray) : Color.accentColor)
            .clipShape(.rect(cornerRadius: 16))
            .frame(maxWidth: .infinity, alignment: isUser ? .leading : .trailing)
    }
}

private struct CompositionLayerCard: View {
    let title: String
    let bodyText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            Text(bodyText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.quinary)
        )
    }
}

private struct CompositionPanel<Content: View>: View {
    let title: String
    let footer: String
    let content: Content

    init(
        title: String,
        footer: String,
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

            Text(footer)
                .font(.footnote)
                .foregroundStyle(.secondary)
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

private struct CompositionSystemPromptSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var prompt: String
    let isResponding: Bool

    @State private var draftPrompt: String
    @State private var selectedPresetID: UUID? = nil

    init(prompt: Binding<String>, isResponding: Bool) {
        _prompt = prompt
        self.isResponding = isResponding
        let initialPrompt = prompt.wrappedValue
        _draftPrompt = State(initialValue: initialPrompt)
        _selectedPresetID = State(
            initialValue: SystemPromptPersona.all.first(where: { $0.prompt == initialPrompt })?.id
        )
    }

    private var selectedPreset: SystemPromptPersona? {
        guard let selectedPresetID else { return nil }
        return SystemPromptPersona.all.first(where: { $0.id == selectedPresetID })
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // Presets
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Presets")
                                .font(.headline.weight(.semibold))
                            Text("Tap a preset to preview it. Only Customize is editable.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        VStack(spacing: 10) {
                            Button {
                                withAnimation(.snappy(duration: 0.2)) {
                                    selectedPresetID = nil
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    Text("🛠️")
                                        .font(.title2)
                                        .frame(width: 36)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Customize")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(.primary)
                                        Text("Use your own instructions and edit them below.")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                    }

                                    Spacer()

                                    if selectedPresetID == nil {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(Color.accentColor)
                                            .font(.body)
                                    } else {
                                        Image(systemName: "circle")
                                            .foregroundStyle(.tertiary)
                                            .font(.body)
                                    }
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(
                                    selectedPresetID == nil
                                    ? Color.accentColor.opacity(0.10)
                                    : Color.secondary.opacity(0.06),
                                    in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                                )
                                .overlay {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .strokeBorder(
                                            selectedPresetID == nil
                                            ? Color.accentColor.opacity(0.35)
                                            : Color.clear,
                                            lineWidth: 1
                                        )
                                }
                            }
                            .buttonStyle(.plain)
                            .animation(.snappy(duration: 0.2), value: selectedPresetID)

                            ForEach(SystemPromptPersona.all) { persona in
                                Button {
                                    withAnimation(.snappy(duration: 0.2)) {
                                        selectedPresetID = persona.id
                                    }
                                } label: {
                                    HStack(spacing: 12) {
                                        Text(persona.emoji)
                                            .font(.title2)
                                            .frame(width: 36)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(persona.name)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(.primary)
                                            Text(persona.description)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                                .lineLimit(1)
                                        }

                                        Spacer()

                                        if selectedPresetID == persona.id {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(persona.tagColor)
                                                .font(.body)
                                        } else {
                                            Image(systemName: "circle")
                                                .foregroundStyle(.tertiary)
                                                .font(.body)
                                        }
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(
                                        selectedPresetID == persona.id
                                        ? persona.tagColor.opacity(0.08)
                                        : Color.secondary.opacity(0.06),
                                        in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    )
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .strokeBorder(
                                                selectedPresetID == persona.id
                                                ? persona.tagColor.opacity(0.35)
                                                : Color.clear,
                                                lineWidth: 1
                                            )
                                    }
                                }
                                .buttonStyle(.plain)
                                .animation(.snappy(duration: 0.2), value: selectedPresetID)
                            }
                        }
                    }

                    Divider()

                    // Custom editor
                    VStack(alignment: .leading, spacing: 10) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(selectedPreset == nil
                                 ? "Customize"
                                 : "Selected Preset: \(selectedPreset?.name ?? "")")
                                .font(.headline.weight(.semibold))
                            Text(selectedPreset == nil
                                 ? "Edit directly — this is exactly what the AI receives before you type anything."
                                 : "Preset prompts are read-only. Select Customize to make edits.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        if let preset = selectedPreset {
                            ScrollView {
                                Text(preset.prompt)
                                    .font(.system(.subheadline, design: .monospaced))
                                    .foregroundStyle(.primary)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(12)
                            }
                            .frame(minHeight: 180)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.secondary.opacity(0.07))
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(Color.secondary.opacity(0.15), lineWidth: 0.8)
                            }
                        } else {
                            TextEditor(text: $draftPrompt)
                                .font(.system(.subheadline, design: .monospaced))
                                .frame(minHeight: 180)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color.secondary.opacity(0.07))
                                )
                                .overlay {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .strokeBorder(Color.secondary.opacity(0.15), lineWidth: 0.8)
                                }

                            Button("Reset to default") {
                                withAnimation(.snappy(duration: 0.2)) {
                                    draftPrompt = CompositionChatEngine.defaultSystemPrompt
                                    selectedPresetID = nil
                                }
                            }
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("System Prompt")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        if let preset = selectedPreset {
                            prompt = preset.prompt
                        } else {
                            let trimmed = draftPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
                            prompt = trimmed.isEmpty ? CompositionChatEngine.defaultSystemPrompt : trimmed
                        }
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(isResponding)
                }
            }
        }
    }
}

private struct CompositionMessageRow: View {
    let message: CompositionMessage

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(message.role.title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(message.text)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.quinary)
        )
    }
}

private struct CompositionMessage: Identifiable, Hashable {
    let id = UUID()
    let role: CompositionRole
    let text: String
}

private enum CompositionRole: String, Hashable {
    case user
    case assistant

    var title: String {
        switch self {
        case .user:
            return "User"
        case .assistant:
            return "Assistant"
        }
    }
}

private enum CompositionChatEngine {
    static let defaultSystemPrompt = """
    You are a clear, beginner-friendly assistant.
    Explain technical ideas in plain language with short examples.
    Keep answers concise and practical.
    """

    static func generateReply(
        systemPrompt: String,
        conversation: [CompositionMessage]
    ) async -> Result<String, CompositionGenerationError> {
        guard !conversation.isEmpty else {
            return .failure(CompositionGenerationError("Conversation is empty."))
        }

        let transcriptText = conversation.enumerated().map { index, message in
            "\(index + 1). \(message.role.title): \(message.text)"
        }.joined(separator: "\n")

        let prompt = """
        CONVERSATION:
        \(transcriptText)

        Reply as Assistant to the final User message.
        Keep continuity with prior turns.
        """

        let instructions = Instructions {
            systemPrompt
        }
        let session = LanguageModelSession(instructions: instructions)

        do {
            let response = try await session.respond(to: prompt).content
            return .success(response)
        } catch let error as LanguageModelSession.GenerationError {
            return .failure(CompositionGenerationError(message(for: error)))
        } catch {
            return .failure(CompositionGenerationError(error.localizedDescription))
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

private struct CompositionGenerationError: LocalizedError {
    private let message: String

    init(_ message: String) {
        self.message = message
    }

    var errorDescription: String? {
        message
    }
}

// MARK: - The Stack

private struct CompositionSummary: View {
    private let layers: [(label: String, icon: String, color: Color, detail: String)] = [
        ("Safety Guardrails", "shield.checkered", .red, "Baked in — no system prompt can override them."),
        ("System Prompt", "gearshape", .cyan, "The most powerful tool for shaping AI behaviour in your app."),
        ("Conversation History", "bubble.left.and.bubble.right", .indigo, "Re-sent in full on every request — that's how context works."),
        ("Your Message", "text.cursor", .green, "The latest input the model responds to."),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("The Stack", systemImage: "square.stack.3d.up")
                .font(.headline)
                .foregroundStyle(.cyan)

            VStack(spacing: 0) {
                ForEach(Array(layers.enumerated()), id: \.element.label) { index, layer in
                    HStack(alignment: .center, spacing: 12) {
                        Image(systemName: layer.icon)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(layer.color)
                            .frame(width: 24, alignment: .center)

                        VStack(alignment: .leading, spacing: 1) {
                            Text(layer.label)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.primary)
                            Text(layer.detail)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)

                    if index < layers.count - 1 {
                        Divider().padding(.leading, 46)
                    }
                }
            }
            .padding(6)
            .background(.quinary, in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "globe")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.teal)
                Text("The same composition model applies to every text-based generative AI.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.teal.opacity(0.08), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        CompositionDemo()
            .environment(FoundationManager())
    }
}
