import SwiftUI

struct AITypesView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                DifferentTypesHeroSection()
                DifferentTypesTopicSection(topic: .predictive)
                DifferentTypesTopicSection(topic: .generative)
                DifferentTypesLiveDemo()
                GenerativeImageSection()
                DifferentTypesTopicSection(topic: .classification)
                ClassificationImageExamples()
                DifferentTypesTakeaways()
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 28)
            .frame(maxWidth: 940, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .navigationTitle("Different Types")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
}

// MARK: - Hero

private struct DifferentTypesHeroSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Basics", systemImage: "book.closed")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text("\"AI\" is an umbrella term that covers very different technologies. Knowing the two main types — predictive and generative — helps you choose the right tool and set the right expectations.")
                .font(.title3.weight(.medium))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Predictive AI classifies and forecasts. Generative AI creates. Both are powered by machine learning, but they answer completely different questions.")
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Live Demo

private struct DifferentTypesLiveDemo: View {
    @Environment(\.basicsAccentColor) private var accent
    @State private var selectedType: AITypeSelection = .none

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            liveDemoHeader

            VStack(alignment: .leading, spacing: 14) {
                Text("Same customer review, two completely different AI tasks. Select a type to see what it does with the input.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 6) {
                    Text("INPUT")
                        .font(.caption2.weight(.bold))
                        .tracking(0.8)
                        .foregroundStyle(.secondary)
                    Text("Customer wrote: \"This product is amazing, best purchase ever!\"")
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.primary)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(.quinary))

                HStack(spacing: 12) {
                    AITypeButton(
                        title: "Predictive AI",
                        icon: "chart.bar.fill",
                        color: .blue,
                        isSelected: selectedType == .predictive
                    ) {
                        withAnimation(.snappy(duration: 0.35)) {
                            selectedType = .predictive
                        }
                    }

                    AITypeButton(
                        title: "Generative AI",
                        icon: "sparkles",
                        color: .purple,
                        isSelected: selectedType == .generative
                    ) {
                        withAnimation(.snappy(duration: 0.35)) {
                            selectedType = .generative
                        }
                    }
                }

                if selectedType != .none {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Text("OUTPUT")
                                .font(.caption2.weight(.bold))
                                .tracking(0.8)

                            Text("(\(selectedType == .predictive ? "Predictive" : "Generative"))")
                                .font(.caption2.weight(.medium))
                        }
                        .foregroundStyle(selectedType == .predictive ? .blue : .purple)

                        if selectedType == .predictive {
                            VStack(alignment: .leading, spacing: 8) {
                                AIOutputRow(label: "Sentiment", value: "Positive", confidence: 0.96, color: .green)
                                AIOutputRow(label: "Category", value: "Product Review", confidence: 0.89, color: .blue)
                                AIOutputRow(label: "Intent", value: "Praise", confidence: 0.92, color: .teal)
                            }
                        } else {
                            Text("\"Thank you so much for your kind words! We're thrilled to hear you love your purchase. Your feedback means the world to our team.\"")
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                                .italic()
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill((selectedType == .predictive ? Color.blue : Color.purple).opacity(0.06))
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke((selectedType == .predictive ? Color.blue : Color.purple).opacity(0.2), lineWidth: 0.8)
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                Button("Reset") {
                    withAnimation(.snappy(duration: 0.3)) {
                        selectedType = .none
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(selectedType == .none)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(.thinMaterial))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.separator.opacity(0.35), lineWidth: 0.8)
            }
        }
    }

    private var liveDemoHeader: some View {
        HStack {
            Rectangle()
                .fill(accent)
                .frame(width: 4, height: 28)
                .clipShape(RoundedRectangle(cornerRadius: 2))

            Text("Live Example")
                .font(.title2.bold())

            Spacer()
        }
    }
}

private enum AITypeSelection {
    case none, predictive, generative
}

private struct AITypeButton: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                Text(title)
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(isSelected ? .white : color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? color : color.opacity(0.1))
            )
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct AIOutputRow: View {
    let label: String
    let value: String
    let confidence: Double
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .frame(width: 70, alignment: .trailing)

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)

            Spacer()

            Text("\(Int(confidence * 100))%")
                .font(.caption.monospacedDigit().weight(.semibold))
                .foregroundStyle(color)
        }
    }
}

// MARK: - Generative Image Section

