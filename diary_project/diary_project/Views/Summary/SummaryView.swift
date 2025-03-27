import SwiftUI

struct SummaryView: UIViewControllerRepresentable {
    typealias UIViewControllerType = SummaryViewController
    
    var diaryEntries: [Diary]
    
    func makeUIViewController(context: Context) -> SummaryViewController {
        let summaryViewController = UIStoryboard(name: "Summary", bundle: nil).instantiateViewController(withIdentifier: "SummaryViewController") as! SummaryViewController
        summaryViewController.viewModel.setEntries(diaryEntries)
        return summaryViewController
    }
    
    func updateUIViewController(_ uiViewController: SummaryViewController, context: Context) {
        uiViewController.didUpdateDiaryEntries(diaryEntries)
    }

}
