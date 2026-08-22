import SwiftUI

struct OnboardingView: View {
    private struct ConversationMessage: Identifiable {
        let id: Int
        let emoji: String
        let name: String
        let text: String
        let isRight: Bool
    }

    @State private var selectedPage = 0
    let onFinish: () -> Void

    private let conversation: [ConversationMessage] = [
        .init(id: 0, emoji: "👨", name: "Alan", text: "Ugh, this AI stuff is so frustrating. It never gives me what I actually want, and everyone's saying it's going to take all our jobs anyway.", isRight: false),
        .init(id: 1, emoji: "🧑", name: "Lukas", text: "I used to think the same thing! But it's actually not like that at all once you understand how it works.", isRight: true),
        .init(id: 2, emoji: "🧑", name: "Lukas", text: "You should check out this app called Claritas. It explains everything really well.", isRight: true),
        .init(id: 3, emoji: "👨", name: "Alan", text: "I don't know... I really don't want to read some boring textbook or sit through a lecture about algorithms.", isRight: false),
        .init(id: 4, emoji: "🧑", name: "Lukas", text: "It's not a textbook at all! It has these really fun interactive examples you can play with, and great stories that explain things simply. You should definitely try it!", isRight: true)
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                chatScene
                Spacer(minLength: 2)
                HStack(spacing: 20) {
                    Button {
                        goToPreviousPage()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                            Text("Previous")
                        }
                        .font(.headline.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glass)
                    .buttonBorderShape(.capsule)
                    .controlSize(.large)
                    .disabled(selectedPage == 0)
                    .opacity(selectedPage == 0 ? 0.45 : 1.0)

                    Button {
                        goToNextPageOrFinish()
                    } label: {
                        HStack(spacing: 8) {
                            Text(nextButtonTitle)
                            Image(systemName: nextButtonSymbol)
                        }
                        .font(.headline.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                    .buttonBorderShape(.capsule)
                    .controlSize(.large)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            .padding(.top, 6)
            .navigationTitle("Scene (\(selectedPage + 1)/\(totalPages))")
#if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
#if os(macOS)
                ToolbarItem(placement: .automatic) {
                    skipButton
                }
#else
                ToolbarItem(placement: .navigationBarTrailing) {
                    skipButton
                }
#endif
            }
        }
    }

    private var totalPages: Int {
        conversation.count
    }

    private var isLastPage: Bool {
        selectedPage == totalPages - 1
    }

    private var nextButtonTitle: String {
        isLastPage ? "Get Started" : "Next"
    }

    private var nextButtonSymbol: String {
        isLastPage ? "checkmark" : "chevron.right"
    }

    private var skipButton: some View {
        Button {
            onFinish()
        } label: {
            HStack(spacing: 4) {
                Text("Skip")
                Image(systemName: "forward.fill")
            }
            .font(.subheadline.weight(.semibold))
        }
        .buttonStyle(.plain)
        .buttonBorderShape(.capsule)
        .padding(12)
        .foregroundStyle(.primary)
    }

    private var chatScene: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(conversation.prefix(selectedPage + 1)) { message in
                        chatRow(for: message)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .bottom)),
                                removal: .opacity
                            ))
                            .id(message.id)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onChange(of: selectedPage) { _, newIndex in
                withAnimation(.smooth(duration: 0.3)) {
                    proxy.scrollTo(newIndex, anchor: .bottom)
                }
            }
        }
    }

    @ViewBuilder
    private func chatRow(for message: ConversationMessage) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isRight {
                Spacer(minLength: 56)
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 6)
                    ChatBubble(text: message.text, isAgent: false)
                }
                avatarView(emoji: message.emoji, name: message.name)
            } else {
                avatarView(emoji: message.emoji, name: message.name)
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 6)
                    ChatBubble(text: message.text, isAgent: true)
                }
                Spacer(minLength: 56)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(message.name): \(message.text)")
    }

    private func avatarView(emoji: String, name: String) -> some View {
        Text(emoji)
            .font(.system(size: 26))
            .frame(width: 40, height: 40)
            .glassEffect(in: Circle())
            .accessibilityHidden(true)
    }

    private func goToNextPageOrFinish() {
        if isLastPage {
            onFinish()
            return
        }

        withAnimation(.smooth(duration: 0.25)) {
            selectedPage += 1
        }
    }

    private func goToPreviousPage() {
        guard selectedPage > 0 else { return }

        withAnimation(.smooth(duration: 0.22)) {
            selectedPage -= 1
        }
    }
}

#Preview {
    OnboardingView { }
}
