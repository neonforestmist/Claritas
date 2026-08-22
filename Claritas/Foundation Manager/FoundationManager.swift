import Foundation
import FoundationModels
import Security

enum AIProvider: String, CaseIterable, Identifiable {
    case appleIntelligence = "Apple Intelligence"
    case openAI = "OpenAI"
    case openAICompatible = "OpenAI-compatible API"

    var id: Self { self }
}

struct APIConfiguration: Sendable {
    let provider: AIProvider
    let baseURL: String
    let model: String
    let apiKey: String
}

@Observable
final class FoundationManager {
    private let keychainKey = "com.claritas.openai-api-key"
    private let environment = ProcessInfo.processInfo.environment

    var provider: AIProvider {
        didSet { UserDefaults.standard.set(provider.rawValue, forKey: "claritas.ai-provider") }
    }
    var apiEndpoint: String
    var model: String
    var apiKey: String {
        get { KeychainStore.read(key: keychainKey) ?? environment["OPENAI_API_KEY"] ?? "" }
        set { KeychainStore.save(value: newValue, key: keychainKey) }
    }
    var notAvailableReason = "Checking model availability..."
    var isModelAvailable: Bool {
        notAvailableReason.isEmpty
    }
    
    init() {
        apiEndpoint = environment["OPENAI_API_ENDPOINT"] ?? "https://api.openai.com/v1"
        model = environment["OPENAI_MODEL"] ?? "gpt-5.6-luna"
        let savedProvider = UserDefaults.standard.string(forKey: "claritas.ai-provider")
        provider = AIProvider(rawValue: savedProvider ?? "") ?? (environment["OPENAI_API_KEY"] == nil ? .appleIntelligence : .openAI)
        checkIsAvailable()
    }

    var hasAPIConfiguration: Bool {
        provider != .appleIntelligence && !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var apiConfiguration: APIConfiguration {
        APIConfiguration(provider: provider, baseURL: apiEndpoint, model: model, apiKey: apiKey)
    }

    func saveAPIKey(_ value: String) {
        apiKey = value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    @MainActor
    func testAPIConnection() async throws {
        let baseURL = apiEndpoint.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let requestURL = baseURL.hasSuffix("/chat/completions") ? baseURL : "\(baseURL)/chat/completions"
        guard let url = URL(string: requestURL), !apiKey.isEmpty else {
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

enum OpenAICompatibleClient {
    static func complete(prompt: String, configuration: APIConfiguration) async throws -> String {
        let baseURL = configuration.baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let requestURL = baseURL.hasSuffix("/chat/completions") ? baseURL : "\(baseURL)/chat/completions"
        guard let url = URL(string: requestURL), !configuration.apiKey.isEmpty else {
            throw APIError.invalidConfiguration
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.setValue("Bearer \(configuration.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "model": configuration.model,
            "messages": [
                ["role": "system", "content": "You predict immediate next tokens. Follow the requested output format exactly."],
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 120,
            "temperature": 0.2
        ])

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw APIError.requestFailed
        }
        let decoded = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
        guard let content = decoded.choices.first?.message.content, !content.isEmpty else {
            throw APIError.emptyResponse
        }
        return content
    }
}

private struct ChatCompletionResponse: Decodable {
    let choices: [Choice]

    struct Choice: Decodable {
        let message: Message
    }

    struct Message: Decodable {
        let content: String?
    }
}

private enum APIError: LocalizedError {
    case invalidConfiguration
    case requestFailed
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .invalidConfiguration: return "Enter a valid endpoint and API key first."
        case .requestFailed: return "The API rejected the request. Check the endpoint, model, and key."
        case .emptyResponse: return "The API returned no usable response."
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
