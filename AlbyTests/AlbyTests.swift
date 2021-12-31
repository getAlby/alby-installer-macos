//  Built by Manuel @StuFFmc Carrasco Molina on New year's Eve 2021
import XCTest
@testable import Alby

class AlbyTests: XCTestCase {
    let alby = Alby()

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func testExample() throws {
        XCTAssertTrue(alby.seek())
    }

    func testPerformanceExample() throws {
        measure {
            _ = alby.seek()
        }
    }

}
