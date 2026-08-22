import SwiftUI

struct WritingStoryView: View {
    let topSafeAreaInset: CGFloat

    private let card = ScenarioCard.sample(for: .writing)
    private let story = ScenarioStory.content(for: .writing)

    var body: some View {
        StoryNavigationRoot(card: card, story: story)
    }
}
