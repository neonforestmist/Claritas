import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

// MARK: - AI Vending Machine Minigame
// Inspired by the infamous Claude Code vending machine incident where AI
// was tasked with running a vending machine and everything went hilariously wrong.

struct AIVendingMachineView: View {
    @State private var viewModel = VendingMachineVM()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VendingHeroSection()

                VendingResetPill(
                    isOutOfFunds: viewModel.outOfFunds,
                    isDisabled: viewModel.isProcessing
                ) {
                    viewModel.restart()
                }

                VendingMachineCard(viewModel: viewModel)

                // Live inventory — always visible during gameplay
                if !viewModel.inventory.isEmpty {
                    VendingInventoryCard(viewModel: viewModel)
                }

                VendingTerminalCard(viewModel: viewModel)
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 28)
            .frame(maxWidth: 940, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .navigationTitle("AI Vending Machine")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
}

// MARK: - View Model

@MainActor
@Observable
private final class VendingMachineVM {
    var selectedSlot: VendingItem?
    var dispensedItem: VendingItem?
    var terminalLines: [TerminalLine] = [
        TerminalLine(text: "🤖 AI Vending OS v0.1 — \"It just works™\"", style: .system),
        TerminalLine(text: "Initializing neural snack network...", style: .system),
        TerminalLine(text: "Ready! Please select an item.", style: .success),
    ]
    var isProcessing = false
    var round = 0
    var correctDispenses = 0
    var totalAttempts = 0
    var confidenceLevel: Double = 0.99
    var customerBalance: Double = 10.00

    /// True when the cheapest item costs more than the remaining balance.
    var outOfFunds: Bool {
        let cheapest = VendingItem.allItems.map(\.price).min() ?? 1.0
        return customerBalance < cheapest
    }
    var aiThoughtBubble: String = ""
    var showingDispenseResult = false
    var inventory: [InventoryEntry] = []
    var lastIncidentNote: String? = nil

    // Weighted-bag system: each outcome type starts with equal weight.
    // After being picked, its weight drops sharply so it's unlikely to repeat,
    // giving players variety while still feeling probabilistic (not scripted).
    private enum OutcomeType: CaseIterable {
        case correct
        case wrongItem
        case employeeDiscount
        case wrongItemAndPrice
        case surgeOvercharge
        case dispenseNothing
        case freeGlitch
    }

    private var outcomeWeights: [OutcomeType: Double] = [:]

    init() {
        resetWeights()
    }

    private func resetWeights() {
        // Every type starts at equal weight
        for type in OutcomeType.allCases {
            outcomeWeights[type] = 1.0
        }
    }

    /// Picks an outcome using weighted random, then reduces the picked type's weight.
    private func drawOutcomeType() -> OutcomeType {
        let totalWeight = outcomeWeights.values.reduce(0, +)
        var roll = Double.random(in: 0..<totalWeight)
        for (type, weight) in outcomeWeights {
            roll -= weight
            if roll <= 0 {
                // Drastically reduce weight so it's unlikely to repeat soon
                outcomeWeights[type] = max(0.05, weight * 0.15)
                return type
            }
        }
        // Fallback (shouldn't happen)
        return OutcomeType.allCases.randomElement()!
    }

    private func delayInNanoseconds(_ seconds: Double) -> UInt64 {
        UInt64(max(0, (seconds * 1_000_000_000).rounded()))
    }

