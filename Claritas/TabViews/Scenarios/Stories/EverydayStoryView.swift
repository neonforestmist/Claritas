import SwiftUI

struct HomeworkStoryView: View {
    let topSafeAreaInset: CGFloat

    private let card = ScenarioCard.sample(for: .homework)
    private let story = ScenarioStory.content(for: .homework)

    var body: some View {
        StoryNavigationRoot(card: card, story: story)
    }
}
