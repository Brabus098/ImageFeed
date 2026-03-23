//  ProfileUITest.swift

import XCTest

class ProfileUiTest: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments.append("isUITest")
        app.launch()
    }
    
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.staticTexts["Владимир Ольшевский"].exists)
        XCTAssertTrue(app.staticTexts["@vovan098"].exists)
        
        app.buttons["Exit"].tap()
        
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }
}
