import SwiftUI

struct NeuralNetworkDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            InfoCard(
                title: "Neural Networks",
                description: "Think of a neural network like a team of detectives trying to solve a puzzle. The first group looks at basic clues (like colors or shapes), passes their notes to the next group who looks for bigger patterns (like ears or wheels), until the final group makes a confident guess. The network learns by making millions of guesses and adjusting its teamwork until it gets things right.",
                icon: "network",
                color: .teal
            )

            DemoSection(title: "Interactive Example") {
                NeuralNetworkInlineDemo()
            }

            DemoSection(title: "Live Example") {
                NeuralNetworkSheetLauncher()
            }

            NeuralNetworkSummary()
        }
    }
}

// MARK: - Inline Live Demo

// MARK: - Animal model for inline demo

/// The four animals the user can pick in the Live Example.
/// The network has two output sub-classifiers: Hooved (Horse/Cow) and Companion (Cat/Dog).
private enum NNAnimal: String, CaseIterable, Identifiable {
    case horse, cow, cat, dog

    var id: String { rawValue }
    var emoji: String {
        switch self { case .horse: "🐴"; case .cow: "🐄"; case .cat: "🐱"; case .dog: "🐶" }
    }
    var name: String { rawValue.capitalized }

    /// [Hooved probability, Companion probability]
    var layer2Probabilities: [Double] {
        switch self {
        case .horse: [0.92, 0.08]
        case .cow:   [0.88, 0.12]
        case .cat:   [0.07, 0.93]
        case .dog:   [0.05, 0.95]
        }
    }

    /// [Horse, Cow, Cat, Dog]
    var targetProbabilities: [Double] {
        switch self {
        case .horse: [0.85, 0.07, 0.03, 0.05]
        case .cow:   [0.09, 0.79, 0.04, 0.08]
        case .cat:   [0.02, 0.05, 0.88, 0.05]
        case .dog:   [0.03, 0.02, 0.04, 0.91]
        }
    }

    var insight: String {
        switch self {
        case .horse: "The network recognized farm-like features (92%), leading it to guess Horse (85%)."
        case .cow:   "The network recognized farm-like features (88%), leading it to guess Cow (79%)."
        case .cat:   "The network recognized pet-like features (93%), leading it to guess Cat (88%)."
        case .dog:   "The network recognized pet-like features (95%), leading it to guess Dog (91%)."
        }
    }

    /// Which output index is dominant (0 = Horse, 1 = Cow, 2 = Cat, 3 = Dog)
    var dominantOutput: Int {
        let max = targetProbabilities.max() ?? 0
        return targetProbabilities.firstIndex(of: max) ?? 0
    }
}

// MARK: - Inline Live Demo