private struct GenerativeImageSection: View {
    @Environment(\.basicsAccentColor) private var accent

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header — same style as all other topic sections
            HStack {
                Rectangle()
                    .fill(accent)
                    .frame(width: 4, height: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 2))
                Text("Generative Images and Videos")
                    .font(.title2.bold())
                Spacer()
            }

            // Info card — same TypeInfoRow style
            TypeInfoRow(
                emoji: "🎬",
                icon: "photo.on.rectangle.angled",
                color: .orange,
                title: "Generative Images and Videos",
                detail: "Unlike prediction (which labels what already exists), generative AI invents entirely new visuals from scratch — pixels that never existed before. The same technology is used in social media filters that smooth skin and relight faces, and in marketing to generate product photos or ad visuals without a camera."
            )

            GenerativeImageDemo()
        }
    }
}

// MARK: - Generative Image Demo

private struct GenStep {
    let label: String
    let sublabel: String
    let blurRadius: CGFloat
    let noiseOpacity: Double
    let imageOpacity: Double
}

private struct GenerativeImageDemo: View {
    @Environment(\.basicsAccentColor) private var accent
    @State private var currentStep: Int = 0
    private let cardCornerRadius: CGFloat = 16

    private let steps: [GenStep] = [
        GenStep(label: "Step 1 of 6",   sublabel: "Pure static — nothing yet",            blurRadius: 0,    noiseOpacity: 1.0,  imageOpacity: 0.0),
        GenStep(label: "Step 2 of 6",   sublabel: "Static starts to blur together",        blurRadius: 18,   noiseOpacity: 0.85, imageOpacity: 0.15),
        GenStep(label: "Step 3 of 6",   sublabel: "Shapes emerging through the haze",      blurRadius: 12,   noiseOpacity: 0.55, imageOpacity: 0.55),
        GenStep(label: "Step 4 of 6",   sublabel: "Getting clearer — almost recognisable", blurRadius: 7,    noiseOpacity: 0.3,  imageOpacity: 0.8),
        GenStep(label: "Step 5 of 6",   sublabel: "Almost there — blur and grain still visible", blurRadius: 3,    noiseOpacity: 0.22, imageOpacity: 0.92),
        GenStep(label: "Step 6 of 6",   sublabel: "Final image!",  blurRadius: 0,    noiseOpacity: 0.0,  imageOpacity: 1.0),
    ]

    private var step: GenStep { steps[currentStep] }
    private var isFirst: Bool { currentStep == 0 }
    private var isLast: Bool  { currentStep == steps.count - 1 }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ── Header band ──────────────────────────────────────────────
            HStack(spacing: 8) {
                Image(systemName: "wand.and.stars")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(accent)
                Text("How generative AI builds an image")
                    .font(.subheadline.weight(.bold))
                Spacer()
                Text("DEMO")
                    .font(.caption2.weight(.black))
                    .tracking(1)
                    .foregroundStyle(accent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(accent.opacity(0.12), in: Capsule())
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background {
                UnevenRoundedRectangle(
                    cornerRadii: .init(
                        topLeading: cardCornerRadius,
                        bottomLeading: 0,
                        bottomTrailing: 0,
                        topTrailing: cardCornerRadius
                    ),
                    style: .continuous
                )
                .fill(accent.opacity(0.07))
            }

            Divider()

            // ── Image area ───────────────────────────────────────────────
            ZStack {
                // The actual image, blurred and faded
                Image("ai-cat")
                    .resizable()
                    .aspectRatio(3 / 2, contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 220)
                    .clipped()
                    .blur(radius: step.blurRadius)
                    .opacity(step.imageOpacity)
                    .animation(.easeInOut(duration: 0.55), value: currentStep)

                // Noise / static overlay — randomised gray checkerboard feel via Canvas
                if step.noiseOpacity > 0 {
                    NoiseOverlay()
                        .opacity(step.noiseOpacity)
                        .animation(.easeInOut(duration: 0.55), value: currentStep)
                }

                // Step label pinned bottom-left
                VStack {
                    Spacer()
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(step.label)
                                .font(.caption.weight(.bold))
                                .tracking(0.5)
                            Text(step.sublabel)
                                .font(.caption.weight(.medium))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.9), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .padding(10)
                        Spacer()
                    }
                }
            }
            .frame(height: 220)
            .clipped()

            Divider()

