import SwiftUI

// MARK: - Story Beat View

struct StoryBeatView: View {
    let story: ScenarioStory
    let beatID: String
    /// Shared array of beat IDs the user has actually reached — used for the checkpoint navigator.
    @Binding var visitedBeatIDs: [String]
    @Binding var navigationPath: [String]
    let onClose: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false
    @State private var promptCopied = false
    @State private var showPageNav = false
    @State private var showTakeaways = false

    private var palette: StoryPalette { story.palette }
    private var beat: ScenarioBeat { story.beat(id: beatID) }
    private var pageNumber: Int { story.pageNumber(for: beatID) }
    private var totalPages: Int { story.beats.count }
    private var isLast: Bool { beat.choices.isEmpty }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Full-screen background
            palette.background.ignoresSafeArea()

            // Scattered decorative SF symbols
            ScatteredBackdrop(symbol: beatSymbol, palette: palette)
                .ignoresSafeArea()

            // Main scrollable content
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer(minLength: 24)

                    beatHeader

                    Spacer(minLength: 26)

                    storyProse

                    // Inline chat exchange — shows AI in action mid-story
                    if !beat.inlineChat.isEmpty {
                        Spacer(minLength: 24)
                        inlineChatBlock
                    }

                    // Continuation prose rendered after the chat block
                    if let continuation = beat.storyAfterChat, !continuation.isEmpty {
                        Spacer(minLength: 20)
                        storyAfterChatProse(continuation)
                    }

                    // To-do / plan list (Joe's planning beats)
                    if !beat.todoItems.isEmpty {
                        Spacer(minLength: 16)
                        todoListBlock
                    }

                    Spacer(minLength: 30)

                    thinDivider

                    Spacer(minLength: 26)

                    aiMoveBlock

                    // Prompt block — hidden when nil
                    if let prompt = beat.promptToTry {
                        Spacer(minLength: 16)
                        BeatPrompt(
                            text: prompt,
                            label: beat.isPromptRecommended ? "PROMPT TO TRY" : "PROMPT TRIED",
                            isCopied: promptCopied,
                            palette: palette,
                            onCopy: copyPrompt
                        )
                        .streamIn(appeared: appeared, delay: 0.50, reduceMotion: reduceMotion)
                    }

                    Spacer(minLength: 44)

                    if isLast {
                        finalEndButton
                    } else {
                        choiceButtons
                    }

                    // Extra bottom padding so content clears the floating buttons
                    Spacer(minLength: 110)
                }
                .padding(.horizontal, 26)
                .frame(maxWidth: 600, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollIndicators(.hidden)

            // Floating bottom-right controls
            floatingControls
        }
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(story.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.ink.opacity(0.65))
            }
#if os(iOS)
            ToolbarItem(placement: .primaryAction) {
                Button(role: .cancel, action: onClose) {
                    Image(systemName: "xmark")
                }
                .accessibilityLabel("Close story")
            }
#endif
        }
#if os(macOS)
        .overlay(alignment: .topTrailing) {
            Button("Done", action: onClose)
                .font(.callout.weight(.semibold))
                .foregroundStyle(.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.regularMaterial, in: Capsule())
                .overlay {
                    Capsule().strokeBorder(.primary.opacity(0.16), lineWidth: 0.6)
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.cancelAction)
                .accessibilityLabel("Close story")
                .padding(.top, 12)
                .padding(.trailing, 16)
        }
#endif
        .sheet(isPresented: $showTakeaways) {
            StoryWrapUpView(story: story)
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showPageNav) {
            CheckpointNavigatorSheet(
                story: story,
                currentBeatID: beatID,
                visitedBeatIDs: visitedBeatIDs,
                onSelectBeat: navigateToVisitedBeat
            )
#if os(macOS)
            .frame(minWidth: 560, minHeight: 500)
#endif
        }
#if os(iOS)
        .background {
            InteractivePopGestureDisabler()
                .frame(width: 0, height: 0)
        }
