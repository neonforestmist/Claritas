import SwiftUI

// MARK: - Architecture Accent Color Environment Key

private struct ArchitectureAccentColorKey: EnvironmentKey {
    static let defaultValue: Color = .blue
}

extension EnvironmentValues {
    var architectureAccentColor: Color {
        get { self[ArchitectureAccentColorKey.self] }
        set { self[ArchitectureAccentColorKey.self] = newValue }
    }
}

struct ArchitectureListView: View {
    private let chapters = ArchitectureChapter.items

    var body: some View {
        NavigationStack {
            List {
                Text("You don't need to be an engineer to get this. Understanding the basics through these interactive examples helps demystify AI, making it easier to separate truth from hype.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)

                ForEach(chapters) { chapter in
                    ZStack(alignment: .leading) {
                        NavigationLink(value: chapter.destination) { EmptyView() }
                            .opacity(0)
                        ArchitectureChapterCard(chapter: chapter)
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 9, leading: 16, bottom: 9, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .navigationTitle("Architecture")
            .navigationDestination(for: ArchitectureChapterDestination.self) { destination in
                destination.view()
                    .tint(destination.accentColor)
                    .environment(\.architectureAccentColor, destination.accentColor)
            }
#if os(iOS)
            .navigationBarTitleDisplayMode(.large)
#endif
        }
    }
}

private struct ArchitectureChapter: Identifiable {
    let id: Int
    let title: String
    let summary: String
    let symbolName: String
    let destination: ArchitectureChapterDestination
}

private enum ArchitectureChapterDestination: Hashable {
    case tokenization
    case contextWindow
    case composition
    case prediction
    case neuralNetwork

    var accentColor: Color {
        switch self {
        case .tokenization:  return .green
        case .contextWindow: return .purple
        case .composition:   return .cyan
        case .prediction:    return .orange
        case .neuralNetwork: return .indigo
        }
    }

    @MainActor
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .tokenization:
            ArchitectureHandbookChapterPage(title: "Tokenization") {
                TokenizationDemo()
            }
        case .contextWindow:
            ArchitectureHandbookChapterPage(title: "Context Window") {
                ContextWindowDemo()
            }
        case .composition:
            ArchitectureHandbookChapterPage(title: "Composition") {
                CompositionDemo()
            }
        case .prediction:
            ArchitectureHandbookChapterPage(title: "Prediction") {
                PredictionDemo()
            }
        case .neuralNetwork:
            ArchitectureHandbookChapterPage(title: "Neural Network") {
                NeuralNetworkDemo()
            }
        }
    }
}

private struct ArchitectureHandbookChapterPage<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.largeTitle.weight(.bold))
                    .padding(.horizontal, 18)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                
                content
                    .padding(.horizontal, 18)
                    .padding(.top, 4)
                    .padding(.bottom, 28)
            }
        }
        .navigationTitle(title)
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
}

private extension ArchitectureChapter {
    static let items: [ArchitectureChapter] = [
        ArchitectureChapter(
            id: 1,
            title: "Neural Network",
            summary: "Peek inside the 'black box' of AI to see the massive scale of math at work. Learn to recognize the true strengths and inherent limits of these complex systems.",
            symbolName: "network",
            destination: .neuralNetwork
        ),
        ArchitectureChapter(
            id: 2,
            title: "Composition",
            summary: "Explore how AI models build their answers layer by layer.",
            symbolName: "square.stack.3d.up",
            destination: .composition
        ),
        ArchitectureChapter(
            id: 3,
            title: "Context Window",
            summary: "Understand the limits of an AI's memory during a conversation. Learn how to prioritize important information to keep the AI's responses accurate and relevant.",
            symbolName: "rectangle.compress.vertical",
            destination: .contextWindow
        ),
        ArchitectureChapter(
            id: 4,
            title: "Prediction",
            summary: "Learn how AI models generate text by predicting the most likely next word. Understand that they are guessing what comes next, not searching for objective truth.",
            symbolName: "dice",
            destination: .prediction
        ),
        ArchitectureChapter(
            id: 5,
            title: "Tokenization",
            summary: "Discover how AI models break down text into smaller pieces called tokens. Learn why even tiny changes in your wording can lead to completely different results.",
            symbolName: "text.word.spacing",
            destination: .tokenization
        )
    ]
}

private struct ArchitectureChapterCard: View {
    let chapter: ArchitectureChapter

    var body: some View {
        let tint = chapter.destination.accentColor

        ShelfNavigationCard(
            title: chapter.title,
            summary: chapter.summary,
            symbolName: chapter.symbolName,
            iconForeground: .white,
            iconBackground: tint
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(chapter.title). \(chapter.summary)")
    }
}

#Preview {
    ArchitectureListView()
        .environment(NavManager())
        .environment(FoundationManager())
}
