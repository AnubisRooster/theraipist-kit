import Foundation
import Security

/// Stores per-provider API keys in the Keychain under the generic-password
/// class, keyed by the host app's bundle identifier and each provider's
/// `keychainKey`.
public final class LLMKeychainStore: @unchecked Sendable {
    public static let shared = LLMKeychainStore()

    private let service: String

    /// - Parameter service: Keychain service identifier. Defaults to the
    ///   host app's bundle identifier so keys are namespaced per app.
    public init(service: String = Bundle.main.bundleIdentifier ?? "BYOKLLMKit") {
        self.service = service
    }

    /// Saves `value` for `provider`, overwriting any existing value. Passing
    /// an empty string clears the stored key.
    @discardableResult
    public func set(_ value: String, for provider: LLMProvider) -> Bool {
        let data = Data(value.utf8)
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: provider.keychainKey,
        ]

        SecItemDelete(query as CFDictionary)

        guard !value.isEmpty else { return true } // Intentional clear.

        var addAttrs = query
        addAttrs[kSecValueData] = data
        let status = SecItemAdd(addAttrs as CFDictionary, nil)
        return status == errSecSuccess
    }

    /// Retrieves the stored value for `provider`, or `nil` if not set.
    public func get(for provider: LLMProvider) -> String? {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: provider.keychainKey,
            kSecReturnData:  true,
            kSecMatchLimit:  kSecMatchLimitOne,
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8),
              !string.isEmpty
        else { return nil }
        return string
    }

    /// Removes the stored key for `provider`.
    @discardableResult
    public func delete(for provider: LLMProvider) -> Bool {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: provider.keychainKey,
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    /// Returns `true` if a non-empty key exists for `provider`.
    public func hasKey(for provider: LLMProvider) -> Bool {
        get(for: provider) != nil
    }
}
