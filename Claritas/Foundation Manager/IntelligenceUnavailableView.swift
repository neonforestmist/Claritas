import SwiftUI

struct IntelligenceUnavailableView: View {
    @Environment(FoundationManager.self) var manager
    var body: some View {
        ContentUnavailableView {
            Label("AI Not available", systemImage: "apple.intelligence")
        } description: {
            Text(manager.notAvailableReason)
        } actions: {
            Button("Try again") {
                manager.checkIsAvailable()
            }
            .buttonStyle(.bordered)
        }
    }
}

#Preview {
    IntelligenceUnavailableView()
        .environment(FoundationManager())
}
