//  Built by Manuel @StuFFmc Carrasco Molina on New year's Eve 2021 / January 2022
import XCTest
@testable import Alby

class AlbyTests: XCTestCase {
    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func testHasAtLeastOneBrowser() throws {
        XCTAssert(Browser.installed.count > 0)
    }

    func testInstall() throws {
        XCTAssert(Browser.installed.count > 0)
        if let browser = Browser.installed.first {
            if albyJsonExist(for: browser) {
                try! FileManager.default.removeItem(at: browser.albyJsonURL)
            }
            try browser.installOrRemove()
            XCTAssertTrue(albyJsonExist(for: browser))
            try browser.installOrRemove()
            XCTAssertFalse(albyJsonExist(for: browser))
        }
    }

    private func albyJsonExist(for browser: Browser) -> Bool {
        FileManager.default.fileExists(atPath: browser.albyJsonURL.path)
    }

    func testPerformanceExample() throws {
        measure {
            _ = Browser.all
        }
    }

}