private struct NeuralNetworkInlineDemo: View {
    @State private var selected: NNAnimal = .dog
    @State private var phase: NNDemoPhase = .idle
    @State private var linePulse: Double = 0
    @State private var hiddenGlow: Double = 0
    @State private var layer2Probabilities: [Double] = [0, 0]
    @State private var outputProbabilities: [Double] = [0, 0, 0, 0]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            // ── Intro ─────────────────────────────────────────────────────
            Text("Pick an image of an animal below to see how a neural network processes it. The network doesn't know what it is immediately — it first breaks it down into broader concepts (like \"Farm\" or \"Pet\"), and then uses those clues to make a precise final guess.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // ── Animal picker ─────────────────────────────────────────────
            VStack(alignment: .leading, spacing: 6) {
                Text("CHOOSE AN IMAGE")
                    .font(.caption2.weight(.black))
                    .tracking(1)
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    ForEach(NNAnimal.allCases) { animal in
                        Button {
                            guard animal != selected else { return }
                            withAnimation(.snappy(duration: 0.22)) {
                                selected = animal
                                phase = .idle
                                layer2Probabilities = [0, 0]
                                outputProbabilities = [0, 0, 0, 0]
                                linePulse = 0
                                hiddenGlow = 0
                            }
                        } label: {
                            VStack(spacing: 0) {
                                Text(animal.emoji)
                                    .font(.title2)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                animal == selected ? Color.teal : Color.secondary.opacity(0.1),
                                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .strokeBorder(
                                        animal == selected ? Color.clear : Color.secondary.opacity(0.2),
                                        lineWidth: 1
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(animal.name)")
                        .accessibilityValue(animal == selected ? "Selected" : "")
                        .animation(.snappy(duration: 0.18), value: selected)
                    }
                }
            }

            // ── Diagram ───────────────────────────────────────────────────
            NNAnimalDiagram(
                animal: selected,
                layer2Probabilities: layer2Probabilities,
                outputProbabilities: outputProbabilities,
                linePulse: linePulse,
                hiddenGlow: hiddenGlow,
                phase: phase
            )
            .frame(height: 240)

            // ── Phase strip ───────────────────────────────────────────────
            if phase != .idle {
                HStack(spacing: 8) {
                    Image(systemName: phaseIcon)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(phaseColor)
                    Text(phaseLabel)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(phaseColor)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(phaseColor.opacity(0.08), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            // ── Insight callout ───────────────────────────────────────────
            if phase == .output {
                HStack(alignment: .top, spacing: 7) {
                    Image(systemName: "lightbulb.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.teal.opacity(0.85))
                    Text(selected.insight)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(9)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.teal.opacity(0.07), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.teal.opacity(0.2), lineWidth: 0.6)
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            // ── Controls ──────────────────────────────────────────────────
            HStack(spacing: 10) {
                Button {
                    runForwardPass()
                } label: {
                    Label(phase.isProcessing ? "Processing…" : "Run Forward Pass",
                          systemImage: phase.isProcessing ? "hourglass" : "play.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.teal)
                .controlSize(.large)
                .disabled(phase.isProcessing)

                Button("Reset") {
                    withAnimation(.snappy(duration: 0.3)) {
                        phase = .idle
                        layer2Probabilities = [0, 0]
                        outputProbabilities = [0, 0, 0, 0]
                        linePulse = 0
                        hiddenGlow = 0
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(phase.isProcessing)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(.thinMaterial))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(.separator.opacity(0.35), lineWidth: 0.8)
        }
    }

    private var phaseLabel: String {
        switch phase {
        case .idle:   return "Ready"
        case .input:  return "Step 1 — Encoding \(selected.name) as a numeric vector…"
        case .hidden: return "Step 2 — Activating hidden nodes…"
        case .output: return "Step 3 — Classification complete ✓"
        }
    }
    private var phaseIcon: String {
        switch phase {
        case .idle:   "circle"
        case .input:  "arrow.right.circle.fill"
        case .hidden: "waveform.circle.fill"
        case .output: "checkmark.circle.fill"
        }
    }
    private var phaseColor: Color {
        switch phase {
        case .idle:   .secondary
        case .input:  .blue
        case .hidden: .teal
        case .output: .green
        }
    }

    private func runForwardPass() {
        let targetL2 = selected.layer2Probabilities
        let targetOut = selected.targetProbabilities
        layer2Probabilities = [0, 0]
        outputProbabilities = [0, 0, 0, 0]
        linePulse = 0
        hiddenGlow = 0

        withAnimation(.easeInOut(duration: 0.3)) { phase = .input }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            withAnimation(.easeInOut(duration: 0.35).repeatCount(3, autoreverses: true)) { linePulse = 1 }
            withAnimation(.easeIn(duration: 0.5)) { hiddenGlow = 1 }
            withAnimation(.easeInOut(duration: 0.3)) { phase = .hidden }
            
            for i in 0..<targetL2.count {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(Double(i) * 0.18)) {
                    layer2Probabilities[i] = targetL2[i]
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            withAnimation(.easeInOut(duration: 0.25)) { phase = .output }
            for i in 0..<targetOut.count {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(Double(i) * 0.18)) {
                    outputProbabilities[i] = targetOut[i]
                }
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.5)) { linePulse = 0 }
            withAnimation(.easeOut(duration: 0.5).delay(0.5)) { hiddenGlow = 0.25 }
        }
    }
}

// MARK: - Animal Classifier Diagram

/// Single-input → hidden nodes → layer 2 (Hooved / Companion) → output classifiers (Horse/Cow/Cat/Dog)
private struct NNAnimalDiagram: View {
    let animal: NNAnimal
    let layer2Probabilities: [Double]
    let outputProbabilities: [Double]
    let linePulse: Double
    let hiddenGlow: Double
    let phase: NNDemoPhase

    private let layer2Labels  = ["Farm", "Pet"]
    private let outputLabels  = ["Horse", "Cow", "Cat", "Dog"]
    private let layer2Colors: [Color] = [.orange, .teal]
    private let outputColors: [Color] = [.orange, .orange, .teal, .teal]
    private var accent: Color { .teal }

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height

            let inputX   = w * 0.10
            let hidden1X = w * 0.32
            let hidden2X = w * 0.58
            let outputX  = w * 0.88

            let inputPt    = CGPoint(x: inputX, y: h / 2)
            let hidden1Pts = evenPoints(count: 4, x: hidden1X, top: 22, bottom: h - 22)
            let hidden2Pts = evenPoints(count: 2, x: hidden2X, top: h * 0.28, bottom: h * 0.72)
            let outputPts  = evenPoints(count: 4, x: outputX, top: 22, bottom: h - 22)

            let inputActive  = phase != .idle
            let hiddenActive = phase == .hidden || phase == .output
            let outputActive = phase == .output

            let connBase: Color = inputActive ? accent : Color.secondary.opacity(0.18)
            let connW = CGFloat(1.0 + 1.4 * linePulse)

            ZStack {
                // input → hidden1
                ForEach(hidden1Pts.indices, id: \.self) { j in
                    Path { p in p.move(to: inputPt); p.addLine(to: hidden1Pts[j]) }
                        .stroke(connBase.opacity(0.2 + 0.5 * linePulse),
                                style: StrokeStyle(lineWidth: connW, lineCap: .round))
                }
                // hidden1 → hidden2 (Layer 2)
                ForEach(hidden1Pts.indices, id: \.self) { i in
                    ForEach(hidden2Pts.indices, id: \.self) { j in
                        let prob = layer2Probabilities.indices.contains(j) ? layer2Probabilities[j] : 0
                        let color = layer2Colors[j]
                        Path { p in p.move(to: hidden1Pts[i]); p.addLine(to: hidden2Pts[j]) }
                            .stroke(hiddenActive
                                        ? color.opacity(0.15 + 0.45 * prob)
                                        : Color.secondary.opacity(0.15),
                                    style: StrokeStyle(lineWidth: connW + CGFloat(prob), lineCap: .round))
                    }
                }
                // hidden2 (Layer 2) → output
                // Only connect Hooved (0) to Horse (0) and Cow (1)
                // Only connect Companion (1) to Cat (2) and Dog (3)
                ForEach(hidden2Pts.indices, id: \.self) { i in
                    let outIndices = i == 0 ? [0, 1] : [2, 3]
                    ForEach(outIndices, id: \.self) { j in
                        let prob = outputProbabilities.indices.contains(j) ? outputProbabilities[j] : 0
                        let outputColor = outputColors[j]
                        Path { p in p.move(to: hidden2Pts[i]); p.addLine(to: outputPts[j]) }
                            .stroke(outputActive
                                        ? outputColor.opacity(0.18 + 0.55 * prob)
                                        : Color.secondary.opacity(0.12),
                                    style: StrokeStyle(lineWidth: connW + CGFloat(prob), lineCap: .round))
                    }
                }

                // Layer labels
                layerLabel("Input",    x: inputX)
                layerLabel("Layer 1",  x: hidden1X)
                layerLabel("Layer 2",  x: hidden2X)
                layerLabel("Output",   x: outputX)

                // Input node (big emoji)
                Circle()
                    .fill(.regularMaterial)
                    .frame(width: 54, height: 54)
                    .overlay { Text(animal.emoji).font(.title2) }
                    .overlay {
                        Circle().stroke(
                            inputActive ? accent.opacity(0.55 + 0.3 * linePulse) : Color.secondary.opacity(0.3),
                            lineWidth: inputActive ? 1.8 : 1
                        )
                    }
                    .shadow(color: inputActive ? accent.opacity(0.25 * linePulse) : .clear, radius: 8)
                    .scaleEffect(inputActive ? 1.0 + 0.03 * linePulse : 1.0)
                    .position(inputPt)

                // Hidden layer 1
                ForEach(hidden1Pts.indices, id: \.self) { i in
                    Circle()
                        .fill(.thickMaterial)
                        .frame(width: 22, height: 22)
                        .overlay { Circle().fill(accent.opacity(0.32 * hiddenGlow)) }
                        .overlay { Circle().stroke(
                            hiddenActive ? accent.opacity(0.45 + 0.35 * hiddenGlow) : Color.secondary.opacity(0.3),
                            lineWidth: 1) }
                        .shadow(color: accent.opacity(0.35 * hiddenGlow), radius: CGFloat(8 * hiddenGlow))
                        .scaleEffect(1.0 + 0.08 * hiddenGlow)
                        .position(hidden1Pts[i])
                }

                // Hidden layer 2 (Hooved / Companion)
                ForEach(hidden2Pts.indices, id: \.self) { i in
                    let prob   = layer2Probabilities.indices.contains(i) ? layer2Probabilities[i] : 0
                    let isWinner = hiddenActive && prob > 0.5
                    let nodeColor = layer2Colors[i]
                    VStack(spacing: 2) {
                        Text(layer2Labels[i])
                            .font(.caption2.weight(.bold))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(isWinner ? nodeColor : .primary)
                        if hiddenActive {
                            Text("\(Int(prob * 100))%")
                                .font(.caption2.monospacedDigit().weight(.black))
                                .foregroundStyle(isWinner ? nodeColor : .secondary)
                                .transition(.opacity.combined(with: .scale(scale: 0.7)))
                        }
                    }
                    .padding(.horizontal, 7)
                    .padding(.vertical, 6)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .stroke(
                                isWinner ? nodeColor.opacity(0.7) : nodeColor.opacity(0.2),
                                lineWidth: isWinner ? 1.8 : 0.8
                            )
                    }
                    .shadow(color: isWinner ? nodeColor.opacity(0.3) : .clear, radius: 8)
                    .scaleEffect(isWinner ? 1.05 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: hiddenActive)
                    .position(hidden2Pts[i])
                }

                // Output nodes (Horse, Cow, Cat, Dog)
                ForEach(outputPts.indices, id: \.self) { i in
                    let prob   = outputProbabilities.indices.contains(i) ? outputProbabilities[i] : 0
                    let isWinner = outputActive && i == animal.dominantOutput
                    let nodeColor = outputColors[i]
                    VStack(spacing: 2) {
                        Text(outputLabels[i])
                            .font(.caption2.weight(.bold))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(isWinner ? nodeColor : .primary)
                        if outputActive {
                            Text("\(Int(prob * 100))%")
                                .font(.caption2.monospacedDigit().weight(.black))
                                .foregroundStyle(isWinner ? nodeColor : .secondary)
                                .transition(.opacity.combined(with: .scale(scale: 0.7)))
                        }
                    }
                    .padding(.horizontal, 7)
                    .padding(.vertical, 6)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .stroke(
                                isWinner ? nodeColor.opacity(0.7) : nodeColor.opacity(0.2),
                                lineWidth: isWinner ? 1.8 : 0.8
                            )
                    }
                    .shadow(color: isWinner ? nodeColor.opacity(0.3) : .clear, radius: 8)
                    .scaleEffect(isWinner ? 1.05 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: outputActive)
                    .position(outputPts[i])
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Neural network: \(animal.name) input → hidden layers → Hooved or Companion output")
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.teal.opacity(0.04)))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.teal.opacity(0.12), lineWidth: 1)
        }
    }

    private func layerLabel(_ text: String, x: CGFloat) -> some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .foregroundStyle(.secondary)
            .position(x: x, y: 7)
    }

    private func evenPoints(count: Int, x: CGFloat, top: CGFloat, bottom: CGFloat) -> [CGPoint] {
        guard count > 1 else { return [CGPoint(x: x, y: (top + bottom) / 2)] }
        let step = (bottom - top) / CGFloat(count - 1)
        return (0..<count).map { CGPoint(x: x, y: top + step * CGFloat($0)) }
    }
}

// NNInlineDiagram removed — replaced by NNAnimalDiagram above

private struct NNOutputRow: View {
    let label: String
    let probability: Double
    let isHighlighted: Bool

    var body: some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.caption2.weight(.medium))
                .frame(width: 48, alignment: .leading)

            ProgressView(value: probability)
                .tint(isHighlighted ? .green : .gray)
                .frame(width: 40)

            Text("\(Int(probability * 100))%")
                .font(.caption2.monospacedDigit().weight(.bold))
                .foregroundStyle(isHighlighted ? .green : .secondary)
                .frame(width: 28, alignment: .trailing)
        }
    }
}