            // ── Controls & callout ───────────────────────────────────────
            VStack(alignment: .leading, spacing: 10) {
                // Progress dots — centered
                HStack(spacing: 6) {
                    Spacer()
                    ForEach(0..<steps.count, id: \.self) { i in
                        Circle()
                            .fill(i <= currentStep ? accent : Color.gray.opacity(0.3))
                            .frame(width: i == currentStep ? 8 : 6, height: i == currentStep ? 8 : 6)
                            .animation(.snappy, value: currentStep)
                    }
                    Spacer()
                }

                // Buttons — two equal pill-shaped buttons always visible
                HStack(spacing: 10) {
                    // Previous Step — disabled on first step
                    Button {
                        withAnimation(.snappy(duration: 0.3)) { currentStep -= 1 }
                    } label: {
                        Label("Previous", systemImage: "arrow.left")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .clipShape(Capsule())
                    .disabled(isFirst)

                    // Next Step / Start Over — always visible, changes label on last step
                    Button {
                        withAnimation(.snappy(duration: 0.3)) {
                            if isLast { currentStep = 0 } else { currentStep += 1 }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text(isLast ? "Start Over" : "Next")
                            Image(systemName: isLast ? "arrow.counterclockwise" : "arrow.right")
                        }
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .clipShape(Capsule())
                }

                Text("Prompt: A cat holding a phone.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Friendly disclaimer
                HStack(alignment: .top, spacing: 7) {
                    Image(systemName: "info.circle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(accent.opacity(0.8))
                    Text("This is a simplified demo — real AI image generation is far more complex.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(9)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(accent.opacity(0.07), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(accent.opacity(0.2), lineWidth: 0.6)
                }
            }
            .padding(14)
        }
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                .stroke(accent.opacity(0.25), lineWidth: 0.8)
        }
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
    }
}

// Simulates grainy static using Canvas with randomised small rects in muted hues
private struct NoiseOverlay: View {
    // A small palette of muted, low-saturation hues that feel like coloured noise
    private static let muteColors: [Color] = [
        Color(hue: 0.62, saturation: 0.30, brightness: 0.45), // slate-indigo
        Color(hue: 0.55, saturation: 0.25, brightness: 0.50), // muted teal
        Color(hue: 0.70, saturation: 0.20, brightness: 0.40), // dusty violet
        Color(hue: 0.58, saturation: 0.28, brightness: 0.55), // steel blue
        Color(hue: 0.65, saturation: 0.18, brightness: 0.35), // dark slate
        Color(hue: 0.50, saturation: 0.22, brightness: 0.60), // pale teal
        Color(hue: 0.75, saturation: 0.15, brightness: 0.65), // soft lavender
        Color(hue: 0.60, saturation: 0.35, brightness: 0.30), // deep navy-indigo
    ]

    var body: some View {
        Canvas { context, size in
            let cellSize: CGFloat = 4
            let cols = Int(size.width  / cellSize) + 1
            let rows = Int(size.height / cellSize) + 1
            for row in 0..<rows {
                for col in 0..<cols {
                    // Pick a random muted hue and vary its brightness slightly
                    let base = NoiseOverlay.muteColors.randomElement()!
                    let brightnessShift = Double.random(in: -0.15...0.15)
                    let rect = CGRect(
                        x: CGFloat(col) * cellSize,
                        y: CGFloat(row) * cellSize,
                        width: cellSize,
                        height: cellSize
                    )
                    // Vary opacity per cell for extra grain texture
                    let cellOpacity = Double.random(in: 0.55...1.0)
                    context.opacity = cellOpacity
                    context.fill(
                        Path(rect),
                        with: .color(base.opacity(1))
                    )
                    context.opacity = 1
                    // Add occasional slightly brighter speck for grain feel
                    if brightnessShift > 0.08 {
                        context.fill(
                            Path(rect),
                            with: .color(Color(hue: Double.random(in: 0.5...0.75),
                                               saturation: 0.12,
                                               brightness: 0.80))
                        )
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Topic Sections

private struct DifferentTypesTopicSection: View {
    @Environment(\.basicsAccentColor) private var accent
    let topic: DifferentTypesTopic

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Rectangle()
                    .fill(accent)
                    .frame(width: 4, height: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 2))

                Text(topic.title)
                    .font(.title2.bold())

                Spacer()
            }

            TypeInfoRow(
                emoji: topic.emoji,
                icon: topic.icon,
                color: topic.color,
                title: topic.title,
                detail: topic.detail
            )
        }
    }
}

private enum DifferentTypesTopic {
    case predictive
    case generative
    case generativeImagesAndVideos
    case classification

    var title: String {
        switch self {
        case .predictive:
            "Predictive AI"
        case .generative:
            "Generative AI"
        case .generativeImagesAndVideos:
            "Generative Images and Videos"
        case .classification:
            "Classification"
        }
    }

    var detail: String {
        switch self {
        case .predictive:
            "Predictive AI finds patterns in existing data to forecast outcomes. It answers questions like \"what will happen next?\" based on historical signals."
        case .generative:
            "Generative AI creates new output such as text, code, or audio by predicting likely continuations. It is designed to produce fresh content, not just score existing input."
        case .generativeImagesAndVideos:
            "Generative image and video systems synthesize new visuals from prompts, reference images, or edits. They predict new pixels and motion, which is why prompt clarity and safety checks matter."
        case .classification:
            "Classification is a predictive AI task: assign one label from known categories and a confidence score. Spam filtering, sentiment tagging, and defect detection are classic examples."
        }
    }

    var emoji: String {
        switch self {
        case .predictive:
            "📊"
        case .generative:
            "✨"
        case .generativeImagesAndVideos:
            "🎬"
        case .classification:
            "🏷️"
        }
    }

    var icon: String {
        switch self {
        case .predictive:
            "chart.bar.fill"
        case .generative:
            "sparkles"
        case .generativeImagesAndVideos:
            "photo.on.rectangle.angled"
        case .classification:
            "tag.fill"
        }
    }

    var color: Color {
        switch self {
        case .predictive:
            .blue
        case .generative:
            .purple
        case .generativeImagesAndVideos:
            .orange
        case .classification:
            .green
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .predictive:
            [.blue, .cyan]
        case .generative:
            [.indigo, .purple]
        case .generativeImagesAndVideos:
            [.orange, .pink]
        case .classification:
            [.green, .mint]
        }
    }
}

private struct TypeInfoRow: View {
    let emoji: String
    let icon: String
    let color: Color
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack(alignment: .bottomTrailing) {
                Text(emoji)
                    .font(.system(size: 28))
                    .frame(width: 46, height: 46)
                    .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                Image(systemName: icon)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(3)
                    .background(color, in: Circle())
                    .offset(x: 3, y: 3)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(color.opacity(0.2), lineWidth: 0.8)
        }
    }
}

// MARK: - Classification Image Examples

private struct ClassificationImageExamples: View {
    @Environment(\.basicsAccentColor) private var accent

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader

            VStack(alignment: .leading, spacing: 12) {
                Text("Two images. Two very different results. See how confident — or confused — the AI gets.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                // Banana — confident, clear classification
                ClassificationExampleCard(
                    imageName: "banana",
                    title: "Banana",
                    badge: "Easy call ✅",
                    badgeColor: .green,
                    results: [
                        ClassificationResult(label: "Banana", confidence: 1.0, color: .yellow, displayedPercentage: "100%"),
                        ClassificationResult(label: "Corkscrew", confidence: 0.0, color: .gray, displayedPercentage: "0.00%")
                    ],
                    insight: "The AI is nearly certain. Bananas have a very unique shape and colour, so the model recognises them right away.",
                    insightColor: .green
                )

                // Orange — fuzzy, split classification
                ClassificationExampleCard(
                    imageName: "orange",
                    title: "Orange… or Lemon?",
                    badge: "Not so sure 🤔",
                    badgeColor: .orange,
                    results: [
                        ClassificationResult(label: "Orange", confidence: 0.653, color: .orange, displayedPercentage: "65.3%"),
                        ClassificationResult(label: "Lemon", confidence: 0.344, color: .yellow, displayedPercentage: "34.4%")
                    ],
                    insight: "Both oranges and lemons are round, roughly the same size, and citrus yellow-orange. Without a person standing next to it for scale, or the smell, the AI hedges its bets.",
                    insightColor: .orange
                )

                ClassificationFunFactCard()
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(.thinMaterial))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.green.opacity(0.25), lineWidth: 0.8)
            }
        }
    }

