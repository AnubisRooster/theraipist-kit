import Foundation

/// Result of a PIN entry attempt.
public enum PINAttemptResult: Equatable, Sendable {
    case success
    case incorrect(attemptsRemaining: Int)
    case lockedOut(secondsRemaining: Int)
}

/// Brute-force lockout state machine, kept separate from Keychain so it is
/// fully unit-testable with an injected `UserDefaults` and clock.
public struct PINLockout {
    let defaults: UserDefaults
    let maxAttempts: Int

    private let failKey  = "pin_fail_count"
    private let levelKey = "pin_lock_level"
    private let untilKey = "pin_lock_until"

    public init(defaults: UserDefaults = .standard, maxAttempts: Int = 5) {
        self.defaults = defaults
        self.maxAttempts = maxAttempts
    }

    /// Lockout duration for the Nth lockout (1-based), escalating then capped.
    public func lockoutDuration(level: Int) -> TimeInterval {
        switch level {
        case ..<1:  return 0
        case 1:     return 30
        case 2:     return 60
        case 3:     return 300
        default:    return 900
        }
    }

    /// Seconds remaining in the current lockout, or 0 if not locked out.
    public func lockoutRemaining(now: Date = Date()) -> Int {
        let until = Date(timeIntervalSince1970: defaults.double(forKey: untilKey))
        let remaining = until.timeIntervalSince(now)
        guard remaining > 0 else { return 0 }
        // The deadline is round-tripped through UserDefaults as a Double near
        // 1.7e9, which loses sub-microsecond precision. Shave a tiny epsilon
        // before rounding up so an exact value like 20.0 doesn't intermittently
        // round to 21 due to that floating-point noise.
        return Int((remaining - 0.0001).rounded(.up))
    }

    public var isLockedOut: Bool { lockoutRemaining() > 0 }

    /// Records a failed attempt and returns the resulting state.
    public mutating func registerFailure(now: Date = Date()) -> PINAttemptResult {
        if lockoutRemaining(now: now) > 0 {
            return .lockedOut(secondsRemaining: lockoutRemaining(now: now))
        }
        let fails = defaults.integer(forKey: failKey) + 1
        if fails >= maxAttempts {
            let level = defaults.integer(forKey: levelKey) + 1
            let duration = lockoutDuration(level: level)
            defaults.set(level, forKey: levelKey)
            defaults.set(now.addingTimeInterval(duration).timeIntervalSince1970, forKey: untilKey)
            defaults.set(0, forKey: failKey)
            return .lockedOut(secondsRemaining: Int(duration.rounded(.up)))
        }
        defaults.set(fails, forKey: failKey)
        return .incorrect(attemptsRemaining: maxAttempts - fails)
    }

    /// Clears all failure/lockout state after a correct PIN.
    public mutating func registerSuccess() {
        defaults.removeObject(forKey: failKey)
        defaults.removeObject(forKey: levelKey)
        defaults.removeObject(forKey: untilKey)
    }
}