private enum NNDemoPhase {
    case idle, input, hidden, output

    var isProcessing: Bool {
        self == .input || self == .hidden
    }
}

// MARK: - Interactive Sheet Launcher

private struct NeuralNetworkSheetLauncher: View {
    @State private var showSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Try any emoji — the network will figure out what kind of thing it is.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button {
                showSheet = true
            } label: {
                Label("Try It Yourself", systemImage: "sparkles")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.teal)
            .controlSize(.large)
            .clipShape(Capsule())
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(.thinMaterial))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.separator.opacity(0.35), lineWidth: 0.8)
        }
        .sheet(isPresented: $showSheet) {
            EmojiClassifierSheet()
#if os(iOS)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
#endif
        }
    }
}

// MARK: - Redesigned Emoji Classifier Sheet

private struct EmojiClassifierSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var inputEmoji: String = ""
    @State private var errorMessage: String? = nil
    @State private var isRunning: Bool = false
    @State private var linePulse: Double = 0
    @State private var hiddenGlow: Double = 0
    @State private var probs: [Double] = [0, 0, 0]   // [Living, Object, Symbol]
    @State private var hasRun: Bool = false
    @State private var runTask: Task<Void, Never>?

    private var outputCategories: [(label: String, icon: String, color: Color)] {
        [("Living",  "leaf.fill",           .green),
         ("Object",  "cube.fill",           .blue),
         ("Symbol",  "star.fill",           .orange)]
    }

    private var winnerIndex: Int? {
        guard hasRun, let max = probs.max(), max > 0 else { return nil }
        return probs.firstIndex(of: max)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // ── Hero header ────────────────────────────────────────
                    VStack(spacing: 10) {
                        // Big emoji preview
                        if displayedEmoji.isEmpty {
                            Text("🤔")
                                .font(.system(size: 72))
                                .opacity(0.3)
                        } else {
                            Text(displayedEmoji)
                                .font(.system(size: 72))
                                .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
                                .contentTransition(.symbolEffect(.replace))
                                .animation(.snappy, value: inputEmoji)
                        }

                        Text("What kind of thing is this?")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 32)
                    .frame(maxWidth: .infinity)
                    .background(.quaternary)

                    VStack(spacing: 20) {
                        // ── Emoji text field ───────────────────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Your Emoji", systemImage: "hand.tap")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)

                            HStack(alignment: .top, spacing: 10) {
                                VStack(alignment: .leading, spacing: 4) {
                                    TextField("Type any emoji…", text: $inputEmoji)
                                        .font(.title2)
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                        .onChange(of: inputEmoji) { _, new in
                                            let glyphs = EmojiParser.emojis(in: new)
                                            if new.isEmpty {
                                                errorMessage = nil
                                            } else if glyphs.isEmpty {
                                                errorMessage = "Please enter an emoji, not text."
                                            } else {
                                                errorMessage = nil
                                                let clamped = String(glyphs.first!)
                                                if clamped != new { inputEmoji = clamped }
                                            }
                                            
                                            // Reset results when input changes
                                            if hasRun {
                                                withAnimation(.snappy) {
                                                    hasRun = false
                                                    probs = [0, 0, 0]
                                                    linePulse = 0
                                                    hiddenGlow = 0
                                                }
                                            }
                                        }
                                    
                                    if let errorMessage {
                                        Text(errorMessage)
                                            .font(.caption2.weight(.medium))
                                            .foregroundStyle(.red)
                                            .padding(.leading, 4)
                                    }
                                }

                                Button {
                                    classify()
                                } label: {
                                    Label(isRunning ? "Running…" : "Classify",
                                          systemImage: isRunning ? "hourglass" : "bolt.fill")
                                        .font(.headline)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.teal)
                                .clipShape(Capsule())
                                .disabled(isRunning || displayedEmoji.isEmpty)
                            }
                        }
                        .padding(.horizontal, 20)

                        // ── Network mini-diagram ───────────────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Network Visualization", systemImage: "point.3.connected.trianglepath.dotted")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)

                            SheetNetworkDiagram(
                                inputEmoji: displayedEmoji,
                                probs: probs,
                                linePulse: linePulse,
                                hiddenGlow: hiddenGlow,
                                hasRun: hasRun
                            )
                            .frame(height: 180)
                        }
                        .padding(.horizontal, 20)

                        // ── Results ────────────────────────────────────────
                        if hasRun {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Results", systemImage: "chart.bar.fill")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)

                                VStack(spacing: 10) {
                                    ForEach(outputCategories.indices, id: \.self) { i in
                                        let cat  = outputCategories[i]
                                        let prob = probs.indices.contains(i) ? probs[i] : 0
                                        let isWinner = i == winnerIndex
                                        HStack(spacing: 12) {
                                            Image(systemName: cat.icon)
                                                .font(.body.weight(.semibold))
                                                .foregroundStyle(isWinner ? .white : cat.color)
                                                .frame(width: 34, height: 34)
                                                .background(
                                                    isWinner ? cat.color : cat.color.opacity(0.12),
                                                    in: RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                )

                                            VStack(alignment: .leading, spacing: 3) {
                                                HStack {
                                                    Text(cat.label)
                                                        .font(.subheadline.weight(isWinner ? .bold : .medium))
                                                    if isWinner {
                                                        Text("WINNER")
                                                            .font(.caption2.weight(.black))
                                                            .tracking(0.8)
                                                            .foregroundStyle(cat.color)
                                                            .padding(.horizontal, 6)
                                                            .padding(.vertical, 2)
                                                            .background(cat.color.opacity(0.12), in: Capsule())
                                                    }
                                                    Spacer()
                                                    Text("\(Int(prob * 100))%")
                                                        .font(.subheadline.monospacedDigit().weight(.semibold))
                                                        .foregroundStyle(isWinner ? cat.color : .secondary)
                                                }
                                                GeometryReader { g in
                                                    ZStack(alignment: .leading) {
                                                        Capsule().fill(cat.color.opacity(0.12))
                                                            .frame(height: 5)
                                                        Capsule().fill(cat.color)
                                                            .frame(width: g.size.width * prob, height: 5)
                                                    }
                                                }
                                                .frame(height: 5)
                                            }
                                        }
                                        .padding(12)
                                        .background(
                                            isWinner ? cat.color.opacity(0.07) : Color.secondary.opacity(0.05),
                                            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        )
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .strokeBorder(
                                                    isWinner ? cat.color.opacity(0.35) : Color.secondary.opacity(0.1),
                                                    lineWidth: isWinner ? 1.2 : 0.8
                                                )
                                        }
                                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                                    }
                                }

                                // Friendly note
                                HStack(alignment: .top, spacing: 7) {
                                    Image(systemName: "info.circle.fill")
                                        .font(.caption)
                                        .foregroundStyle(Color.teal.opacity(0.7))
                                    Text("Please note: AI models can sometimes make mistakes or misclassify items. This is a simplified simulation of how real neural networks learn from huge datasets.")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(10)
                                .background(Color.teal.opacity(0.06), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                            }
                            .padding(.horizontal, 20)
                            .transition(.opacity)
                        }
                    }
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Emoji Classifier")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onDisappear { runTask?.cancel() }
        }
    }

    private var displayedEmoji: String {
        EmojiParser.emojis(in: inputEmoji).first ?? inputEmoji
    }

    private func classify() {
        guard !isRunning else { return }
        runTask?.cancel()
        probs = [0, 0, 0]
        linePulse = 0
        hiddenGlow = 0
        hasRun = false
        isRunning = true

        let target = NeuralProbabilityEngine.probabilities(for: [displayedEmoji])

        runTask = Task {
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.38).repeatCount(4, autoreverses: true)) { linePulse = 1 }
                withAnimation(.easeIn(duration: 0.5)) { hiddenGlow = 1 }
            }
            try? await Task.sleep(nanoseconds: 600_000_000)
            if Task.isCancelled { return }

            for i in target.indices {
                try? await Task.sleep(nanoseconds: 130_000_000)
                if Task.isCancelled { return }
                await MainActor.run {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                        probs[i] = target[i]
                    }
                }
            }
            try? await Task.sleep(nanoseconds: 350_000_000)
            if Task.isCancelled { return }
            await MainActor.run {
                withAnimation(.easeOut(duration: 0.3)) { linePulse = 0; hiddenGlow = 0.2 }
                withAnimation(.snappy) { hasRun = true; isRunning = false }
            }
        }
    }
}

