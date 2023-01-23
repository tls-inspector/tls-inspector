import XCTest

final class BasicInspectTest: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {}

    func testTrustedInspect() throws {
        let app = XCUIApplication()
        app.launch()

        let understoodButton = app.buttons["Understood"]
        if understoodButton.exists {
            understoodButton.tap()
        }

        let input = app.textFields["Domain Name or IP Address"]
        input.tap()
        input.typeText("tlsinspector.com")

        app.navigationBars.buttons["Inspect Domain"].tap()

        let certificateTable = app.tables["Certificate Table"]
        certificateTable.staticTexts["sni.cloudflaressl.com"].tap()
        app.navigationBars.firstMatch.buttons["tlsinspector.com"].tap()
        certificateTable.buttons["More Info"].tap()
        app.navigationBars["Trust Details"].buttons["Close"].tap()
    }

    func testExpiredInspect() throws {
        let app = XCUIApplication()
        app.launch()

        let understoodButton = app.buttons["Understood"]
        if understoodButton.exists {
            understoodButton.tap()
        }

        let input = app.textFields["Domain Name or IP Address"]
        input.tap()
        input.typeText("expired.badssl.com")

        app.navigationBars.buttons["Inspect Domain"].tap()

        let certificateTable = app.tables["Certificate Table"]
        certificateTable.staticTexts["*.badssl.com (Expired)"].tap()
        app.navigationBars.firstMatch.buttons["expired.badssl.com"].tap()
        certificateTable.buttons["More Info"].tap()
        app.navigationBars["Trust Details"].buttons["Close"].tap()
    }

    func testUntrustedInspect() throws {
        let app = XCUIApplication()
        app.launch()

        let understoodButton = app.buttons["Understood"]
        if understoodButton.exists {
            understoodButton.tap()
        }

        let input = app.textFields["Domain Name or IP Address"]
        input.tap()
        input.typeText("untrusted-root.badssl.com")

        app.navigationBars.buttons["Inspect Domain"].tap()

        let certificateTable = app.tables["Certificate Table"]
        certificateTable.staticTexts["sni.cloudflaressl.com"].tap()
        app.navigationBars.firstMatch.buttons["untrusted-root.badssl.com"].tap()
        certificateTable.buttons["More Info"].tap()
        app.navigationBars["Trust Details"].buttons["Close"].tap()
    }
}
