import SwiftUI

struct SettingsView: View {
    @Environment(FoundationManager.self) private var manager
    @State private var draftKey = ""
    @State private var showingKey = false

    var body: some View {
        @Bindable var manager = manager
        NavigationStack {
            Form {
                Section {
                    Picker("AI provider", selection: $manager.provider) {
                        ForEach(AIProvider.allCases) { provider in
                            Label(provider.rawValue, systemImage: provider == .appleIntelligence ? "apple.intelligence" : provider == .openAI ? "sparkles" : "network")
                                .tag(provider)
                        }
                    }
                    // Keep provider selection on the Settings screen. A navigation-style
                    // picker here can appear to pop back through the nested NavigationStack.
                    .pickerStyle(.inline)
                } header: {
                    Text("Intelligence")
                } footer: {
                    Text(manager.provider == .appleIntelligence
                         ? "Use Apple Intelligence on supported devices."
                         : manager.provider == .openAI
                         ? "Use OpenAI with the gpt-5.6-luna model."
                         : "Use any API that follows the OpenAI chat completions format.")
                }

                if manager.provider != .appleIntelligence {
                    Section(manager.provider == .openAI ? "OpenAI API" : "OpenAI-compatible API") {
                        TextField("Base URL", text: $manager.apiEndpoint)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                        TextField("Model ID", text: $manager.model)
                            .textInputAutocapitalization(.never)

                        HStack {
                            Group {
                                if showingKey {
                                    TextField("API key", text: $draftKey)
                                } else {
                                    SecureField("API key", text: $draftKey)
                                }
                            }
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            Button(showingKey ? "Hide" : "Show") { showingKey.toggle() }
                                .font(.caption)
                        }

                    }
                }

            }
            .navigationTitle("Settings")
        }
        .onAppear { draftKey = manager.apiKey }
        .onChange(of: draftKey) { _, newValue in
            manager.saveAPIKey(newValue)
        }
    }
}

#Preview {
    SettingsView().environment(FoundationManager())
}
