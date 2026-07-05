import XCTest
@testable import BYOKLLMKit

final class LLMKeychainStoreTests: XCTestCase {

    private func makeStore() -> LLMKeychainStore {
        // Unique service per test so runs never collide or leak state.
        LLMKeychainStore(service: "kit-tests.\(UUID().uuidString)")
    }

    func testSetThenGetRoundTrips() {
        let store = makeStore()
        XCTAssertTrue(store.set("sk-test-123", for: .openai))
        XCTAssertEqual(store.get(for: .openai), "sk-test-123")
        XCTAssertTrue(store.hasKey(for: .openai))
    }

    func testMissingKeyReturnsNil() {
        let store = makeStore()
        XCTAssertNil(store.get(for: .anthropic))
        XCTAssertFalse(store.hasKey(for: .anthropic))
    }

    func testSettingEmptyStringClearsKey() {
        let store = makeStore()
        store.set("sk-test-123", for: .groq)
        XCTAssertTrue(store.set("", for: .groq))
        XCTAssertNil(store.get(for: .groq))
    }

    func testDeleteRemovesKey() {
        let store = makeStore()
        store.set("sk-test-123", for: .deepseek)
        XCTAssertTrue(store.delete(for: .deepseek))
        XCTAssertNil(store.get(for: .deepseek))
    }

    func testKeysAreIsolatedPerProvider() {
        let store = makeStore()
        store.set("openai-key", for: .openai)
        store.set("groq-key", for: .groq)
        XCTAssertEqual(store.get(for: .openai), "openai-key")
        XCTAssertEqual(store.get(for: .groq), "groq-key")
    }
}