#endif
        .onAppear {
            // Mark this beat as visited (checkpoint)
            if !visitedBeatIDs.contains(beatID) {
                visitedBeatIDs.append(beatID)
            }
            appeared = false
            promptCopied = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
                appeared = true
            }
        }
    }

    // MARK: Subviews

    private var pageCounterLabel: some View {
        Text("PAGE \(pageNumber) OF \(totalPages)")
            .font(.caption2.weight(.bold))
            .tracking(2.4)
            .foregroundStyle(palette.ink.opacity(0.40))
            .streamIn(appeared: appeared, delay: 0.0, reduceMotion: reduceMotion)
    }

    private var beatHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(beat.emoji)
                .font(.system(size: 44))
                .accessibilityHidden(true)
                .streamIn(appeared: appeared, delay: 0.08, reduceMotion: reduceMotion)

            Text(beat.title)
                .font(.system(.title, design: .serif).weight(.semibold))
                .foregroundStyle(palette.ink)
                .fixedSize(horizontal: false, vertical: true)
                .streamIn(appeared: appeared, delay: 0.13, reduceMotion: reduceMotion)
        }
    }

    private var storyProse: some View {
        Text(beat.story)
            .font(.system(.body, design: .serif))
            .foregroundStyle(palette.ink.opacity(0.90))
            .lineSpacing(7)
            .fixedSize(horizontal: false, vertical: true)
            .streamIn(appeared: appeared, delay: 0.22, reduceMotion: reduceMotion)
    }

    private func storyAfterChatProse(_ text: String) -> some View {
        Text(text)
            .font(.system(.body, design: .serif))
            .foregroundStyle(palette.ink.opacity(0.90))
            .lineSpacing(7)
            .fixedSize(horizontal: false, vertical: true)
            .streamIn(appeared: appeared, delay: 0.34, reduceMotion: reduceMotion)
    }

    private var thinDivider: some View {
        Rectangle()
            .fill(palette.ink.opacity(0.11))
            .frame(height: 1)
            .streamIn(appeared: appeared, delay: 0.28, reduceMotion: reduceMotion)
    }

    private var aiMoveBlock: some View {
        BeatCallout(
            sfIcon: "sparkles",
            label: "WHAT HAPPENED",
            text: beat.aiMove,
            palette: palette
        )
        .streamIn(appeared: appeared, delay: 0.36, reduceMotion: reduceMotion)
    }

    // MARK: Inline rich content

    /// Palette-aware chat exchange shown between prose and callouts.
    private var inlineChatBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "bubble.left.and.bubble.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(palette.ink.opacity(0.40))
                Text("CHAT WITH AI")
                    .font(.caption2.weight(.bold))
                    .tracking(1.8)
                    .foregroundStyle(palette.ink.opacity(0.40))
            }
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(beat.inlineChat.enumerated()), id: \.offset) { _, line in
                    StoryChatBubble(line: line, palette: palette)
                }
            }
        }
        .streamIn(appeared: appeared, delay: 0.28, reduceMotion: reduceMotion)
    }

    /// Checklist card — used for Joe's AI-suggested daily plan.
    private var todoListBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "checklist")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(palette.ink.opacity(0.40))
                Text("TODAY'S PLAN")
                    .font(.caption2.weight(.bold))
                    .tracking(1.8)
                    .foregroundStyle(palette.ink.opacity(0.40))
            }
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(beat.todoItems.enumerated()), id: \.offset) { _, item in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "circle")
                            .font(.system(size: 13, weight: .light))
                            .foregroundStyle(palette.ink.opacity(0.35))
                            .padding(.top, 2)
                        Text(item)
                            .font(.system(.subheadline))
                            .foregroundStyle(palette.ink.opacity(0.85))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(palette.ink.opacity(0.07), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(palette.ink.opacity(0.12), lineWidth: 0.8)
            }
        }
        .streamIn(appeared: appeared, delay: 0.34, reduceMotion: reduceMotion)
    }

    // MARK: Goosebumps-style choices

    private var choiceButtons: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            HStack(spacing: 6) {
                Rectangle()
                    .fill(palette.ink.opacity(0.20))
                    .frame(width: 3, height: 14)
                    .clipShape(Capsule())
                Text("WHAT DO YOU DO?")
                    .font(.caption.weight(.bold))
                    .tracking(1.8)
                    .foregroundStyle(palette.ink.opacity(0.45))
            }

            VStack(spacing: 10) {
                ForEach(Array(beat.choices.enumerated()), id: \.offset) { index, choice in
                    // Value-based NavigationLink — reliably pushes via the
                    // .navigationDestination(for: String.self) registered in StoryNavigationRoot.
                    NavigationLink(value: choice.targetBeatID) {
                        GoosebumpsChoiceRow(
                            prompt: choice.prompt,
                            pageNumber: story.pageNumber(for: choice.targetBeatID),
                            choiceIndex: index,
                            palette: palette
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .streamIn(appeared: appeared, delay: 0.62, reduceMotion: reduceMotion)
    }

    private var finalEndButton: some View {
        VStack(alignment: .leading, spacing: 16) {
            Rectangle()
                .fill(palette.ink.opacity(0.11))
                .frame(height: 1)

            HStack(spacing: 8) {
                Image(systemName: "flag.checkered")
                    .font(.callout)
                    .foregroundStyle(palette.ink.opacity(0.50))
                Text("You've reached the end of this story.")
                    .font(.system(.callout, design: .serif))
                    .foregroundStyle(palette.ink.opacity(0.55))
            }

            Button {
                showTakeaways = true
            } label: {
                HStack(spacing: 8) {
                    Text("See What to Take Away")
                        .font(.body.weight(.semibold))
                    Image(systemName: "checkmark.seal")
                        .font(.body.weight(.semibold))
                }
                .foregroundStyle(palette.background)
                .padding(.horizontal, 24)
                .padding(.vertical, 15)
                .background(palette.ink, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .streamIn(appeared: appeared, delay: 0.62, reduceMotion: reduceMotion)
    }

    // MARK: Floating controls

    private var floatingControls: some View {
        Button {
            showPageNav = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "list.bullet.rectangle.portrait")
                    .font(.system(size: 18, weight: .semibold))
                Text("Pages")
                    .font(.callout.weight(.semibold))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(minWidth: 96, minHeight: 56)
            .foregroundStyle(.primary)
            .background(.regularMaterial, in: Capsule())
            .overlay {
                Capsule().strokeBorder(.primary.opacity(0.16), lineWidth: 0.7)
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open checkpoints")
        .accessibilityHint("Shows visited pages")
#if os(macOS)
        // Keep clear of the bottom-right resize area for reliable clicks.
        .padding(.trailing, 28)
        .padding(.bottom, 28)
#else
        .padding(.trailing, 20)
        .padding(.bottom, 40)
#endif
    }

    // MARK: Helpers

    /// Uses the story's own palette symbol so the backdrop is always
    /// thematically matched — dogs for Alan, sun for Joe, pencil for Sam.
    private var beatSymbol: String { palette.symbol }

    private func copyPrompt() {
        guard let prompt = beat.promptToTry else { return }
#if os(iOS)
        UIPasteboard.general.string = prompt
#elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(prompt, forType: .string)
#endif
        withAnimation(.snappy(duration: 0.22)) { promptCopied = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.snappy(duration: 0.22)) { promptCopied = false }
        }
    }

    private func navigateToVisitedBeat(_ targetBeatID: String) {
        guard targetBeatID != beatID else { return }

        if let existingIndex = navigationPath.firstIndex(of: targetBeatID) {
            navigationPath = Array(navigationPath.prefix(existingIndex + 1))
            return
        }

        navigationPath = [targetBeatID]
    }
}

// MARK: - Story Chat Bubble

/// A single palette-aware chat bubble used in inline story exchanges.
private struct StoryChatBubble: View {
    let line: ChatLine
    let palette: StoryPalette

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if line.isUser { Spacer(minLength: 48) }

            Text(line.text)
                .font(.system(.subheadline))
                .foregroundStyle(line.isUser ? palette.background : palette.ink.opacity(0.90))
                .lineSpacing(4)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    line.isUser
                        ? palette.ink.opacity(0.88)
                        : palette.ink.opacity(0.10),
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                )
                .overlay {
                    if !line.isUser {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(palette.ink.opacity(0.14), lineWidth: 0.7)
                    }
                }

            if !line.isUser { Spacer(minLength: 48) }
        }
        .frame(maxWidth: .infinity, alignment: line.isUser ? .trailing : .leading)
    }
}

// MARK: - Scattered Backdrop

/// Multiple SF Symbol instances scattered across the screen at different sizes,
/// rotations, and positions — like stars or decorative watermarks.
private struct ScatteredBackdrop: View {
    let symbol: String
    let palette: StoryPalette

    @State private var pulse = false

    // Each decoration: (alignment, size, rotation-deg, offset-x, offset-y, base-opacity)
    private let decorations: [(Alignment, CGFloat, Double, CGFloat, CGFloat, Double)] = [
        (.topLeading,    52,  -18,  -14,  -18, 0.055),
        (.topTrailing,   30,   22,   18,  -12, 0.040),
        (.topTrailing,  160,   12,   50,   30, 0.050),
        (.leading,       36,  -30,  -10,   60, 0.035),
        (.center,        22,   45,   70,  -80, 0.030),
        (.trailing,      28,  -10,  -16,  -40, 0.030),
        (.bottomLeading, 38,   25,  -12,   14, 0.040),
        (.bottomTrailing,200,  10,   55,   55, 0.060),  // large one bottom-right
        (.bottom,        24,  -20,   30,   20, 0.035),
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(Array(decorations.enumerated()), id: \.offset) { _, d in
                    let (alignment, size, rotation, ox, oy, baseOpacity) = d
                    Image(systemName: symbol)
                        .font(.system(size: size, weight: .ultraLight))
                        .foregroundStyle(
                            palette.ink.opacity(
                                pulse
                                    ? baseOpacity * 1.35
                                    : baseOpacity
                            )
                        )
                        .rotationEffect(.degrees(rotation))
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: alignment
                        )
                        .offset(x: ox, y: oy)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 3.2).repeatForever(autoreverses: true)
            ) {
                pulse = true
            }
        }
    }
}

