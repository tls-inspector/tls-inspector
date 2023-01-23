import XCTest

final class CryptoEngineTest: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {}

    func testInspect() throws {
        let app = XCUIApplication()
        app.launch()

        let understoodButton = app.buttons["Understood"]
        if understoodButton.exists {
            understoodButton.tap()
        }

        app.navigationBars["TLS Inspector"].buttons["Options and About"].tap()
        app.tables["More Table"].cells["Options"].tap()
        app.tables["Options Table"].cells["Advanced Options"].tap()

        if app.alerts["Warning"].exists {
            app.alerts["Warning"].buttons["Dismiss"].tap()
        }

        app.tables["Advanced Options Table"].cells["network_framework"].tap()
        app.tables["Advanced Options Table"].cells["openssl"].tap()
    }
}
