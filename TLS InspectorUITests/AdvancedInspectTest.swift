import XCTest

final class AdvancedInspectTest: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {}

    func testAdvancedInspect() throws {
        let app = XCUIApplication()
        app.launch()

        let understoodButton = app.buttons["Understood"]
        if understoodButton.exists {
            understoodButton.tap()
        }

        app.tables.buttons["Advanced Inspect Options Button"].tap()

        let advancedTable = app.tables["Advanced Inspect Table"]

        let domainInput = advancedTable.textFields["Domain Name or IP Address"]
        domainInput.tap()
        domainInput.typeText("one.one.one.one")

        let addressInput = advancedTable.textFields["Host IP Address"]
        addressInput.tap()
        addressInput.typeText("1.1.1.1")

        app.navigationBars["Advanced Inspect"].buttons["Done"].tap()
        app.tables.staticTexts["cloudflare-dns.com"].tap()
        app.navigationBars["cloudflare-dns.com"].buttons["one.one.one.one"].tap()
        app.tables.buttons["More Info"].tap()
        app.navigationBars["Trust Details"].buttons["Close"].tap()
    }
}
