import Foundation
import MapKit
import UIKit
final class SnapshotManager {
    private let fileManager: FileManager
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    func generateSnapshot(for location: CLLocationCoordinate2D) async -> UIImage? {
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 500, longitudinalMeters: 500)
        let snapshotter = Snapshotter(imagename: UUID().uuidString, region: region)

        return await withCheckedContinuation { continuation in
            snapshotter.takeSnapshot { snapshot in
                continuation.resume(returning: snapshot)
            }
        }
    }
    
    func saveSnapshot(_ snapshot: UIImage) -> String? {
        guard let imageData = snapshot.pngData() else {
            return nil
        }
        
        let fileName = UUID().uuidString + ".png"
        let fileURL = fileManager.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: fileURL)
            return fileURL.lastPathComponent
        } catch {
            print("Failed to save snapshot: \(error.localizedDescription)")
            return nil
        }
    }
}