// MARK: - Goosebumps Choice Row

private struct GoosebumpsChoiceRow: View {
    let prompt: String
    let pageNumber: Int
    let choiceIndex: Int
    let palette: StoryPalette

    /// Letter label — A, B, C…
    private var choiceLetter: String {
        let letters = ["A", "B", "C", "D"]
        return letters[safe: choiceIndex] ?? "\(choiceIndex + 1)"
    }

    var body: some View {
        HStack(alignment: .center, spacing: 14) {

            // Choice letter badge
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(palette.ink.opacity(0.12))
                    .frame(width: 34, height: 34)
                Text(choiceLetter)
                    .font(.system(.subheadline, design: .monospaced).weight(.bold))
                    .foregroundStyle(palette.ink.opacity(0.65))
            }

            // Prompt text + page label
            VStack(alignment: .leading, spacing: 3) {
                Text(prompt)
                    .font(.system(.subheadline, design: .serif))
                    .foregroundStyle(palette.ink.opacity(0.90))
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)

                Text("Turn to page \(pageNumber)")
                    .font(.caption.weight(.semibold))
                    .tracking(0.2)
                    .foregroundStyle(palette.ink.opacity(0.40))
            }

            Spacer(minLength: 8)

            // Arrow indicator
            ZStack {
                Circle()
                    .fill(palette.ink.opacity(0.12))
                    .frame(width: 32, height: 32)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(palette.ink.opacity(0.55))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(palette.ink.opacity(0.07), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(palette.ink.opacity(0.18), lineWidth: 1.0)
        }
        // Press state is handled by .buttonStyle(.plain) on the NavigationLink above
    }
}

