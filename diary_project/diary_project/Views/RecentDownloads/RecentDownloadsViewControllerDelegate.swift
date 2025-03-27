import UIKit

protocol RecentDownloadsViewControllerDelegate: AnyObject {
    func recentDownloadsViewController(_ vc: RecentDownloadsViewController, didSelectPhoto photoPath: String)
    func recentDownloadsViewControllerDidCancel(_ vc: RecentDownloadsViewController)
}