// MARK: - Sheet network mini-diagram

private struct SheetNetworkDiagram: View {
    let inputEmoji: String
    let probs: [Double]
    let linePulse: Double
    let hiddenGlow: Double
    let hasRun: Bool

    private let outputLabels  = ["Living", "Object", "Symbol"]
    private let outputColors: [Color] = [.green, .blue, .orange]
    private var accent: Color { .teal }

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height

            let inputX   = w * 0.12
            let hidden1X = w * 0.38
            let hidden2X = w * 0.62
            let outputX  = w * 0.88

            let inputPt     = CGPoint(x: inputX, y: h / 2)
            let hidden1Pts  = evenPoints(count: 5, x: hidden1X, top: 14, bottom: h - 14)
            let hidden2Pts  = evenPoints(count: 2, x: hidden2X, top: h * 0.35, bottom: h * 0.65)
            let outputPts   = evenPoints(count: 3, x: outputX, top: h * 0.2, bottom: h * 0.8)

            let _ = max(probs.max() ?? 0, 0.001)
            let connW = CGFloat(1.0 + 1.2 * linePulse)

            ZStack {
                // input → hidden1
                ForEach(hidden1Pts.indices, id: \.self) { j in
                    Path { p in p.move(to: inputPt); p.addLine(to: hidden1Pts[j]) }
                        .stroke(accent.opacity(0.15 + 0.4 * linePulse),
                                style: StrokeStyle(lineWidth: connW, lineCap: .round))
                }
                
                // hidden1 → hidden2
                ForEach(hidden1Pts.indices, id: \.self) { i in
                    ForEach(hidden2Pts.indices, id: \.self) { j in
                        Path { p in p.move(to: hidden1Pts[i]); p.addLine(to: hidden2Pts[j]) }
                            .stroke(accent.opacity(0.12 + 0.3 * linePulse),
                                    style: StrokeStyle(lineWidth: connW, lineCap: .round))
                    }
                }
                
                // hidden2 → output (colored by output)
                // Connect top hidden2 node to Living (0)
                // Connect bottom hidden2 node to Object (1) and Symbol (2)
                ForEach(hidden2Pts.indices, id: \.self) { i in
                    let outIndices = i == 0 ? [0] : [1, 2]
                    ForEach(outIndices, id: \.self) { j in
                        let prob  = probs.indices.contains(j) ? probs[j] : 0
                        let color = outputColors[j]
                        Path { p in p.move(to: hidden2Pts[i]); p.addLine(to: outputPts[j]) }
                            .stroke(hasRun ? color.opacity(0.1 + 0.55 * prob) : accent.opacity(0.12 + 0.3 * linePulse),
                                    style: StrokeStyle(lineWidth: connW, lineCap: .round))
                    }
                }

                // Input node
                Circle()
                    .fill(.regularMaterial)
                    .frame(width: 52, height: 52)
                    .overlay { Text(inputEmoji).font(.title2) }
                    .overlay { Circle().stroke(accent.opacity(0.3 + 0.4 * linePulse), lineWidth: 1.5) }
                    .shadow(color: accent.opacity(0.2 * linePulse), radius: 8)
                    .scaleEffect(1.0 + 0.03 * linePulse)
                    .position(inputPt)

                // Hidden 1 nodes
                ForEach(hidden1Pts.indices, id: \.self) { i in
                    Circle()
                        .fill(.thickMaterial)
                        .frame(width: 20, height: 20)
                        .overlay { Circle().fill(accent.opacity(0.3 * hiddenGlow)) }
                        .overlay { Circle().stroke(accent.opacity(0.3 + 0.4 * hiddenGlow), lineWidth: 1) }
                        .shadow(color: accent.opacity(0.3 * hiddenGlow), radius: CGFloat(7 * hiddenGlow))
                        .scaleEffect(1.0 + 0.08 * hiddenGlow)
                        .position(hidden1Pts[i])
                }
                
                // Hidden 2 nodes
                ForEach(hidden2Pts.indices, id: \.self) { i in
                    Circle()
                        .fill(.thickMaterial)
                        .frame(width: 20, height: 20)
                        .overlay { Circle().fill(accent.opacity(0.3 * hiddenGlow)) }
                        .overlay { Circle().stroke(accent.opacity(0.3 + 0.4 * hiddenGlow), lineWidth: 1) }
                        .shadow(color: accent.opacity(0.3 * hiddenGlow), radius: CGFloat(7 * hiddenGlow))
                        .scaleEffect(1.0 + 0.08 * hiddenGlow)
                        .position(hidden2Pts[i])
                }

                // Output nodes
                ForEach(outputPts.indices, id: \.self) { i in
                    let prob = probs.indices.contains(i) ? probs[i] : 0
                    let isWinner = hasRun && prob == probs.max()
                    let color = outputColors[i]
                    VStack(spacing: 2) {
                        Text(outputLabels[i])
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(isWinner ? color : .primary)
                        Text("\(Int(prob * 100))%")
                            .font(.caption2.monospacedDigit().weight(.black))
                            .foregroundStyle(isWinner ? color : .secondary)
                    }
                    .padding(.horizontal, 7)
                    .padding(.vertical, 5)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(isWinner ? color.opacity(0.7) : color.opacity(0.2),
                                    lineWidth: isWinner ? 1.5 : 0.8)
                    }
                    .shadow(color: isWinner ? color.opacity(0.25) : .clear, radius: 6)
                    .scaleEffect(isWinner ? 1.06 : 1.0)
                    .animation(.spring(response: 0.35, dampingFraction: 0.7), value: hasRun)
                    .position(outputPts[i])
                }
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.teal.opacity(0.04)))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.teal.opacity(0.12), lineWidth: 1)
        }
    }

    private func evenPoints(count: Int, x: CGFloat, top: CGFloat, bottom: CGFloat) -> [CGPoint] {
        guard count > 1 else { return [CGPoint(x: x, y: (top + bottom) / 2)] }
        let step = (bottom - top) / CGFloat(count - 1)
        return (0..<count).map { CGPoint(x: x, y: top + step * CGFloat($0)) }
    }
}

