import SwiftUI

struct SettingsView: View {
    @Environment(FoundationManager.self) private var manager
    @State private var draftKey = ""
    @State private var showingSaved = false
    @State private var showingKey = false
    @State private var connectionMessage: String?
    @State private var isTestingConnection = false

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
                        TextField("Endpoint", text: $manager.apiEndpoint)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                        TextField("Model", text: $manager.model)
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

                        Button("Save API key", action: saveKey)
                            .disabled(draftKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        Button {
                            testConnection()
                        } label: {
                            Label(isTestingConnection ? "Testing..." : "Test connection", systemImage: "bolt.horizontal.circle")
                        }
                        .disabled(isTestingConnection || !manager.hasAPIConfiguration)
                        if let connectionMessage {
                            Text(connectionMessage)
                                .font(.footnote)
                                .foregroundStyle(connectionMessage.hasPrefix("Connected") ? .green : .secondary)
                        }
                        Label(
                            manager.hasAPIConfiguration ? "API key saved securely" : "API key not configured",
                            systemImage: manager.hasAPIConfiguration ? "checkmark.shield.fill" : "exclamationmark.triangle"
                        )
                        .foregroundStyle(manager.hasAPIConfiguration ? .green : .secondary)
                    }
                }

            }
            .navigationTitle("Settings")
            .alert("Saved", isPresented: $showingSaved) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your API key is stored in the device Keychain.")
            }
        }
        .onAppear { draftKey = manager.apiKey }
    }

    private func saveKey() {
        manager.saveAPIKey(draftKey)
        showingSaved = true
    }

    private func testConnection() {
        isTestingConnection = true
        connectionMessage = nil
        Task {
            do {
                try await manager.testAPIConnection()
                connectionMessage = "Connected successfully."
            } catch {
                connectionMessage = error.localizedDescription
            }
            isTestingConnection = false
        }
    }
}

#Preview {
    SettingsView().environment(FoundationManager())
}
