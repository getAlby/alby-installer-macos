//  Built by Manuel @StuFFmc Carrasco Molina on New year's Eve 2021
import XCTest
@testable import Alby

class AlbyTests: XCTestCase {
    let alby = Alby()

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func testSeek() throws {
        XCTAssertTrue(alby.seek())
    }

    func testInstall() throws {
        XCTAssertNoThrow(try alby.install())
    }

    func testPerformanceExample() throws {
        measure {
            _ = alby.seek()
        }
    }

}