// NeuralDogClassifierExampleCard removed — section replaced by NNAnimalDiagram in inline demo

// Dead code removed (DogClassifierMiniDiagram, ExampleConfidenceRow, NeuralOutputCategory)

private enum NeuralProbabilityEngine {
    static func probabilities(for emojis: [String]) -> [Double] {
        let safeInput = Array(emojis.prefix(3))
        guard !safeInput.isEmpty else {
            return [0.34, 0.33, 0.33]
        }

        var inputVector = [Double](repeating: 0, count: 3)
        for emoji in safeInput {
            let embedding = embedding(for: emoji)
            for index in inputVector.indices {
                inputVector[index] += embedding[index]
            }
        }
        inputVector = inputVector.map { $0 / Double(safeInput.count) }

        let hiddenWeights: [[Double]] = [
            [0.9, 0.3, 0.2],
            [0.4, 0.8, 0.5],
            [0.2, 0.5, 0.9],
            [0.7, 0.6, 0.4]
        ]
        let hiddenBiases: [Double] = [0.1, -0.2, 0.05, 0.0]

        let hiddenLayer = zip(hiddenWeights, hiddenBiases).map { weights, bias in
            max(0, dot(weights, inputVector) + bias)
        }

        let outputWeights: [[Double]] = [
            [1.2, 0.35, 0.2, 0.1],
            [0.2, 1.25, 0.35, 0.15],
            [0.25, 0.3, 1.15, 0.2]
        ]
        let outputBiases: [Double] = [0.02, -0.01, 0.0]

        let logits = zip(outputWeights, outputBiases).map { weights, bias in
            dot(weights, hiddenLayer) + bias
        }

        return softmax(logits)
    }

