import SwiftUI

// MARK: - Story Wrap-Up View

/// Final page shown after all beats are complete.
/// Shows the importanceHeadline, best moves, and watch-outs — all in the story's palette.
struct StoryWrapUpView: View {
    let story: ScenarioStory

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    private var palette: StoryPalette { story.palette }

    var body: some View {
        NavigationStack {
            ZStack {
                palette.background.ignoresSafeArea()

                WrapUpBackdrop(color: palette.ink)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer(minLength: 20)

                        Text("STORY COMPLETE")
                            .font(.caption2.weight(.bold))
                            .tracking(2.2)
                            .foregroundStyle(palette.ink.opacity(0.45))
                            .streamIn(appeared: appeared, delay: 0.0, reduceMotion: reduceMotion)

                        Spacer(minLength: 20)

                        Text("What to take away")
                            .font(.system(.title2, design: .serif).weight(.semibold))
                            .foregroundStyle(palette.ink)
                            .streamIn(appeared: appeared, delay: 0.10, reduceMotion: reduceMotion)

                        Spacer(minLength: 16)

                        Text(story.importanceHeadline)
                            .font(.system(.body, design: .serif))
                            .foregroundStyle(palette.ink.opacity(0.75))
                            .lineSpacing(6)
                            .fixedSize(horizontal: false, vertical: true)
                            .streamIn(appeared: appeared, delay: 0.18, reduceMotion: reduceMotion)

                        Spacer(minLength: 36)

                        // Best moves
                        WrapUpSection(
                            icon: "checkmark.circle",
                            title: "Best Moves",
                            items: story.bestUseMoves,
                            emojis: ["✅", "🎯", "💡", "🔁", "🛡️"],
                            palette: palette
                        )
                        .streamIn(appeared: appeared, delay: 0.28, reduceMotion: reduceMotion)

                        Spacer(minLength: 28)

                        // Watch outs
                        WrapUpSection(
                            icon: "exclamationmark.triangle",
                            title: "Watch Out For",
                            items: story.watchOuts,
                            emojis: ["⚠️", "🚫", "❌"],
                            palette: palette
                        )
                        .streamIn(appeared: appeared, delay: 0.40, reduceMotion: reduceMotion)

                        Spacer(minLength: 60)
                    }
                    .padding(.horizontal, 28)
                    .frame(maxWidth: 600, alignment: .leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .scrollIndicators(.hidden)
            }
#if os(macOS)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                HStack {
                    Spacer()
                    Button("Done") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.cancelAction)
                    .accessibilityLabel("Done")
                    .accessibilityHint("Closes the takeaways sheet")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
            }
#endif
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
#endif
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(story.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(palette.ink.opacity(0.7))
                }
#if os(iOS)
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundStyle(palette.ink)
                }
#endif
            }
        }
        .onAppear {
            appeared = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
                appeared = true
            }
        }
    }
}

// MARK: - Wrap-up Section

private struct WrapUpSection: View {
    let icon: String
    let title: String
    let items: [String]
    let emojis: [String]
    let palette: StoryPalette

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.ink.opacity(0.65))
                Text(title)
                    .font(.system(.headline, design: .serif).weight(.semibold))
                    .foregroundStyle(palette.ink)
            }

            VStack(spacing: 10) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    HStack(alignment: .top, spacing: 12) {
                        Text(emojis[index % emojis.count])
                            .font(.body)
                            .frame(width: 24)
                        Text(item)
                            .font(.system(.subheadline, design: .serif))
                            .foregroundStyle(palette.ink.opacity(0.85))
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        palette.ink.opacity(0.06),
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(palette.ink.opacity(0.10), lineWidth: 0.7)
                    }
                }
            }
        }
    }
}

// MARK: - Backdrop

private struct WrapUpBackdrop: View {
    let color: Color
    @State private var pulse = false

    private let decorations: [(Alignment, CGFloat, Double, CGFloat, CGFloat, Double)] = [
        (.topLeading,    48,  -15,  -10,  -14, 0.050),
        (.topTrailing,   28,   20,   14,  -10, 0.038),
        (.topTrailing,  140,   10,   44,   28, 0.048),
        (.leading,       32,  -28,   -8,   56, 0.032),
        (.center,        20,   42,   64,  -76, 0.028),
        (.bottomLeading, 36,   22,  -10,   12, 0.038),
        (.bottomTrailing,180,   8,   52,   52, 0.058),
        (.bottom,        22,  -18,   28,   18, 0.032),
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(Array(decorations.enumerated()), id: \.offset) { _, d in
                    let (alignment, size, rotation, ox, oy, baseOpacity) = d
                    Image(systemName: "checkmark.seal")
                        .font(.system(size: size, weight: .ultraLight))
                        .foregroundStyle(color.opacity(pulse ? baseOpacity * 1.3 : baseOpacity))
                        .rotationEffect(.degrees(rotation))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
                        .offset(x: ox, y: oy)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}
