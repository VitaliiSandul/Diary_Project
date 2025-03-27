import XCTest

final class DiaryUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }

    func test_button_SaveData_to_json() throws {
        let diaryNavBar = app.navigationBars["Diary"]
        let saveDataButton = diaryNavBar/*@START_MENU_TOKEN@*/.staticTexts["Save Data"]/*[[".otherElements[\"Save Data\"]",".buttons[\"Save Data\"].staticTexts[\"Save Data\"]",".staticTexts[\"Save Data\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        saveDataButton.tap()
        
        XCTAssert(app.navigationBars["Diary"].exists)
    }
    
    func test_button_Plus() throws {
        let diaryNavBar = app.navigationBars["Diary"]
        let plusButton = diaryNavBar/*@START_MENU_TOKEN@*/.buttons["plus"]/*[[".otherElements[\"Add\"]",".buttons[\"Add\"]",".buttons[\"plus\"]",".otherElements[\"plus\"]"],[[[-1,2],[-1,1],[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        plusButton.tap()
        
        XCTAssert(app.navigationBars["Add entry"].exists)
    }
    
    func test_button_Save_in_AddEntry() throws {
        let diaryNavigationBar = app.navigationBars["Diary"]
        let plusButton = diaryNavigationBar.buttons["plus"]
        plusButton.tap()
        
        let addEntryNavBar = app.navigationBars["Add entry"]
        let saveButton = addEntryNavBar/*@START_MENU_TOKEN@*/.buttons["Save"]/*[[".otherElements[\"Save\"].buttons[\"Save\"]",".buttons[\"Save\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        saveButton.tap()
        
        XCTAssert(diaryNavigationBar.staticTexts["Diary"].exists)
    }
    
    func test_calendar_in_AddEntry() throws {
        let diaryNavigationBar = app.navigationBars["Diary"]
        let plusButton = diaryNavigationBar.buttons["plus"]
        plusButton.tap()
        
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery/*@START_MENU_TOKEN@*/.buttons["calendar"]/*[[".cells",".buttons[\"Calendar\"]",".buttons[\"calendar\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        collectionViewsQuery.datePickers["Select a date"].staticTexts["December 2024"].tap()
        collectionViewsQuery.datePickers["Select a date"].datePickers.pickerWheels["2024"].tap()
        collectionViewsQuery.datePickers["Select a date"].datePickers.pickerWheels["December"].tap()
        collectionViewsQuery.datePickers["Select a date"].staticTexts["December 2024"].tap()
        collectionViewsQuery.datePickers["Select a date"].collectionViews.staticTexts["9"].tap()
        
        XCTAssert(collectionViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["09 January"]/*[[".cells.staticTexts[\"09 January\"]",".staticTexts[\"09 January\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.exists || collectionViewsQuery.staticTexts["Monday, 09 December"].exists)
    }
}
