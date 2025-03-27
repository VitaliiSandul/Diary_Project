import Foundation

protocol SummaryViewControllerDelegate: AnyObject {
    func didUpdateDiaryEntries(_ entries: [Diary])
}
