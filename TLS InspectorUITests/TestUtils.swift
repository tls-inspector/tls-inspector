import XCTest

func saveScreenshot(_ name: String) -> XCTAttachment {
    let fullScreenshot = XCUIScreen.main.screenshot()
    let screenshot = XCTAttachment(screenshot: fullScreenshot)
    screenshot.lifetime = .keepAlways
    screenshot.name = name
    return screenshot
}
