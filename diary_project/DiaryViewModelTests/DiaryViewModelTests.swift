import XCTest
@testable import diary_project

class DiaryViewModelTests: XCTestCase {
    
    var viewModel: DiaryViewModel?
    
    override func setUpWithError() throws {
        viewModel = DiaryViewModel()
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
    }
    
    func test_getRandomEntity_returnsValidDiary() {
        let entity = DiaryViewModel.getRandomEntity()
        XCTAssertNotNil(entity.date)
        XCTAssertFalse(entity.textContent.isEmpty)
        XCTAssertTrue(Diary.Mood.allCases.contains(entity.mood))
        XCTAssertTrue(entity.energy >= 0 && entity.energy <= 100)
    }
    
    func test_readDataFromJson_success() throws {
        let tempFileURL = try FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("test_diary_entries.json")
        
        let sampleData = try JSONEncoder().encode(createSampleDiaryEntries())
        try sampleData.write(to: tempFileURL)
        
        let result = try viewModel?.readDataFromJson(jsonFileName: "test_diary_entries.json")
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, 2)
        
        try FileManager.default.removeItem(at: tempFileURL)
    }
    
    func test_readDataFromJson_unsuccess() throws {
        let wrongFileName = "test_diary_entries_wrong_file.json"

        XCTAssertThrowsError(try viewModel?.readDataFromJson(jsonFileName: wrongFileName)) { error in
            guard let dataProviderError = error as? DiaryViewModel.DataProviderError else {
                XCTFail("Unexpected error type: \(error)")
                return
            }
            
            XCTAssertEqual(dataProviderError, .failedToReadData("Failed to retrieve file URL."))
        }
    }
    
    func test_readDataFromJson_missingRequiredProperty() throws {
        let tempFileURL = try FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("test_diary_entries_missing_property.json")
        
        let invalidData = """
        [
            {
                "textContent": "Test Entry 1",
                "mood": "happy",
                "energy": 80.0
            }
        ]
        """.data(using: .utf8)!
        
        try invalidData.write(to: tempFileURL)
        
        XCTAssertThrowsError(try viewModel?.readDataFromJson(jsonFileName: "test_diary_entries_missing_property.json")) { error in
            guard let dataProviderError = error as? DiaryViewModel.DataProviderError else {
                XCTFail("Unexpected error type: \(error)")
                return
            }
            
            XCTAssertEqual(dataProviderError, .failedToReadData("The data couldn’t be read because it is missing."))
        }
        
        try FileManager.default.removeItem(at: tempFileURL)
    }
    
    func test_writeDataToJson_success() throws {
        let sampleEntries = createSampleDiaryEntries()
        
        let tempFileURL = try FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("test_diary_entries.json")
        
        try viewModel?.writeDataToJson(diaryEntries: sampleEntries, jsonFileName: "test_diary_entries.json")
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempFileURL.path))
        
        let data = try Data(contentsOf: tempFileURL)
        let decodedEntries = try JSONDecoder().decode([Diary].self, from: data)
        XCTAssertEqual(decodedEntries, sampleEntries)
        
        try FileManager.default.removeItem(at: tempFileURL)
    }
    
    func createSampleDiaryEntries() -> [Diary] {
        viewModel?.addDefaultImage()
        return [
            Diary(date: Date(), textContent: "Test Entry 1", mood: Diary.Mood.okey, energy: 80, photoDataUrl: "default_image.jpg"),
            Diary(date: Date(), textContent: "Test Entry 2", mood: Diary.Mood.normal, energy: 55, photoDataUrl: "default_image.jpg")
        ]
    }
    
}