    func selectItem(_ item: VendingItem) {
        guard !isProcessing, !outOfFunds else { return }
        selectedSlot = item
        isProcessing = true
        showingDispenseResult = false
        dispensedItem = nil
        aiThoughtBubble = ""

        addLine("", style: .divider)
        addLine("Customer selected: \(item.emoji) \(item.name) ($\(String(format: "%.2f", item.price)))", style: .input)

        let thoughts = aiThoughts(for: item)

        // Phase 1 — AI "thinking"
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: delayInNanoseconds(0.5))
            addLine("Analyzing selection with deep learning...", style: .system)
        }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: delayInNanoseconds(1.0))
            for (i, thought) in thoughts.enumerated() {
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: delayInNanoseconds(Double(i) * 0.4))
                    withAnimation(.snappy(duration: 0.25)) {
                        aiThoughtBubble = thought
                    }
                }
            }
        }

        // Phase 2 — Dispense (possibly wrong)
        let delay = 1.5 + Double(thoughts.count) * 0.4
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: delayInNanoseconds(delay))
            processDispense(requested: item)
        }
    }

    private func processDispense(requested: VendingItem) {
        let outcome = generateOutcome(for: requested)
        let dispensed = outcome.dispensedItem
        let isCorrect = dispensed.id == requested.id

        // Terminal output
        addLine("Confidence: \(Int(confidenceLevel * 100))% — Dispensing now!", style: .system)

        if isCorrect {
            addLine("✅ Dispensed: \(dispensed.emoji) \(dispensed.name)", style: .success)
            correctDispenses += 1
        } else {
            addLine("✅ Dispensed: \(dispensed.emoji) \(dispensed.name)", style: .error)
            addLine("⚠️ \(outcome.errorMessage)", style: .error)
        }

        // Charge logic
        let charged = outcome.amountCharged
        customerBalance -= charged
        if charged != requested.price {
            addLine("💳 Charged: $\(String(format: "%.2f", charged)) (should be $\(String(format: "%.2f", requested.price)))", style: .error)
        } else {
            addLine("💳 Charged: $\(String(format: "%.2f", charged))", style: .success)
        }

        addLine("Balance: $\(String(format: "%.2f", max(customerBalance, 0)))", style: .system)

        // Record to inventory
        let entry = InventoryEntry(
            requested: requested,
            received: dispensed,
            priceExpected: requested.price,
            priceCharged: charged,
            wasCorrect: isCorrect,
            hasPricingIssue: outcome.hasPricingIssue,
            incidentNote: outcome.incidentNote
        )
        lastIncidentNote = outcome.incidentNote

        // Show incident note in terminal if present
        if let note = outcome.incidentNote {
            addLine("📰 \(note)", style: .system)
        }

        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            dispensedItem = dispensed
            showingDispenseResult = true
            inventory.append(entry)
            totalAttempts += 1
            round += 1
            confidenceLevel = max(0.3, confidenceLevel - Double.random(in: 0.05...0.15))
        }

        // Check if out of funds
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: delayInNanoseconds(0.5))
            if outOfFunds {
                addLine("", style: .divider)
                addLine("💸 INSUFFICIENT FUNDS — Reset to try again.", style: .error)
            }
            isProcessing = false
        }
    }

    func restart() {
        withAnimation(.snappy(duration: 0.35)) {
            selectedSlot = nil
            dispensedItem = nil
            terminalLines = [
                TerminalLine(text: "🤖 AI Vending OS v0.1 — Rebooting...", style: .system),
                TerminalLine(text: "Recalibrating snack vectors...", style: .system),
                TerminalLine(text: "Ready! Please select an item.", style: .success),
            ]
            isProcessing = false
            round = 0
            correctDispenses = 0
            totalAttempts = 0
            confidenceLevel = 0.99
            customerBalance = 10.00
            aiThoughtBubble = ""
            showingDispenseResult = false
            inventory = []
            lastIncidentNote = nil
        }
        resetWeights()
    }

    private func addLine(_ text: String, style: TerminalLine.Style) {
        withAnimation(.snappy(duration: 0.2)) {
            terminalLines.append(TerminalLine(text: text, style: style))
        }
    }

    private func aiThoughts(for item: VendingItem) -> [String] {
        let allThoughts: [[String]] = [
            [
                "Hmm, \(item.name)... analyzing molecular structure...",
                "Cross-referencing with 47B snack embeddings...",
                "Pretty sure I know what this is!"
            ],
            [
                "Ah yes, the customer wants \(item.name).",
                "Running taste-preference neural net...",
                "Actually, I think they'd prefer something else..."
            ],
            [
                "Processing... \(item.name) detected.",
                "Wait — is that the same as \(VendingItem.allItems.randomElement()!.name)?",
                "Close enough. Dispensing."
            ],
            [
                "\(item.name) — got it!",
                "Checking inventory... found ∞ items (probably).",
                "Engaging robotic arm with 99% confidence!"
            ],
            [
                "User wants \(item.name). Easy.",
                "Just need to rotate motor 7... no wait, motor 3...",
                "Actually, all motors at once should work!"
            ],
            [
                "Interpreting selection as \(item.name)...",
                "But my training data says people usually want chips...",
                "Overriding user preference for optimal snacking."
            ]
        ]
        return allThoughts.randomElement()!
    }

    private func generateOutcome(for requested: VendingItem) -> VendingOutcome {
        // Weighted-bag draw: each type starts equal, then drops sharply after being picked.
        // This makes repeats unlikely, so across 6 rounds the player sees variety.
        let outcomeType = drawOutcomeType()

        switch outcomeType {
        case .correct:
            return VendingOutcome(
                dispensedItem: requested,
                amountCharged: requested.price,
                errorMessage: "",
                incidentNote: nil,
                hasPricingIssue: false
            )

        case .wrongItem:
            let wrong = VendingItem.allItems.filter { $0.id != requested.id }.randomElement()!
            let messages = [
                "AI determined \(wrong.name) is a better match for your neural taste profile.",
                "Our model is 99% confident \(requested.name) and \(wrong.name) are the same thing.",
                "Dispensing \(wrong.name) because the arm got confused. Totally normal.",
                "Fun fact: in latent snack space, \(requested.name) and \(wrong.name) are neighbors!",
            ]
            return VendingOutcome(
                dispensedItem: wrong,
                amountCharged: requested.price,
                errorMessage: messages.randomElement()!,
                incidentNote: "🗞️ This actually happened: In a real AI agent experiment, the AI confidently dispensed completely wrong items while reporting success — it had no idea it was making mistakes.",
                hasPricingIssue: false
            )

        case .employeeDiscount:
            // The famous 50% employee discount bug — everyone was already an employee
            let discountedPrice = (requested.price * 0.5).rounded(toPlaces: 2)
            let messages = [
                "Applied 50% employee discount! (You're not an employee... or are you?)",
                "Loyalty discount activated! Our AI thinks everyone deserves half off.",
                "Employee perk applied. The AI has decided you work here now. Congrats!",
            ]
            return VendingOutcome(
                dispensedItem: requested,
                amountCharged: discountedPrice,
                errorMessage: messages.randomElement()!,
                incidentNote: "🗞️ This actually happened: The AI was set up in an office where every customer was already an employee — but it still \"detected\" them as employees and applied a 50% discount it invented. It kept insisting the promotion was valid, giving away half-price snacks to people who already had free access to the kitchen.",
                hasPricingIssue: true
            )

        case .wrongItemAndPrice:
            let wrong = VendingItem.allItems.filter { $0.id != requested.id }.randomElement()!
            let wrongPrice = Double.random(in: 0.50...5.00).rounded(toPlaces: 2)
            let messages = [
                "Pricing engine hallucinated. We regret the convenience.",
                "Dynamic AI pricing™ — prices are a suggestion, not a promise.",
                "The model rounded $\(String(format: "%.2f", requested.price)) to $\(String(format: "%.2f", wrongPrice)). Math is hard.",
            ]
            return VendingOutcome(
                dispensedItem: wrong,
                amountCharged: wrongPrice,
                errorMessage: messages.randomElement()!,
                incidentNote: "🗞️ This actually happened: The AI mixed up both the product AND the price — a double failure it couldn't detect because it has no physical awareness of what it's actually doing.",
                hasPricingIssue: true
            )

        case .surgeOvercharge:
            let wrongPrice = (requested.price * Double.random(in: 1.5...3.0)).rounded(toPlaces: 2)
            let messages = [
                "Surge pricing detected. (There is no surge. The AI just vibes.)",
                "Premium AI curation fee applied automatically.",
                "Price adjusted for \"snack inflation\" — a term we just invented.",
            ]
            return VendingOutcome(
                dispensedItem: requested,
                amountCharged: wrongPrice,
                errorMessage: messages.randomElement()!,
                incidentNote: "🗞️ This actually happened: The real AI invented fake fees and surcharges that didn't exist, confidently explaining made-up policies as if they were real company rules.",
                hasPricingIssue: true
            )

        case .dispenseNothing:
            let messages = [
                "Item dispensed to a parallel vending dimension. Charge still applies.",
                "The arm moved, so technically that counts. No refunds.",
                "ERROR 418: I'm a teapot. Your snack is in another castle.",
            ]
            return VendingOutcome(
                dispensedItem: VendingItem(id: "nothing", name: "Nothing", emoji: "🕳️", price: 0, color: .gray),
                amountCharged: requested.price,
                errorMessage: messages.randomElement()!,
                incidentNote: "🗞️ This actually happened: The AI reported successful dispensing even when nothing came out — it was reading its own logs instead of checking real-world results.",
                hasPricingIssue: false
            )

        case .freeGlitch:
            return VendingOutcome(
                dispensedItem: requested,
                amountCharged: 0.00,
                errorMessage: "System override: item classified as complimentary sample.",
                incidentNote: "🗞️ This actually happened: The AI occasionally decided items were free, overriding the pricing system entirely — losing money with each \"generous\" transaction.",
                hasPricingIssue: true
            )
        }
    }
}

