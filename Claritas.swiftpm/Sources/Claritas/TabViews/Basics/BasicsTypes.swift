import SwiftUI

// MARK: - Environment key for per-page accent colour

struct BasicsAccentColorKey: EnvironmentKey {
    static let defaultValue: Color = .blue
}

extension EnvironmentValues {
    var basicsAccentColor: Color {
        get { self[BasicsAccentColorKey.self] }
        set { self[BasicsAccentColorKey.self] = newValue }
    }
}

// MARK: -

enum BasicsDestination: Hashable {
    case whatIsAI
    case aiTypes
    case promptEngineeringBasics
    case promptWorkshop
    case limitations
    case myths
    case dangersBasics
    case vendingMachine

    var accentColor: Color {
        switch self {
        case .whatIsAI:               return .teal
        case .myths:                  return .brown
        case .aiTypes:                return .indigo
        case .promptEngineeringBasics: return .green
        case .limitations:            return .yellow
        case .dangersBasics:          return .red
        default:                      return .blue
        }
    }

    @MainActor
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .whatIsAI:
            WhatIsAIView()
        case .aiTypes:
            AITypesView()
        case .promptEngineeringBasics:
            BasicsPromptEngineeringView()
        case .promptWorkshop:
            PromptEngineeringWorkshopView()
        case .limitations:
            AILimitationsView()
        case .myths:
            AIMythsView()
        case .dangersBasics:
            BasicsDangersView()
        case .vendingMachine:
            AIVendingMachineView()
        }
    }
}

struct BasicsFeedItem: Identifiable, Hashable {
    let id: UUID
    let title: String
    let summary: String
    let symbolName: String
    let iconForeground: Color
    let iconBackground: Color
    let destination: BasicsDestination

    init(
        id: UUID = UUID(),
        title: String,
        summary: String,
        symbolName: String,
        iconForeground: Color = .white,
        iconBackground: Color = .blue,
        destination: BasicsDestination
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.symbolName = symbolName
        self.iconForeground = iconForeground
        self.iconBackground = iconBackground
        self.destination = destination
    }
}

enum BasicsFeedRepository {
    static let featuredFeeds: [BasicsFeedItem] = [
        BasicsFeedItem(
            title: "What Is AI?",
            summary: "Discover the core concepts behind artificial intelligence. Learn how computers are trained to perform tasks that typically require human intelligence.",
            symbolName: "person.fill.questionmark",
            iconForeground: .white,
            iconBackground: .teal,
            destination: .whatIsAI
        ),
        BasicsFeedItem(
            title: "Myths",
            summary: "Uncover the truth behind common misconceptions about artificial intelligence. Understand what AI can actually do, and what remains science fiction.",
            symbolName: "person.checkmark.and.xmark",
            iconForeground: .white,
            iconBackground: .brown,
            destination: .myths
        ),
        BasicsFeedItem(
            title: "Different Types",
            summary: "Explore the various categories of AI models available today. Find out which type of AI is best suited for your specific needs.",
            symbolName: "brain",
            iconForeground: .white,
            iconBackground: .indigo,
            destination: .aiTypes
        ),
        BasicsFeedItem(
            title: "Prompt Engineering",
            summary: "Master the art of communicating with AI to get better results. Learn simple techniques to craft clear and effective instructions.",
            symbolName: "wrench.and.screwdriver",
            iconForeground: .white,
            iconBackground: .green,
            destination: .promptEngineeringBasics
        ),
        BasicsFeedItem(
            title: "Limitations",
            summary: "Understand the boundaries and current shortcomings of AI technology.",
            symbolName: "exclamationmark.triangle",
            iconForeground: .white,
            iconBackground: .yellow,
            destination: .limitations
        ),
        BasicsFeedItem(
            title: "Dangers",
            summary: "Learn about the potential risks and ethical concerns surrounding AI. Discover how to use these powerful tools safely and responsibly.",
            symbolName: "exclamationmark.octagon.fill",
            iconForeground: .white,
            iconBackground: .red,
            destination: .dangersBasics
        )
    ]
}