// MARK: - Checkpoint Navigator Sheet

/// Shows only the beats the user has actually visited — their story path.
/// Uses standard list styling for readability and predictable navigation.
private struct CheckpointNavigatorSheet: View {
    let story: ScenarioStory
    let currentBeatID: String
    let visitedBeatIDs: [String]
    let onSelectBeat: (String) -> Void

    @Environment(\.dismiss) private var dismiss

    /// Only the beats the user has visited, in story order.
    private var checkpoints: [ScenarioBeat] {
        story.beats.filter { visitedBeatIDs.contains($0.id) }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(checkpoints) { beat in
                        if beat.id == currentBeatID {
                            CheckpointRow(
                                beat: beat,
                                pageNumber: story.pageNumber(for: beat.id),
                                isCurrent: true
                            )
                            .accessibilityHint("Current page")
                        } else {
                            Button {
                                onSelectBeat(beat.id)
                                dismiss()
                            } label: {
                                CheckpointRow(
                                    beat: beat,
                                    pageNumber: story.pageNumber(for: beat.id),
                                    isCurrent: false
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityHint("Double tap to go back to this page")
                        }
                    }
                } header: {
                    Text("Visited Pages")
                        .font(.headline)
                } footer: {
                    Text("Tap any page above to go back. Only pages you've visited are shown.")
                        .font(.footnote)
                        .foregroundStyle(.primary.opacity(0.68))
                }
            }
#if os(macOS)
            .listStyle(.inset)
#else
            .listStyle(.insetGrouped)
#endif
            .navigationTitle("Checkpoints")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("Close checkpoints")
                    .buttonStyle(.plain)
                }
#endif
            }
        }