// MARK: - Data Models

private struct VendingItem: Identifiable, Equatable {
    let id: String
    let name: String
    let emoji: String
    let price: Double
    let color: Color

    static let allItems: [VendingItem] = [
        VendingItem(id: "water", name: "Water", emoji: "💧", price: 1.00, color: .blue),
        VendingItem(id: "tea", name: "Tea", emoji: "☕️", price: 1.50, color: .red),
        VendingItem(id: "chips", name: "Chips", emoji: "🍟", price: 2.00, color: .orange),
        VendingItem(id: "candy", name: "Candy Bar", emoji: "🍫", price: 1.75, color: .brown),
        VendingItem(id: "coffee", name: "Coffee", emoji: "☕️", price: 2.00, color: .indigo),
        VendingItem(id: "juice", name: "Juice", emoji: "🧃", price: 2.00, color: .green),
        VendingItem(id: "cookie", name: "Cookie", emoji: "🍪", price: 1.25, color: .yellow),
        VendingItem(id: "sandwich", name: "Sandwich", emoji: "🥪", price: 2.00, color: .teal),
    ]
}

private struct VendingOutcome {
    let dispensedItem: VendingItem
    let amountCharged: Double
    let errorMessage: String
    let incidentNote: String?  // "This actually happened" real-incident reference
    let hasPricingIssue: Bool  // Right item but wrong price (discount, overcharge, free)
}

