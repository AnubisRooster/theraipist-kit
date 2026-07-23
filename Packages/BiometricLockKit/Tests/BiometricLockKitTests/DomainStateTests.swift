import XCTest
@testable import BiometricLockKit

/// The anti-tamper baseline: first success seeds it, matches pass, a changed
/// enrolled set is caught, and re-baselining recovers.
final class DomainStateTests: XCTestCase {

    private let stateA = Data("enrolled-set-A".utf8)
    private let stateB = Data("enrolled-set-B".utf8)

    func testFirstSuccessEstablishesBaseline() async {
        let store = InMemoryStore()
        let service = BiometricService(evaluator: FakeEvaluator(.success(domainState: stateA)), store: store)

        let result = await service.unlock(reason: "unlock")
        XCTAssertEqual(result, .success)
        XCTAssertEqual(store.load(), stateA, "first successful unlock should seed the baseline")
        XCTAssertTrue(service.hasBaseline)
    }

    func testUnchangedBaselinePasses() async {
        let store = InMemoryStore(stateA)
        let service = BiometricService(evaluator: FakeEvaluator(.success(domainState: stateA)), store: store)
        XCTAssertEqual(await service.unlock(reason: "unlock"), .success)
    }

    func testChangedEnrolledSetIsCaught() async {
        let store = InMemoryStore(stateA)
        let service = BiometricService(evaluator: FakeEvaluator(.success(domainState: stateB)), store: store)

        XCTAssertEqual(await service.unlock(reason: "unlock"), .biometryChanged)
        XCTAssertEqual(store.load(), stateA, "a tampered set must not overwrite the baseline")
    }

    func testAcceptCurrentBiometryRebaselinesOnNextUnlock() async {
        let store = InMemoryStore(stateA)
        // Simulate: user enrolled a new face (now state B), got .biometryChanged,
        // verified their PIN, and the host called acceptCurrentBiometry().
        let eval = FakeEvaluator([.success(domainState: stateB)])
        let service = BiometricService(evaluator: eval, store: store)

        XCTAssertEqual(await service.unlock(reason: "unlock"), .biometryChanged)
        service.acceptCurrentBiometry()
        XCTAssertFalse(service.hasBaseline)

        // Next successful unlock adopts B as the new baseline.
        XCTAssertEqual(await service.unlock(reason: "unlock"), .success)
        XCTAssertEqual(store.load(), stateB)
    }

    func testMissingDomainStateAllowsButDoesNotSeedBaseline() async {
        let store = InMemoryStore()
        let service = BiometricService(evaluator: FakeEvaluator(.success(domainState: nil)), store: store)

        XCTAssertEqual(await service.unlock(reason: "unlock"), .success)
        XCTAssertNil(store.load(), "a nil domain state shouldn't establish a baseline")
    }

    func testResetForgetsBaseline() async {
        let store = InMemoryStore(stateA)
        let service = BiometricService(evaluator: FakeEvaluator(.success(domainState: stateA)), store: store)
        service.reset()
        XCTAssertFalse(service.hasBaseline)
    }
}
