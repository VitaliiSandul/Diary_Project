import Foundation
import MapKit
import UIKit

final class Snapshotter: ObservableObject {
    
    let defaultMap: UIImage
    private(set) var mapSnapShot: UIImage?
    private let imageName: String
    private let region: MKCoordinateRegion
    private let fileLocation: URL
    private let options: MKMapSnapshotter.Options
    private var mapSnapshotter: MKMapSnapshotter?
    
    
    @Published private(set) var isOnDevice = false
    
    init(imagename:String, region: MKCoordinateRegion) {
        self.imageName = imagename
        self.region = region
        
        guard let map = UIImage(named: "map.png") else {
            fatalError("Missing default map")
        }
        
        self.defaultMap = map
        options = MKMapSnapshotter.Options()
        options.region = region
        options.size = CGSize(width: 200, height: 200)
        options.scale = UIScreen.main.scale
        
        let fileManager = FileManager.default
        guard let url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            fatalError("Unable to get file.")
        }
        
        fileLocation = url.appendingPathComponent("\(imagename).png")
        if fileManager.fileExists(atPath: fileLocation.path), let image = UIImage(contentsOfFile: fileLocation.path) {
            mapSnapShot = image
            isOnDevice = true
        }
    }
    
    func takeSnapshot(completion: @escaping (UIImage?) -> Void) {
        mapSnapshotter = MKMapSnapshotter(options: options)
        mapSnapshotter?.start { snapshot, error in
            guard let snapshot = snapshot else {
                print("Unable to get snapshot: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            let imagedata = snapshot.image.pngData()
            guard let data = imagedata, let imageSnapshot = UIImage(data: data) else {
                print("Unable to produce map image.")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.isOnDevice = true
                self?.writeToDisk(imagedata: data)
                self?.mapSnapShot = imageSnapshot
                completion(imageSnapshot)
            }
        }
    }
    
    private func writeToDisk(imagedata: Data) {
        do {
            try imagedata.write(to: fileLocation)
        } catch {
            fatalError("Unable to write file.")
        }
    }
    
}
