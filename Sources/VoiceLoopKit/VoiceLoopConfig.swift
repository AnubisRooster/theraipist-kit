import Foundation

/// Tunable parameters for a `VoiceConversationController` session. The host
/// app owns persistence (e.g. `UserDefaults`, a settings screen) and passes
/// the resolved values in — the controller itself has no storage opinions.
public struct VoiceLoopConfig: Sendable {
    /// Seconds of trailing silence that ends a turn. Clamped to 2...12.
    public var silenceInterval: TimeInterval
    public var ttsRate: Float
    public var ttsPitch: Float
    /// Falls back to the system's best available voice when empty.
    public var voiceID: String

    public init(silenceInterval: TimeInterval = 5.0,
               ttsRate: Float = 0.5,
               ttsPitch: Float = 1.0,
               voiceID: String = "") {
        self.silenceInterval = min(max(silenceInterval, 2.0), 12.0)
        self.ttsRate = ttsRate
        self.ttsPitch = ttsPitch
        self.voiceID = voiceID
    }
}
