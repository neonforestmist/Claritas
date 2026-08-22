import SwiftUI

// MARK: - Story Intro Page

/// Full-screen landing page for a scenario story.
/// Uses the story's StoryPalette for its colour scheme.
/// The user reads the intro text, then taps "Begin" to enter the first beat.
struct ScenariosStoryScaffold: View {
    // topSafeAreaInset kept for API compatibility — not used in full-screen layout.
    var topSafeAreaInset: CGFloat = 0
    let card: ScenarioCard
    let story: ScenarioStory
    /// Shared with every beat view — used to track checkpoint history.
    @Binding var visitedBeatIDs: [String]
    let onClose: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    private var palette: StoryPalette { story.palette }

    var body: some View {
        ZStack {
            // ── Background ──────────────────────────────────────────────
            palette.background
                .ignoresSafeArea()

            // ── Decorative backdrop symbol ───────────────────────────────
            BackdropSymbol(
                name: palette.symbol,
                color: palette.ink
            )
            .ignoresSafeArea()

            // ── Content ─────────────────────────────────────────────────
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer(minLength: 60)

                    // Category label
                    Text(card.heroTitle.uppercased())
                        .font(.caption.weight(.bold))
                        .tracking(2.0)
                        .foregroundStyle(palette.ink.opacity(0.5))
                        .streamIn(appeared: appeared, delay: 0.05, reduceMotion: reduceMotion)

                    Spacer(minLength: 18)

                    // Title
                    Text(story.title)
                        .font(.system(size: 40, weight: .bold, design: .serif))
                        .foregroundStyle(palette.ink)
                        .fixedSize(horizontal: false, vertical: true)
                        .streamIn(appeared: appeared, delay: 0.15, reduceMotion: reduceMotion)

                    Spacer(minLength: 6)

                    // Subtitle
                    Text(story.subtitle)
                        .font(.system(.callout, design: .serif).weight(.medium))
                        .foregroundStyle(palette.ink.opacity(0.65))
                        .fixedSize(horizontal: false, vertical: true)
                        .streamIn(appeared: appeared, delay: 0.25, reduceMotion: reduceMotion)

                    Spacer(minLength: 32)

                    // Divider
                    Rectangle()
                        .fill(palette.ink.opacity(0.15))
                        .frame(height: 1)
                        .streamIn(appeared: appeared, delay: 0.35, reduceMotion: reduceMotion)

                    Spacer(minLength: 28)

                    // Intro paragraphs
                    Text(story.introText)
                        .font(.system(.body, design: .serif))
                        .foregroundStyle(palette.ink.opacity(0.88))
                        .lineSpacing(7)
                        .fixedSize(horizontal: false, vertical: true)
                        .streamIn(appeared: appeared, delay: 0.45, reduceMotion: reduceMotion)

                    Spacer(minLength: 48)

                    // Begin button — pushes into first beat via value-based navigation
                    if !story.beats.isEmpty {
                        NavigationLink(value: story.firstBeatID) {
                            HStack(spacing: 8) {
                                Text("Begin")
                                    .font(.body.weight(.semibold))
                                Image(systemName: "arrow.right")
                                    .font(.body.weight(.semibold))
                            }
                            .foregroundStyle(palette.background)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 16)
                            .background(palette.ink, in: Capsule())
                        }
                        .buttonStyle(.plain)
                        .streamIn(appeared: appeared, delay: 0.60, reduceMotion: reduceMotion)
                    }

                    Spacer(minLength: 60)
                }
                .padding(.horizontal, 28)
                .frame(maxWidth: 600, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollIndicators(.hidden)
        }
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(story.title)
                    .font(.headline)
                    .foregroundStyle(palette.ink)
                    .opacity(0)   // hidden — title is in the body
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
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                appeared = true
            }
        }
    }
}

// MARK: - Backdrop Symbol

private struct BackdropSymbol: View {
    let name: String
    let color: Color

    @State private var pulse = false

    var body: some View {
        GeometryReader { geo in
            Image(systemName: name)
                .font(.system(size: min(geo.size.width, geo.size.height) * 0.75, weight: .ultraLight))
                .foregroundStyle(color.opacity(pulse ? 0.07 : 0.04))
                .symbolEffect(.variableColor.cumulative.dimInactiveLayers.reversing, value: pulse)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .offset(x: 60, y: 60)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

// streamIn modifier is defined in StoryBeatView.swift and shared across story views.
