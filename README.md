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

### PINLockKit

Keychain-backed PIN storage (`PINService`) plus a fully decoupled `PINLockout` state machine implementing escalating brute-force lockout (30s → 60s → 5m → 15m).

```swift
import PINLockKit

let pin = PINService()
pin.save("1234")

switch pin.attempt("0000") {
case .success: break
case .incorrect(let remaining): print("\(remaining) attempts left")
case .lockedOut(let seconds): print("locked for \(seconds)s")
}
```

### ContentSafetyKit

Keyword-based crisis detection (`CrisisDetector`) and boundary-violation detection (`BoundaryDetector`) for assistant replies that must avoid diagnostic/prescriptive language. Both ship with sensible defaults and accept custom pattern lists.

```swift
import ContentSafetyKit

let crisis = CrisisDetector()
let result = crisis.check(userMessage)   // (isCrisis, level, pattern)

let boundary = BoundaryDetector()
let violation = boundary.check(replyText, context: .standard)
```

### GraphKit

Heuristic knowledge-graph extraction (`KnowledgeGraphExtractor`: emotions, people, and belief statements from free text, with edges wired between co-occurring entities) plus cross-session aggregation and export to Cytoscape/Neo4j JSON and GraphML (Gephi) via `GraphExporter`. Persistence-agnostic — pass your own node/edge value types via `SessionGraph`.

```swift
import GraphKit

let extraction = KnowledgeGraphExtractor().analyze("I feel anxious around my mother")
// extraction.nodes / extraction.edges — persist however you like

let graph = GraphExporter.aggregate(sessions: sessionGraphs)
let json = GraphExporter.cytoscapeJSON(graph: graph)
```

### AgentRouteKit

A generic confidence-scored routing primitive: register handlers that each report how confident they are about a context, and `Router` dispatches to the best match (with a fallback when nothing claims it).

```swift
import AgentRouteKit

let router = Router<String, String>(handlers: [myHandlerA, myHandlerB])
let output = await router.route(input, fallback: myDefaultHandler)
```

## Requirements

- iOS 17+ (both modules currently require iOS — `VoiceLoopKit` depends on `Speech`/`AVAudioSession`, which don't exist on macOS)
- Swift 5.9+

## Installation

Add via Swift Package Manager:

```swift
.package(url: "https://github.com/AnubisRooster/theraipist-kit", from: "0.1.0")
```

Then depend on whichever product(s) you need — `BYOKLLMKit`, `VoiceLoopKit`, `PINLockKit`, `ContentSafetyKit`, `GraphKit`, `AgentRouteKit` — in your target.

## Status

Early extraction — API surface may still shift before `1.0`. More modules (on-device GGUF inference via LLM.swift, an offline Cytoscape.js graph viewer) are planned; see the [therAIpist](https://github.com/AnubisRooster/therAIpist) README for the source implementations they'll be extracted from.

## License

Apache License 2.0 — see [LICENSE](LICENSE).