    private var sectionHeader: some View {
        HStack {
            Rectangle()
                .fill(accent)
                .frame(width: 4, height: 28)
                .clipShape(RoundedRectangle(cornerRadius: 2))

            Text("See It In Action")
                .font(.title2.bold())

            Spacer()
        }
    }
}

private struct ClassificationResult {
    let label: String
    let confidence: Double
    let color: Color
    let displayedPercentage: String

    init(label: String, confidence: Double, color: Color, displayedPercentage: String? = nil) {
        self.label = label
        self.confidence = confidence
        self.color = color
        self.displayedPercentage = displayedPercentage ?? "\(Int(confidence * 100))%"
    }
}

private struct ClassificationExampleCard: View {
    let imageName: String
    let title: String
    let badge: String
    let badgeColor: Color
    let results: [ClassificationResult]
    let insight: String
    let insightColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Full-width 3:2 image
            Image(imageName)
                .resizable()
                .aspectRatio(3 / 2, contentMode: .fill)
                .frame(maxWidth: .infinity)
                .clipped()

            // Content below image
            VStack(alignment: .leading, spacing: 12) {
                // Title + badge row
                HStack(alignment: .center, spacing: 8) {
                    Text(title)
                        .font(.headline.weight(.bold))
                    Spacer()
                    Text(badge)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(badgeColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(badgeColor.opacity(0.12), in: Capsule())
                }

                // Two confidence stats side by side
                HStack(spacing: 10) {
                    ForEach(results.prefix(2), id: \.label) { result in
                        ClassificationStatBox(result: result)
                    }
                }

                // Insight callout
                HStack(alignment: .top, spacing: 7) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(insightColor)
                        .padding(.top, 1)
                    Text(insight)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(insightColor.opacity(0.08), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(insightColor.opacity(0.2), lineWidth: 0.6)
                }
            }
            .padding(14)
        }
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.separator.opacity(0.25), lineWidth: 0.8)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct ClassificationStatBox: View {
    let result: ClassificationResult

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(result.displayedPercentage)
                .font(.title2.weight(.bold).monospacedDigit())
                .foregroundStyle(result.color)
            Text(result.label)
                .font(.caption.weight(.medium))
                .foregroundStyle(.primary)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(.quaternary)
                        .frame(height: 4)
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(result.color)
                        .frame(width: geo.size.width * result.confidence, height: 4)
                }
            }
            .frame(height: 4)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(result.color.opacity(0.06), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(result.color.opacity(0.18), lineWidth: 0.8)
        }
    }
}

