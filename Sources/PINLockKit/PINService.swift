import Foundation
import Security

/// Stores and verifies a numeric PIN in the device Keychain.
///
/// The PIN never touches `UserDefaults` or iCloud; it lives only in the local
/// Keychain with `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`.
public final class PINService {
    public static let shared = PINService()

    private let service: String
    private let account = "user_pin"
    private var lockout: PINLockout

    /// - Parameter service: Keychain service identifier. Defaults to the
    ///   host app's bundle identifier so PINs are namespaced per app.
    public init(service: String = (Bundle.main.bundleIdentifier ?? "PINLockKit") + ".pin",
               defaults: UserDefaults = .standard) {
        self.service = service
        self.lockout = PINLockout(defaults: defaults)
    }

    // MARK: Public API

    public var isPINSetup: Bool { load() != nil }

    public var isLockedOut: Bool { lockout.isLockedOut }
    public var lockoutRemaining: Int { lockout.lockoutRemaining() }

    /// Verifies a PIN while enforcing brute-force lockout. Prefer this over
    /// `verify(_:)` at the UI layer.
    public func attempt(_ pin: String, now: Date = Date()) -> PINAttemptResult {
        let remaining = lockout.lockoutRemaining(now: now)
        if remaining > 0 { return .lockedOut(secondsRemaining: remaining) }
        if verify(pin) {
            lockout.registerSuccess()
            return .success
        }
        return lockout.registerFailure(now: now)
    }

    @discardableResult
    public func save(_ pin: String) -> Bool {
        guard let data = pin.data(using: .utf8) else { return false }
        delete()
        lockout.registerSuccess()
        let attrs: [CFString: Any] = [
            kSecClass:          kSecClassGenericPassword,
            kSecAttrService:    service,
            kSecAttrAccount:    account,
            kSecValueData:      data,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        ]
        return SecItemAdd(attrs as CFDictionary, nil) == errSecSuccess
    }

    public func verify(_ pin: String) -> Bool {
        guard let stored = load() else { return false }
        return stored == pin
    }

    public func delete() {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
        ]
        SecItemDelete(query as CFDictionary)
    }

    // MARK: Private

    private func load() -> String? {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData:  true,
            kSecMatchLimit:  kSecMatchLimitOne,
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data,
              let pin  = String(data: data, encoding: .utf8) else { return nil }
        return pin
    }
}