    private static func embedding(for emoji: String) -> [Double] {
        switch EmojiSemanticClassifier.classify(emoji) {
        case .living:
            return [2.8, 0.35, 0.5]
        case .objects:
            return [0.45, 2.75, 0.5]
        case .symbols:
            return [0.5, 0.55, 2.7]
        case .unknown:
            // Deterministic neutral embedding for unknown emoji.
            return [1.0, 1.0, 1.0]
        }
    }

    private static func dot(_ lhs: [Double], _ rhs: [Double]) -> Double {
        zip(lhs, rhs).reduce(0) { partial, pair in
            partial + (pair.0 * pair.1)
        }
    }

    private static func softmax(_ values: [Double]) -> [Double] {
        guard let maxValue = values.max() else { return [] }
        let exponents = values.map { exp($0 - maxValue) }
        let sum = exponents.reduce(0, +)
        return exponents.map { $0 / sum }
    }
}

private enum EmojiSemanticCategory {
    case living
    case objects
    case symbols
    case unknown
}

private enum EmojiSemanticClassifier {
    static func classify(_ emoji: String) -> EmojiSemanticCategory {
        let scalars = meaningfulScalars(in: emoji)
        guard !scalars.isEmpty else { return .unknown }

        var livingScore = 0
        var objectScore = 0
        var symbolScore = 0

        if scalars.contains(where: { (0x1F1E6...0x1F1FF).contains(Int($0.value)) }) ||
            containsKeycap(scalars) ||
            containsTagScalars(scalars)
        {
            symbolScore += 4
        }

        for scalar in scalars {
            if scalar.properties.isEmojiModifier || scalar.properties.isEmojiModifierBase {
                livingScore += 2
            }

            switch scalar.properties.generalCategory {
            case .currencySymbol, .mathSymbol, .modifierSymbol:
                symbolScore += 1
            default:
                break
            }

            guard let scalarName = scalar.properties.name?.uppercased() else { continue }

            livingScore += keywordScore(in: scalarName, keywords: livingKeywords)
            objectScore += keywordScore(in: scalarName, keywords: objectKeywords)
            symbolScore += keywordScore(in: scalarName, keywords: symbolKeywords)
        }

        let maxScore = max(livingScore, objectScore, symbolScore)
        guard maxScore > 0 else { return .unknown }

        let winnerCount = [livingScore, objectScore, symbolScore].filter { $0 == maxScore }.count
        guard winnerCount == 1 else { return .unknown }

        if maxScore == livingScore { return .living }
        if maxScore == objectScore { return .objects }
        return .symbols
    }

    private static func keywordScore(in scalarName: String, keywords: Set<String>) -> Int {
        keywords.reduce(0) { partial, keyword in
            partial + (scalarName.contains(keyword) ? 1 : 0)
        }
    }

    private static func meaningfulScalars(in emoji: String) -> [UnicodeScalar] {
        emoji.unicodeScalars.filter { scalar in
            scalar.value != 0x200D && // zero-width joiner
            scalar.value != 0xFE0F && // emoji variation selector
            scalar.value != 0xFE0E // text variation selector
        }
    }

    private static func containsKeycap(_ scalars: [UnicodeScalar]) -> Bool {
        scalars.contains { $0.value == 0x20E3 }
    }

    private static func containsTagScalars(_ scalars: [UnicodeScalar]) -> Bool {
        scalars.contains { (0xE0020...0xE007F).contains(Int($0.value)) }
    }

