import Combine
import UIKit

class DiaryViewModel: ObservableObject {
    @Published var diaryEntries: [Diary]
    
    enum DataProviderError: Error, LocalizedError, Equatable {
        case fileUrlNotFound
        case failedToWriteData(String)
        case failedToReadData(String)
        
        var errorDescription: String? {
            switch self {
            case .fileUrlNotFound:
                return "Failed to retrieve file URL."
            case .failedToWriteData(let message):
                return "Failed to write data to file: \(message)"
            case .failedToReadData(let message):
                return "Failed to read data from file: \(message)"
            }
        }
    }
    
    private var fileManager: FileManager
    
    init() {
            self.diaryEntries = []
            self.fileManager = FileManager.default
        }
    
    func getFileUrl(jsonFileName: String) throws -> URL {
        guard let fileURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(jsonFileName) else {
            throw DataProviderError.fileUrlNotFound
        }
        return fileURL
    }
    
    static func getRandomEntity() -> Diary {
        Diary(
            date: Date(),
            textContent: "Diary note",
            mood: Diary.Mood.allCases.randomElement() ?? .excellent,
            energy: Double.random(in: 0...100),
            photoDataUrl: "default_image.jpg"
        )
    }
    
    func writeDataToJson(diaryEntries: [Diary], jsonFileName: String = "diary_entries.json") throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let jsonData = try encoder.encode(diaryEntries)
            let fileURL = try getFileUrl(jsonFileName: jsonFileName)
            try jsonData.write(to: fileURL)
        } catch {
            throw DataProviderError.failedToWriteData(error.localizedDescription)
        }
    }
    
    func readDataFromJson(jsonFileName: String = "diary_entries.json") throws -> [Diary]? {
        let decoder = JSONDecoder()
        
        do {
            let fileURL = try getFileUrl(jsonFileName: jsonFileName)
            
            guard fileManager.fileExists(atPath: fileURL.path) else {
                throw DataProviderError.fileUrlNotFound
            }
            
            let jsonData = try Data(contentsOf: fileURL)
            return try decoder.decode([Diary].self, from: jsonData)
        } catch {
            throw DataProviderError.failedToReadData(error.localizedDescription)
        }
    }
    
    func addDefaultImage() -> Void {
        if let image = UIImage(named: "image0") {
            saveDefaultImage(image: image)
        }
    }
    
    private func saveDefaultImage(image: UIImage) -> Void {
        let fileName = "default_image.jpg"
        let fileURL = fileManager.temporaryDirectory.appendingPathComponent(fileName)
        
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            do {
                try imageData.write(to: fileURL)
            } catch {
                print("Error saving image: \(error)")
            }
        }
    }
}
