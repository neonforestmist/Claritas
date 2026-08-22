import SwiftUI

private enum ScenariosLayout {
    static let horizontalPadding: CGFloat = 16
    static let verticalPadding: CGFloat = 12
    static let gridSpacing: CGFloat = 14
    static let cardCornerRadius: CGFloat = 20
    static let heroHeight: CGFloat = 150
    static let maxContentWidth: CGFloat = 980
    static let minCardWidth: CGFloat = 320
    static let maxCardWidth: CGFloat = 420
}

struct Scenarios: View {
    @Environment(NavManager.self) var navManager
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private let cards = ScenarioCard.samples

    /// The destination currently being presented full-screen.
    @State private var activeDestination: ScenarioDestination?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Pick a story and see how different scenarios and AI choices lead to different outcomes, tradeoffs, and results.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)

                    LazyVGrid(
                        columns: cardColumns,
                        spacing: ScenariosLayout.gridSpacing
                    ) {
                        ForEach(cards) { card in
                            Button {
                                activeDestination = card.destination
                            } label: {
                                ScenarioEditorialCard(card: card)
                            }
                            .buttonStyle(ScenarioCardPressStyle())
                        }
                    }
                    .padding(.horizontal, ScenariosLayout.horizontalPadding)
                    .padding(.vertical, ScenariosLayout.verticalPadding)
                    .frame(maxWidth: ScenariosLayout.maxContentWidth)
                    .frame(maxWidth: .infinity)
                }
                .padding(.vertical)
            }
            .navigationTitle(navManager.selectedTab.rawValue)
#if os(iOS)
            .navigationBarTitleDisplayMode(.large)
#endif
        }
#if os(macOS)
        .sheet(item: $activeDestination) { destination in
            let card = ScenarioCard.sample(for: destination)
            let story = ScenarioStory.content(for: destination)
            StoryNavigationRoot(card: card, story: story)
        }
#else
        // Full-screen cover — hides tab bar, presents the entire story experience
        .fullScreenCover(item: $activeDestination) { destination in
            let card = ScenarioCard.sample(for: destination)
            let story = ScenarioStory.content(for: destination)
            StoryNavigationRoot(card: card, story: story)
        }
#endif
    }

    private var cardColumns: [GridItem] {
#if os(iOS)
        if horizontalSizeClass == .regular {
            return [
                GridItem(
                    .adaptive(
                        minimum: ScenariosLayout.minCardWidth,
                        maximum: ScenariosLayout.maxCardWidth
                    ),
                    spacing: ScenariosLayout.gridSpacing
                )
            ]
        }
        return [GridItem(.flexible(), spacing: ScenariosLayout.gridSpacing)]
#else
        return [
            GridItem(
                .adaptive(
                    minimum: ScenariosLayout.minCardWidth,
                    maximum: ScenariosLayout.maxCardWidth
                ),
                spacing: ScenariosLayout.gridSpacing
            )
        ]
#endif
    }
}

// MARK: - Story Navigation Root
//
// Wraps the story experience in a NavigationStack so that beat-to-beat
// pushes work correctly inside the fullScreenCover. The dismiss button
// lives here so it's always reachable from anywhere in the stack.

struct StoryNavigationRoot: View {
    let card: ScenarioCard
    let story: ScenarioStory

    @Environment(\.dismiss) private var dismiss

    /// Tracks which beat IDs the user has actually visited (checkpoints).
    @State private var visitedBeatIDs: [String] = []
    @State private var navigationPath: [String] = []

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScenariosStoryScaffold(
                card: card,
                story: story,
                visitedBeatIDs: $visitedBeatIDs,
                onClose: { dismiss() }
            )
            // Beat-to-beat navigation driven by String (beatID)
            .navigationDestination(for: String.self) { beatID in
                StoryBeatView(
                    story: story,
                    beatID: beatID,
                    visitedBeatIDs: $visitedBeatIDs,
                    navigationPath: $navigationPath,
                    onClose: { dismiss() }
                )
            }
        }
    }
}

// MARK: - Editorial Card

private struct ScenarioEditorialCard: View {
    let card: ScenarioCard

    var body: some View {
        VStack(spacing: 0) {
            MeshGradient(
                width: 3,
                height: 3,
                points: card.points,
                colors: card.colors
            )
            .frame(height: ScenariosLayout.heroHeight)
            .overlay(
                LinearGradient(
                    colors: [.clear, .black.opacity(0.30)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(alignment: .topLeading) {
                MeshHeroBadge(
                    title: card.heroTitle,
                    symbolName: card.heroSymbolName
                )
                .padding(.leading, 16)
                .padding(.top, 12)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top, spacing: 10) {
                    Text(card.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(.tertiary)
                        .padding(.top, 2)
                }

                Text(card.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: ScenariosLayout.cardCornerRadius, style: .continuous)
                .fill(.regularMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: ScenariosLayout.cardCornerRadius, style: .continuous)
                .stroke(.separator.opacity(0.24), lineWidth: 0.6)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: ScenariosLayout.cardCornerRadius,
                style: .continuous
            )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(card.title). \(card.subtitle)")
        .accessibilityAddTraits(.isButton)
    }
}

private struct ScenarioCardPressStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .brightness(configuration.isPressed ? -0.02 : 0)
            .animation(
                reduceMotion
                ? .easeInOut(duration: 0.12)
                : .spring(response: 0.25, dampingFraction: 0.82),
                value: configuration.isPressed
            )
    }
}

private struct MeshHeroBadge: View {
    let title: String
    let symbolName: String

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: symbolName)
                .font(.subheadline.weight(.semibold))
                .imageScale(.medium)

            Text(title)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(.black.opacity(0.22), in: Capsule())
    }
}

#Preview {
    Scenarios()
        .environment(NavManager())
        .environment(FoundationManager())
}
