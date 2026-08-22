import Foundation
import FoundationModels
import Security

enum AIProvider: String, CaseIterable, Identifiable {
    case appleIntelligence = "Apple Intelligence"
    case openAICompatible = "OpenAI-compatible API"

    var id: Self { self }
}

@Observable
final class FoundationManager {
    private let keychainKey = "com.claritas.openai-api-key"

    var provider: AIProvider {
        didSet { UserDefaults.standard.set(provider.rawValue, forKey: "claritas.ai-provider") }
    }
    var apiEndpoint = "https://api.openai.com/v1/chat/completions"
    var model = "gpt-4o-mini"
    var apiKey: String {
        get { KeychainStore.read(key: keychainKey) ?? "" }
        set { KeychainStore.save(value: newValue, key: keychainKey) }
    }
    var notAvailableReason = "Checking model availability..."
    var isModelAvailable: Bool {
        notAvailableReason.isEmpty
    }
    
    init() {
        provider = AIProvider(rawValue: UserDefaults.standard.string(forKey: "claritas.ai-provider") ?? "") ?? .appleIntelligence
        checkIsAvailable()
    }

    var hasAPIConfiguration: Bool {
        provider == .openAICompatible && !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func saveAPIKey(_ value: String) {
        apiKey = value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    @MainActor
    func testAPIConnection() async throws {
        guard let url = URL(string: apiEndpoint), !apiKey.isEmpty else {
            throw APIError.invalidConfiguration
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 20
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "model": model,
            "messages": [["role": "user", "content": "Reply with OK."]],
            "max_tokens": 1
        ])

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw APIError.requestFailed
        }
    }
    
    @discardableResult
    func checkIsAvailable() -> Bool {
        switch SystemLanguageModel.default.availability {
        case .available:
            notAvailableReason = ""
        case .unavailable(.deviceNotEligible):
            notAvailableReason = "Upgrade to use Apple Intelligence"
        case .unavailable(.appleIntelligenceNotEnabled):
            notAvailableReason = "Enable Apple Intelligence in System Settings."
        case .unavailable(.modelNotReady):
            notAvailableReason = "Model not ready.  Downloding or temporarily unavailable. Please wait, ensure sufficient battery and Wi-Fi."
        case.unavailable(let unknownReason):
            notAvailableReason = "Model unavailable: \(String(describing: unknownReason))"
        }
        return isModelAvailable
    }
    
    func minimizeMarkDown(_ content: String) -> String {
        let tags = ["#", "##", "###", "####", "---"]
        var content = content
        tags.forEach { tag in
            content = content.replacingOccurrences(of: tag, with: "")
        }
        return content
    }
}

private enum APIError: LocalizedError {
    case invalidConfiguration
    case requestFailed

    var errorDescription: String? {
        switch self {
        case .invalidConfiguration: return "Enter a valid endpoint and API key first."
        case .requestFailed: return "The API rejected the request. Check the endpoint, model, and key."
        }
    }
}

private enum KeychainStore {
    static func save(value: String, key: String) {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    static func read(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
