import XCTest
@testable import VoiceLoopKit

final class VoiceLoopConfigTests: XCTestCase {

    func testDefaultsAreReasonable() {
        let config = VoiceLoopConfig()
        XCTAssertEqual(config.silenceInterval, 5.0)
        XCTAssertEqual(config.ttsRate, 0.5)
        XCTAssertEqual(config.ttsPitch, 1.0)
        XCTAssertEqual(config.voiceID, "")
    }

    func testSilenceIntervalIsClampedToLowerBound() {
        let config = VoiceLoopConfig(silenceInterval: 0.5)
        XCTAssertEqual(config.silenceInterval, 2.0)
    }

    func testSilenceIntervalIsClampedToUpperBound() {
        let config = VoiceLoopConfig(silenceInterval: 30)
        XCTAssertEqual(config.silenceInterval, 12.0)
    }

    func testSilenceIntervalWithinBoundsIsUnchanged() {
        let config = VoiceLoopConfig(silenceInterval: 7)
        XCTAssertEqual(config.silenceInterval, 7)
    }
}