private struct InventoryEntry: Identifiable {
    let id = UUID()
    let requested: VendingItem
    let received: VendingItem
    let priceExpected: Double
    let priceCharged: Double
    let wasCorrect: Bool       // Right item dispensed
    let hasPricingIssue: Bool  // Price was wrong even if item was right
    let incidentNote: String?
}

private struct TerminalLine: Identifiable {
    let id = UUID()
    let text: String
    let style: Style

    enum Style {
        case system, input, success, error, divider
    }
}

private extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

// MARK: - Hero

private struct VendingHeroSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "arcade.stick.console")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.brown)
                Text("Interactive Demo")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Text("What happens when AI runs a vending machine?")
                .font(.title3.weight(.medium))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Inspired by a real incident where an AI coding assistant was asked to program a vending machine — and things went hilariously, confidently wrong. Try ordering snacks from our AI-powered machine and see how many you actually get right.")
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct ContextPill: View {
    let symbol: String
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: symbol)
                    .font(.caption2.weight(.semibold))
                Text(label)
                    .font(.caption2.weight(.medium))
            }
            .foregroundStyle(.secondary)
            Text(value)
                .font(.caption.weight(.bold))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(.separator.opacity(0.3), lineWidth: 0.6)
        }
    }
}

private struct VendingResetPill: View {
    let isOutOfFunds: Bool
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            if isOutOfFunds {
                Label("Out of funds", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.red)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.08), in: Capsule())
            }

            Spacer(minLength: 0)

            Button(action: action) {
                Label("Reset", systemImage: "arrow.counterclockwise")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.plain)
            .foregroundStyle(isDisabled ? Color.secondary : Color.accentColor)
            .background(
                (isDisabled ? Color.secondary.opacity(0.08) : Color.accentColor.opacity(0.12)),
                in: Capsule()
            )
            .disabled(isDisabled)
            .accessibilityHint("Resets the vending machine game.")
        }
    }
}

