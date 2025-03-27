import Foundation

final class RecentDownloadsManager {
    static let shared = RecentDownloadsManager()
    private let maxRecentDownloads = 10
    private let fileName = "recent_downloads.json"
    
    private var recentDownloads: [String] = []
    
    init() {
        loadRecentDownloads()
    }
    
    func addDownloadedPhoto(url: String?) {
        guard let url = url else { return }
        recentDownloads.insert(url, at: 0)
        
        if recentDownloads.count > maxRecentDownloads {
            recentDownloads.remove(at: recentDownloads.count - 1)
        }
        
        saveRecentDownloads()
    }
    
    func getDownloadedPhotos() -> [String] {
        return recentDownloads
    }
    
    private func saveRecentDownloads() {
        guard let data = try? JSONEncoder().encode(recentDownloads),
        let fileURL = getFileUrl() else { return }
        
        do {
            try data.write(to: fileURL, options: .atomicWrite)
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    private func loadRecentDownloads() {
        guard let fileURL = getFileUrl(),
              let data = try? Data(contentsOf: fileURL),
              let downloads = try? JSONDecoder().decode([String].self, from: data) else { return }
        
        recentDownloads = downloads
    }
    
    private func getFileUrl() -> URL? {
        guard let fullFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName) else { return nil }
        
        return fullFileURL
    }
}