    private static let livingKeywords: Set<String> = [
        "FACE", "PERSON", "MAN", "WOMAN", "BOY", "GIRL", "BABY", "ADULT", "HAND", "EYE", "MOUTH",
        "ANIMAL", "DOG", "CAT", "MONKEY", "BIRD", "FISH", "WHALE", "SHARK", "HORSE", "BEAR", "PANDA",
        "RABBIT", "FOX", "LION", "TIGER", "ELEPHANT", "FROG", "BEE", "BUTTERFLY", "PLANT", "TREE",
        "LEAF", "FLOWER", "BLOSSOM", "SEEDLING", "HERB", "CACTUS", "MUSHROOM", "SMILE", "GRIN",
        "LAUGH", "TEAR", "CRY", "SAD", "ANGRY", "MAD", "POUT", "KISS", "HEART_EYES", "ALIEN",
        "GHOST", "SKULL", "OGRE", "GOBLIN", "ZOMBIE", "VAMPIRE", "MERMAID", "FAIRY", "MAGE",
        "ELF", "GENIE", "TROLL", "BUG", "ANT", "SPIDER", "SNAIL", "SNAKE", "TURTLE", "LIZARD",
        "DINOSAUR", "DRAGON", "MICROBE", "VIRUS", "BACTERIA", "CORAL", "ROSE", "TULIP", "CHERRY",
        "APPLE", "PEAR", "ORANGE", "LEMON", "BANANA", "WATERMELON", "GRAPE", "STRAWBERRY", "MELON",
        "PEACH", "PINEAPPLE", "COCONUT", "KIWI", "TOMATO", "EGGPLANT", "AVOCADO", "POTATO", "CARROT",
        "CORN", "PEPPER", "CUCUMBER", "LETTUCE", "BROCCOLI", "GARLIC", "ONION", "PEANUT", "CHESTNUT",
        "BONE", "MEAT", "POULTRY", "HAIR", "TOOTH", "TONGUE", "EAR", "NOSE", "FOOT", "LEG", "ARM",
        "BRAIN", "LUNG", "ANATOMICAL HEART", "BLOOD", "SWEAT", "FINGER", "THUMB", "FIST", "PALM",
        "NAIL", "MUSCLE", "KNEE", "PIG", "COW", "BOAR", "SHEEP", "GOAT", "CAMEL", "LLAMA", "GIRAFFE",
        "MACAQUE", "GORILLA", "ORANGUTAN", "CHIPMUNK", "SQUIRREL", "HEDGEHOG", "BAT", "SLOTH",
        "OTTER", "SKUNK", "KANGAROO", "BADGER", "TURKEY", "CHICKEN", "ROOSTER", "HATCHING", "PENGUIN",
        "DOVE", "EAGLE", "DUCK", "SWAN", "OWL", "FLAMINGO", "PEACOCK", "PARROT", "FROG", "CROCODILE",
        "SAUROPOD", "T-REX", "DOLPHIN", "SEAL", "ORCA", "OCTOPUS", "SQUID", "SHRIMP", "LOBSTER",
        "CRAB", "BLOWFISH", "OYSTER", "SCORPION", "MOSQUITO", "CRICKET", "BEETLE", "COCKROACH",
        "FLY", "WORM"
    ]

    private static let objectKeywords: Set<String> = [
        "FOOD", "DRINK", "BREAD", "CAKE", "PIZZA", "BURGER", "SUSHI", "NOODLE", "RICE", "FRUIT", "VEGETABLE",
        "PHONE", "COMPUTER", "LAPTOP", "CAMERA", "HEADPHONE", "MICROPHONE", "CLOCK", "WATCH", "BOOK", "TOOL",
        "HAMMER", "WRENCH", "LIGHT", "BULB", "BATTERY", "KEY", "LOCK", "DOOR", "HOUSE", "BUILDING", "CAR",
        "BUS", "TRAIN", "AIRPLANE", "SHIP", "PACKAGE", "BAG", "SHOE", "HAT", "SHIRT", "BALL", "TROPHY",
        "PALETTE", "CRAYON", "BRUSH", "PENCIL", "PEN", "INSTRUMENT", "VEHICLE", "WHEEL", "ROCKET",
        "SAILBOAT", "GUITAR", "PIANO", "TRUMPET", "VIOLIN", "DRUM", "CROWN", "RING", "GEM", "SHIELD",
        "SWORD", "DAGGER", "BOW", "GUN", "PISTOL", "BOMB", "NUT", "GEAR", "SCISSORS", "BED", "COUCH",
        "CHAIR", "TOILET", "SHOWER", "BATH", "SOAP", "SPONGE", "BROOM", "BASKET", "COFFIN", "URN",
        "AMPHORA", "VASE", "MAP", "GLOBE", "COMPASS", "BRICK", "ROCK", "WOOD", "LOG", "COIN", "MONEY",
        "BILL", "CARD", "TICKET", "MEDAL", "GIFT", "RIBBON", "BALLOON", "DOLL", "TEDDY", "FRAME",
        "PAINTING", "MIRROR", "WINDOW", "TELESCOPE", "MICROSCOPE", "SYRINGE", "PILL", "THERMOMETER",
        "STETHOSCOPE", "BANDAGE", "CRUTCH", "WHEELCHAIR", "CANE", "GLASSES", "GOGGLES", "COAT",
        "JACKET", "TIE", "DRESS", "SKIRT", "PANTS", "JEANS", "SOCKS", "GLOVES", "SCARF", "UMBRELLA",
        "THREAD", "YARN", "PIN", "NEEDLE", "ZIPPER", "CUP", "MUG", "BOTTLE", "PLATE", "BOWL",
        "CHOPSTICKS", "FORK", "SPOON", "KNIFE", "JUG", "JAR", "POT", "PAN", "TENT", "CASTLE",
        "STADIUM", "SHRINE", "MOSQUE", "SYNAGOGUE", "CHURCH", "TEMPLE", "FACTORY", "HOSPITAL",
        "SCHOOL", "HOTEL", "BANK", "POST", "STATION", "TOWER", "STATUE", "MONUMENT", "BRIDGE",
        "CAROUSEL", "FERRIS", "COASTER", "TRAM", "MONORAIL", "RAILWAY", "AMBULANCE", "FIRE",
        "POLICE", "TAXI", "TRACTOR", "TRUCK", "BICYCLE", "SCOOTER", "SKATEBOARD", "ROLLER", "BOAT",
        "FERRY", "YACHT", "HELICOPTER", "DRONE", "SATELLITE", "BELL", "HORN", "MIC", "RADIO", "TV",
        "TELEVISION", "VIDEO", "TAPE", "CASSETTE", "DISC", "DISK", "FLOPPY", "CD", "DVD", "TELEPHONE",
        "PAGER", "FAX", "PLUG", "PRINTER", "KEYBOARD", "MOUSE", "TRACKBALL", "JOYSTICK", "GAMEPAD",
        "ABACUS", "CALCULATOR", "MOVIE", "FILM", "PROJECTOR", "NOTEBOOK", "LEDGER", "PAPER", "SCROLL",
        "CLIPBOARD", "CALENDAR", "FOLDER", "BOX", "CABINET", "FILE", "NEWSPAPER", "MAGAZINE",
        "BOOKMARK", "LABEL", "TAG", "ENVELOPE", "MAIL", "POSTBOX", "MAILBOX", "NIB", "RULER",
        "TRIANGLE", "AXE", "PICK", "CLAMP", "BALANCE", "LINK", "CHAIN", "TUB", "RAZOR", "LOTION",
        "ROLL", "TOWEL", "BOOT", "SANDAL", "CAP", "HELMET", "MASK", "KIMONO", "SARI", "BIKINI",
        "CLOTHING", "PURSE", "HANDBAG", "POUCH", "BACKPACK", "BRIEFCASE", "LUGGAGE", "LIPSTICK",
        "PERFUME", "SCORE", "NOTE", "SAXOPHONE", "ACCORDION", "BANJO", "FLUTE", "SPEAKER", "MEGAPHONE",
        "BULLHORN", "FLASHLIGHT", "LANTERN", "DIODE", "WEAPON", "FIRECRACKER", "FIREWORK", "SPARKLER",
        "WAND"
    ]