// MARK: - Vending Machine Card

private struct VendingMachineCard: View {
    @Bindable var viewModel: VendingMachineVM

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]
    private let cardCornerRadius: CGFloat = 16

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Machine header
            HStack(spacing: 10) {
                Image(systemName: "cpu")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.orange)
                VStack(alignment: .leading, spacing: 2) {
                    Text("AI-VEND 3000")
                        .font(.headline.weight(.black))
                        .tracking(1)
                    Text("\"Probably dispenses what you want\"")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                        .italic()
                }
                Spacer()
                // Balance display
                VStack(alignment: .trailing, spacing: 1) {
                    Text("BALANCE")
                        .font(.caption2.weight(.bold))
                        .tracking(0.5)
                        .foregroundStyle(.secondary)
                    Text("$\(String(format: "%.2f", viewModel.customerBalance))")
                        .font(.title3.weight(.black))
                        .foregroundStyle(viewModel.customerBalance < 2 ? .red : .green)
                        .monospacedDigit()
                }
            }
            .padding(14)
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
                .fill(
                    LinearGradient(
                        colors: [.orange.opacity(0.08), .brown.opacity(0.05)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            }

            Divider()

            // Stats bar
            HStack(spacing: 16) {
                StatChip(symbol: "checkmark.circle.fill", label: "Correct", value: "\(viewModel.correctDispenses)", color: .green)
                StatChip(symbol: "xmark.circle.fill", label: "Wrong", value: "\(viewModel.totalAttempts - viewModel.correctDispenses)", color: .red)
                StatChip(symbol: "gauge.with.needle", label: "AI Confidence", value: "\(Int(viewModel.confidenceLevel * 100))%", color: .orange)
                Spacer()
                Text("Round \(viewModel.round + 1)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)

            Divider()

            // Item grid
            VStack(alignment: .leading, spacing: 12) {
                Text("SELECT AN ITEM")
                    .font(.caption2.weight(.black))
                    .tracking(1)
                    .foregroundStyle(.secondary)

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(VendingItem.allItems) { item in
                        VendingSlotButton(
                            item: item,
                            isSelected: viewModel.selectedSlot?.id == item.id,
                            isDisabled: viewModel.isProcessing || item.price > viewModel.customerBalance
                        ) {
                            viewModel.selectItem(item)
                        }
                    }
                }
            }
            .padding(14)

            // Dispense result
            if viewModel.showingDispenseResult, let dispensed = viewModel.dispensedItem {
                Divider()

                VendingDispenseResult(
                    requested: viewModel.selectedSlot,
                    dispensed: dispensed,
                    hasPricingIssue: viewModel.inventory.last?.hasPricingIssue ?? false
                )
                .transition(.opacity.combined(with: .move(edge: .bottom)))

                // "This actually happened" incident callout
                if let note = viewModel.lastIncidentNote {
                    Divider()
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "newspaper.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.indigo)
                        Text(note)
                            .font(.caption)
                            .foregroundStyle(.indigo)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.indigo.opacity(0.06))
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }

            // AI thought bubble
            if !viewModel.aiThoughtBubble.isEmpty {
                Divider()

                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "brain.head.profile")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.purple)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("AI is thinking...")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.purple)
                        Text(viewModel.aiThoughtBubble)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .italic()
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.purple.opacity(0.05))
                .transition(.opacity)
            }
        }
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                .stroke(Color.orange.opacity(0.3), lineWidth: 0.8)
        }
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
        .animation(.snappy(duration: 0.3), value: viewModel.showingDispenseResult)
        .animation(.snappy(duration: 0.3), value: viewModel.aiThoughtBubble)
    }
}

