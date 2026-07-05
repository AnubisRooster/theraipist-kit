# therAIpist-kit

Reusable Swift Package Manager components extracted from [therAIpist](https://github.com/AnubisRooster/therAIpist), a private on-device iOS therapy companion app. These modules are domain-agnostic — nothing here is specific to therapy, journaling, or mental health — and are split out so other iOS/macOS projects can use them independently.

## Modules

### BYOKLLMKit

A "bring your own key" multi-provider LLM client. One `LLMSending` protocol, one `LLMService` actor implementation, routing to OpenRouter, OpenAI, Anthropic, DeepSeek, Groq, or Together AI based on a provider string — handling both the shared OpenAI-compatible chat-completions schema and Anthropic's distinct message schema. API keys are stored in the Keychain via `LLMKeychainStore`, never in `UserDefaults`.

```swift
import BYOKLLMKit

let keychain = LLMKeychainStore.shared
keychain.set("sk-...", for: .openai)

let llm = LLMService(keychain: keychain)
let reply = try await llm.sendMessage(
    provider: "openai",
    model: "gpt-4o-mini",
    messages: [LLMMessage(role: "user", content: "Hello!")]
)
```

### VoiceLoopKit

A hands-free, continuous voice-conversation loop: listen → (natural pause) → hand off → speak → resume listening. Wraps `SFSpeechRecognizer` + `AVAudioEngine` with silence-based endpointing, and stitches long monologues across `SFSpeechRecognizer`'s ~1-minute segment cap. `SpeechService` wraps `AVSpeechSynthesizer` for the speaking half.

```swift
import VoiceLoopKit

let controller = VoiceConversationController(
    config: VoiceLoopConfig(silenceInterval: 4, ttsRate: 0.5)
)
controller.start()

// Observe `controller.pendingUtterance`, run your own reply pipeline,
// then hand the reply back:
controller.deliverResponse("Here's my reply.")
```

## Requirements

- iOS 17+ / macOS 14+
- Swift 5.9+

## Installation

Add via Swift Package Manager:

```swift
.package(url: "https://github.com/AnubisRooster/theraipist-kit", from: "0.1.0")
```

Then depend on whichever product(s) you need — `BYOKLLMKit`, `VoiceLoopKit` — in your target.

## Status

Early extraction — API surface may still shift before `1.0`. More modules (on-device GGUF inference, knowledge-graph extraction/export, PIN lockout, crisis-keyword safety net) are planned; see the [therAIpist](https://github.com/AnubisRooster/therAIpist) README for the source implementations they'll be extracted from.

## License

Apache License 2.0 — see [LICENSE](LICENSE).
