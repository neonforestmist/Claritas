import SwiftUI

struct EverydayStoryView: View {
    let topSafeAreaInset: CGFloat

    private let card = ScenarioCard.sample(for: .everyday)
    private let story = ScenarioStory.content(for: .everyday)

    var body: some View {
        StoryNavigationRoot(card: card, story: story)
    }
}