private struct ClassificationFunFactCard: View {
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Icon box
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.purple.opacity(0.12))
                    .frame(width: 46, height: 46)
                Text("📸")
                    .font(.system(size: 24))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Your iPhone Already Does This!")
                    .font(.subheadline.weight(.bold))

                Text("Open your Photos app and tap \"People & Pets\" — your phone has been quietly looking at every photo you've ever taken and grouping them by face. That's image classification. It figures out which photos have your mom in them, which ones have your dog, and even suggests their name if they're in your Contacts.\n\nThe best part? It all happens on your phone. Nothing is sent to Apple. No one is watching.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 5) {
                    Image(systemName: "lock.fill")
                        .font(.caption2.weight(.bold))
                    Text("Runs privately on your device — Apple never sees your photos.")
                        .font(.caption2.weight(.medium))
                }
                .foregroundStyle(.purple)
                .padding(.horizontal, 9)
                .padding(.vertical, 6)
                .background(Color.purple.opacity(0.08), in: Capsule())
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.purple.opacity(0.2), lineWidth: 0.8)
        }
    }
}

// MARK: - At a Glance

private struct DifferentTypesTakeaways: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("At a Glance", systemImage: "rectangle.split.2x1")
                .font(.headline)

            HStack(alignment: .top, spacing: 10) {
                TypeGlanceColumn(
                    title: "Predictive",
                    color: .blue,
                    icon: "chart.bar.fill",
                    rows: [
                        "Classifies existing data",
                        "Answers \"what is this?\"",
                        "Labels + confidence scores",
                        "Spam filters, sentiment"
                    ]
                )
                TypeGlanceColumn(
                    title: "Generative",
                    color: .purple,
                    icon: "sparkles",
                    rows: [
                        "Creates new content",
                        "Answers \"what comes next?\"",
                        "Text, images, code, audio",
                        "Chatbots, image generators"
                    ]
                )
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.separator.opacity(0.45), lineWidth: 0.8)
        }
    }
}

private struct TypeGlanceColumn: View {
    let title: String
    let color: Color
    let icon: String
    let rows: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(4)
                    .background(color, in: Circle())
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(color)
            }

            ForEach(rows, id: \.self) { row in
                HStack(alignment: .top, spacing: 6) {
                    Circle()
                        .fill(color.opacity(0.5))
                        .frame(width: 5, height: 5)
                        .padding(.top, 6)
                    Text(row)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.06), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(color.opacity(0.15), lineWidth: 0.8)
        }
    }
}

#Preview {
    NavigationStack {
        AITypesView()
    }
}