#if os(macOS)
        .overlay(alignment: .topTrailing) {
            Button("Done") {
                dismiss()
            }
            .font(.callout.weight(.semibold))
            .foregroundStyle(.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.regularMaterial, in: Capsule())
            .overlay {
                Capsule().strokeBorder(.primary.opacity(0.16), lineWidth: 0.6)
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.cancelAction)
            .accessibilityLabel("Close checkpoints")
            .padding(.top, 12)
            .padding(.trailing, 16)
        }
#endif
#if os(macOS)
        .frame(minWidth: 560, minHeight: 500)
#endif
#if os(iOS)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
#endif
    }
}

// MARK: - Checkpoint Row

private struct CheckpointRow: View {
    let beat: ScenarioBeat
    let pageNumber: Int
    let isCurrent: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(beat.emoji)
                .font(.title3)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(beat.title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    private var subtitle: String {
        if isCurrent {
            return "Page \(pageNumber) • Current page selected"
        }
        return "Page \(pageNumber)"
    }

    private var accessibilityLabel: String {
        if isCurrent {
            return "Page \(pageNumber), \(beat.title), current page selected"
        }
        return "Page \(pageNumber), \(beat.title)"
    }
}

// MARK: - Callout Block

private struct BeatCallout: View {
    let sfIcon: String
    let label: String
    let text: String
    let palette: StoryPalette

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 7) {
                Image(systemName: sfIcon)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(palette.background)
                    .padding(5)
                    .background(palette.ink.opacity(0.80), in: Circle())
                    .accessibilityHidden(true)

                Text(label)
                    .font(.caption.weight(.bold))
                    .tracking(1.0)
                    .foregroundStyle(palette.ink.opacity(0.48))
            }

            Text(text)
                .font(.system(.callout, design: .serif))
                .foregroundStyle(palette.ink.opacity(0.80))
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(palette.ink.opacity(0.07), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(palette.ink.opacity(0.11), lineWidth: 0.8)
        }
    }
}

// MARK: - Prompt Block

private struct BeatPrompt: View {
    let text: String
    let label: String
    let isCopied: Bool
    let palette: StoryPalette
    let onCopy: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 7) {
                Image(systemName: "text.quote")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(palette.background)
                    .padding(5)
                    .background(palette.ink.opacity(0.80), in: Circle())
                    .accessibilityHidden(true)

                Text(label)
                    .font(.caption.weight(.bold))
                    .tracking(1.0)
                    .foregroundStyle(palette.ink.opacity(0.48))

                Spacer()

                Button(action: onCopy) {
                    HStack(spacing: 4) {
                        Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                        Text(isCopied ? "Copied" : "Copy")
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(palette.ink.opacity(isCopied ? 0.45 : 0.70))
                }
                .buttonStyle(.plain)
            }

            Text(text)
                .font(.system(.subheadline, design: .monospaced))
                .foregroundStyle(palette.ink.opacity(0.85))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(palette.ink.opacity(0.07), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(palette.ink.opacity(0.11), lineWidth: 0.8)
        }
    }
}

// MARK: - Stream-in modifier (shared across story views)

struct StreamInModifier: ViewModifier {
    let appeared: Bool
    let delay: Double
    let reduceMotion: Bool

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: (appeared || reduceMotion) ? 0 : 16)
            .animation(
                reduceMotion
                    ? .easeIn(duration: 0.1).delay(delay * 0.3)
                    : .spring(response: 0.52, dampingFraction: 0.80).delay(delay),
                value: appeared
            )
    }
}

extension View {
    func streamIn(appeared: Bool, delay: Double, reduceMotion: Bool) -> some View {
        modifier(StreamInModifier(appeared: appeared, delay: delay, reduceMotion: reduceMotion))
    }
}

#if os(iOS)
private struct InteractivePopGestureDisabler: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> PopGestureController {
        PopGestureController()
    }

    func updateUIViewController(_ uiViewController: PopGestureController, context: Context) {}
}

private final class PopGestureController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
}
#endif

// MARK: - Safe array subscript helper

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