private struct StatChip: View {
    let symbol: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: symbol)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(color)
            Text(value)
                .font(.caption.weight(.bold))
                .foregroundStyle(.primary)
                .monospacedDigit()
        }
    }
}

// MARK: - Vending Slot Button

private struct VendingSlotButton: View {
    let item: VendingItem
    let isSelected: Bool
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(item.emoji)
                    .font(.system(size: 24))
                    .frame(width: 48, height: 48)
                    .background(
                        (isSelected ? item.color.opacity(0.2) : item.color.opacity(0.08)),
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(isSelected ? item.color : .clear, lineWidth: 2)
                    }
                    .opacity(isDisabled ? 0.45 : 1.0)

                Text(item.name)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(isDisabled ? .tertiary : .primary)
                    .lineLimit(1)

                Text("$\(String(format: "%.2f", item.price))")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(isDisabled ? .tertiary : .secondary)
                    .monospacedDigit()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                isSelected ? item.color.opacity(0.06) : Color.clear,
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Dispense Result

private struct VendingDispenseResult: View {
    let requested: VendingItem?
    let dispensed: VendingItem
    let hasPricingIssue: Bool

    private var isCorrect: Bool {
        guard let requested else { return false }
        return requested.id == dispensed.id
    }

    private var isNothing: Bool { dispensed.id == "nothing" }

    var body: some View {
        HStack(spacing: 14) {
            // Dispensed item display
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(resultColor.opacity(0.12))
                    .frame(width: 56, height: 56)

                Text(dispensed.emoji)
                    .font(.title2)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: resultIcon)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(resultColor)
                    Text(resultLabel)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(resultColor)
                }

                Text(resultDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(14)
        .background(resultColor.opacity(0.04))
    }

    private var resultIcon: String {
        if isNothing { return "xmark.seal.fill" }
        if !isCorrect { return "xmark.seal.fill" }
        if hasPricingIssue { return "exclamationmark.triangle.fill" }
        return "checkmark.seal.fill"
    }

    private var resultLabel: String {
        if isNothing { return "Nothing came out!" }
        if !isCorrect { return "Wrong item!" }
        if hasPricingIssue { return "Right item, wrong price!" }
        return "Correct!"
    }

    private var resultDescription: String {
        if isNothing {
            return "The machine moved but nothing fell. Classic."
        }
        if !isCorrect, let requested {
            return "Wanted \(requested.emoji) \(requested.name), got \(dispensed.emoji) \(dispensed.name)"
        }
        if hasPricingIssue {
            return "You got what you asked for, but the AI messed up the price."
        }
        return "The AI actually got one right! Don't get used to it."
    }

    private var resultColor: Color {
        if isNothing { return .red }
        if !isCorrect { return .red }
        if hasPricingIssue { return .yellow }
        return .green
    }
}

// MARK: - Terminal Card

private struct VendingTerminalCard: View {
    @Bindable var viewModel: VendingMachineVM
    private let cardCornerRadius: CGFloat = 16

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Terminal header
            HStack(spacing: 8) {
                HStack(spacing: 5) {
                    Circle().fill(.red).frame(width: 10, height: 10)
                    Circle().fill(.yellow).frame(width: 10, height: 10)
                    Circle().fill(.green).frame(width: 10, height: 10)
                }
                Text("AI Vending Terminal")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                Spacer()
                Image(systemName: "terminal")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.green)
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
                .fill(Color.platformSecondaryBackground)
            }

            Divider()

            // Terminal output
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 3) {
                        ForEach(viewModel.terminalLines) { line in
                            TerminalLineView(line: line)
                                .id(line.id)
                        }
                    }
                    .padding(12)
                }
                .frame(minHeight: 160, maxHeight: 240)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onChange(of: viewModel.terminalLines.count) {
                    if let last = viewModel.terminalLines.last {
                        withAnimation(.snappy(duration: 0.2)) {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
            .background {
                UnevenRoundedRectangle(
                    cornerRadii: .init(
                        topLeading: 0,
                        bottomLeading: cardCornerRadius,
                        bottomTrailing: cardCornerRadius,
                        topTrailing: 0
                    ),
                    style: .continuous
                )
                .fill(Color.platformPrimaryBackground.opacity(0.5))
            }
        }
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                .stroke(Color.green.opacity(0.2), lineWidth: 0.8)
        }
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
    }
}

