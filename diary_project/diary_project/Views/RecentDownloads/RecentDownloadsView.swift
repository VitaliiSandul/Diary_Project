import UIKit
import SwiftUI

struct RecentDownloadsView: UIViewControllerRepresentable {
    var onSelect: (String) -> Void
    var onCancel: () -> Void

    func makeUIViewController(context: Context) -> UINavigationController {
        let recentDownloadsVC = RecentDownloadsViewController()
        recentDownloadsVC.delegate = context.coordinator
        
        let navigationController = UINavigationController(rootViewController: recentDownloadsVC)
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self, onSelect: onSelect, onCancel: onCancel)
    }

    class Coordinator: NSObject, RecentDownloadsViewControllerDelegate {
        let parent: RecentDownloadsView
        let onSelect: (String) -> Void
        let onCancel: () -> Void

        init(_ parent: RecentDownloadsView, onSelect: @escaping (String) -> Void, onCancel: @escaping () -> Void) {
            self.parent = parent
            self.onSelect = onSelect
            self.onCancel = onCancel
        }

        func recentDownloadsViewController(_ vc: RecentDownloadsViewController, didSelectPhoto photoPath: String) {
            onSelect(photoPath)
        }

        func recentDownloadsViewControllerDidCancel(_ vc: RecentDownloadsViewController) {
            onCancel()
        }
    }
}