    private static let symbolKeywords: Set<String> = [
        "SYMBOL", "SIGN", "ARROW", "MARK", "PUNCTUATION", "QUESTION", "EXCLAMATION", "PLUS", "MINUS", "DIVISION",
        "MULTIPLICATION", "HEART", "STAR", "SPARKLE", "CHECK", "CROSS", "WARNING", "RECYCLE", "KEYCAP", "DIGIT",
        "NUMBER", "REGIONAL INDICATOR", "EMOJI", "FLAG", "RAINBOW", "ZODIAC", "ARIES", "TAURUS", "GEMINI",
        "CANCER", "LEO", "VIRGO", "LIBRA", "SCORPIO", "SAGITTARIUS", "CAPRICORN", "AQUARIUS", "PISCES",
        "OPHIUCHUS", "STAR OF DAVID", "WHEEL OF DHARMA", "YIN YANG", "PEACE", "MENORAH", "POINTED STAR",
        "OM", "KAABA", "ROSARY", "BEADS", "ID", "BUTTON", "SQUARE", "CIRCLE", "TRIANGLE", "DIAMOND",
        "GEOMETRIC", "TIME", "HOUR", "MINUTE", "SECOND", "O'CLOCK", "A.M.", "P.M.", "CHART", "GRAPH",
        "TREND", "UPWARDS", "DOWNWARDS", "BAR", "PIE", "LINE", "CURVE", "WAVE", "DROPLET", "SWEAT",
        "DASH", "DOT", "COMMA", "COLON", "SEMICOLON", "QUOTATION", "APOSTROPHE", "BRACKET", "PARENTHESIS",
        "BRACE", "ANGLE", "TILDE", "MACRON", "UNDERSCORE", "SLASH", "BACKSLASH", "PIPE", "AT", "HASH",
        "DOLLAR", "PERCENT", "CARET", "AMPERSAND", "ASTERISK", "LOGICAL", "MATHEMATICAL", "INFINITY",
        "INTEGRAL", "APPROXIMATELY", "EQUAL", "NOT", "LESS", "GREATER", "PROPORTIONAL", "IDENTICAL",
        "EQUIVALENT", "STRICTLY", "SUBSET", "SUPERSET", "UNION", "INTERSECTION", "EMPTY", "MEMBER",
        "ELEMENT", "MEASURED", "SPHERICAL", "RIGHT", "PERPENDICULAR", "PARALLEL", "LETTERS", "WORDS",
        "IDEOGRAPH", "KANA", "KATAKANA", "HIRAGANA", "BOPOMOFO", "HANGUL", "HAN", "CJK", "RADICAL",
        "STROKE", "SYLLABLE", "CHARACTER", "LETTER", "ALPHABET", "LATIN", "GREEK", "CYRILLIC", "ARABIC",
        "HEBREW", "THAI", "DEVANAGARI", "BENGALI", "GURMUKHI", "GUJARATI", "ORIYA", "TAMIL", "TELUGU",
        "KANNADA", "MALAYALAM", "SINHALA", "LAO", "TIBETAN", "MYANMAR", "GEORGIAN", "ETHIOPIC", "CHEROKEE",
        "CANADIAN", "OGHAM", "RUNIC", "TAGALOG", "KHMER", "MONGOLIAN", "LIMBU", "TAI", "LE", "NEW",
        "BUGINESE", "BATAK", "SYLOTI", "PHAGS", "PA", "SAURASHTRA", "KAYAH", "LI", "REJANG", "JAVANESE",
        "CHAM", "VIET", "MEETEI", "MAYEK", "BAMUM", "LISU", "VAI", "GLAGOLITIC", "COPTIC", "ARMENIAN",
        "SYRIAC", "THANA", "NKO", "SAMARITAN", "MANDAIC"
    ]
}

private enum EmojiParser {
    static func emojis(in value: String) -> [String] {
        value.compactMap { character in
            character.isEmojiGlyph ? String(character) : nil
        }
    }

    static func limitedInput(from value: String, maximumEmojiCount: Int) -> String {
        emojis(in: value)
            .prefix(maximumEmojiCount)
            .joined(separator: " ")
    }
}

private extension Character {
    var isEmojiGlyph: Bool {
        unicodeScalars.contains {
            $0.properties.isEmojiPresentation || ($0.properties.isEmoji && $0.value > 0x238C)
        }
    }
}

// MARK: - Under the Hood

private struct NeuralNetworkSummary: View {
    private let facts: [(icon: String, color: Color, title: String, detail: String)] = [
        ("scalemass", .indigo, "Billions of connections", "Real models have hundreds of billions of connections — the diagrams shown above are just simple examples."),
        ("circle.badge.questionmark", .teal, "Passing the message", "Each part of the network looks at the clues it gets, makes a decision, and passes it to the next part."),
        ("arrow.clockwise", .orange, "Learning from mistakes", "The network practices on millions of examples, adjusting how it works until it stops making mistakes."),
        ("bolt.fill", .green, "Lightning fast", "This whole process happens in milliseconds every single time the AI generates a word."),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Under the Hood", systemImage: "gearshape.2")
                .font(.headline)
                .foregroundStyle(.teal)

            ForEach(facts, id: \.title) { fact in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: fact.icon)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(fact.color, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                        .padding(.top, 1)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(fact.title)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.primary)
                        Text(fact.detail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NeuralNetworkDemo()
}