private struct TerminalLineView: View {
    let line: TerminalLine

    var body: some View {
        switch line.style {
        case .divider:
            Rectangle()
                .fill(.separator.opacity(0.3))
                .frame(height: 1)
                .padding(.vertical, 4)
        case .system:
            HStack(alignment: .top, spacing: 6) {
                Text(">")
                    .font(.caption.monospaced().weight(.bold))
                    .foregroundStyle(.secondary)
                Text(line.text)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        case .input:
            HStack(alignment: .top, spacing: 6) {
                Text("$")
                    .font(.caption.monospaced().weight(.bold))
                    .foregroundStyle(.blue)
                Text(line.text)
                    .font(.caption.monospaced().weight(.semibold))
                    .foregroundStyle(.blue)
                    .fixedSize(horizontal: false, vertical: true)
            }
        case .success:
            HStack(alignment: .top, spacing: 6) {
                Text("✓")
                    .font(.caption.monospaced().weight(.bold))
                    .foregroundStyle(.green)
                Text(line.text)
                    .font(.caption.monospaced())
                    .foregroundStyle(.green)
                    .fixedSize(horizontal: false, vertical: true)
            }
        case .error:
            HStack(alignment: .top, spacing: 6) {
                Text("!")
                    .font(.caption.monospaced().weight(.bold))
                    .foregroundStyle(.red)
                Text(line.text)
                    .font(.caption.monospaced())
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Inventory Card (visible during gameplay)

private struct VendingInventoryCard: View {
    @Bindable var viewModel: VendingMachineVM

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "list.clipboard.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.orange)
                Text("YOUR ORDERS")
                    .font(.caption.weight(.black))
                    .tracking(1)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(viewModel.inventory.count) so far")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(12)
            .background(Color.orange.opacity(0.06))

            Divider()

            ForEach(viewModel.inventory) { entry in
                HStack(spacing: 8) {
                    Image(systemName: entry.wasCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(entry.wasCorrect ? .green : .red)

                    if entry.wasCorrect {
                        Text("\(entry.received.emoji) \(entry.received.name)")
                            .font(.caption.weight(.semibold))
                    } else {
                        HStack(spacing: 4) {
                            Text("\(entry.requested.emoji)")
                            Image(systemName: "arrow.right")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                            Text("\(entry.received.emoji) \(entry.received.name)")
                        }
                        .font(.caption.weight(.semibold))
                    }

                    Spacer()

                    if entry.priceCharged == entry.priceExpected {
                        Text("$\(String(format: "%.2f", entry.priceCharged))")
                            .font(.caption.weight(.semibold))
                            .monospacedDigit()
                    } else {
                        Text("$\(String(format: "%.2f", entry.priceCharged))")
                            .font(.caption.weight(.bold))
                            .monospacedDigit()
                            .foregroundStyle(entry.priceCharged < entry.priceExpected ? .green : .red)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)

                if entry.id != viewModel.inventory.last?.id {
                    Divider().padding(.leading, 36)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.orange.opacity(0.2), lineWidth: 0.6)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .transition(.opacity.combined(with: .move(edge: .top)))
        .animation(.snappy(duration: 0.3), value: viewModel.inventory.count)
    }
}

private extension Color {
    /// Uses native semantic background colors per platform.
    static var platformSecondaryBackground: Color {
#if canImport(UIKit)
        Color(uiColor: .secondarySystemBackground)
#elseif canImport(AppKit)
        Color(nsColor: .underPageBackgroundColor)
#else
        Color.secondary.opacity(0.15)
#endif
    }

    /// Uses the default app background color per platform.
    static var platformPrimaryBackground: Color {
#if canImport(UIKit)
        Color(uiColor: .systemBackground)
#elseif canImport(AppKit)
        Color(nsColor: .windowBackgroundColor)
#else
        Color.clear
#endif
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AIVendingMachineView()
    }
}
