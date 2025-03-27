import Combine
import UIKit
import PhotosUI

class ImageLoaderService {
    func loadImage(from fileName: String) -> AnyPublisher<UIImage?, Never> {
        Future<UIImage?, Never> { promise in
            DispatchQueue.global(qos: .background).async {
                let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
                if let imageData = try? Data(contentsOf: fileURL), let image = UIImage(data: imageData) {
                    promise(.success(image))
                } else {
                    promise(.success(nil))
                }
            }
        }
        .delay(for: .seconds(1), scheduler: DispatchQueue.main)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func fetchRandomImageURL() -> AnyPublisher<String?, Never> {
        guard let url = URL(string: "https://picsum.photos/300") else {
            return Just(nil).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { data, _ in
                self.saveImageToInternalStorage(data: data)?.lastPathComponent
            }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
    
    func saveImageToInternalStorage(data: Data) -> URL? {
        let fileName = "\(UUID().uuidString).jpg"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
}
