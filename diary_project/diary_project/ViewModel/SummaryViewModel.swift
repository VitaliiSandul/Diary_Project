import Foundation
import UIKit

class SummaryViewModel {
    private(set) var diaryEntries: [Diary] = [] {
        didSet {
            updateStatistics()
            updateEntryDates()
        }
    }
    
    private var statistics: [Statistic] = []
    
    private var entryDates: Set<Date> = []
    
    private var isCurrentMonth: Bool = false
    
    private let calendar = Calendar.current
    
    func setEntries(_ entries: [Diary]) {
        diaryEntries = entries
    }
    
    func setCurrentMonthFilter(_ isCurrentMonth: Bool) {
        self.isCurrentMonth = isCurrentMonth
        updateStatistics()
        updateEntryDates()
    }
    
    func getStatistics(for indexPath: IndexPath) -> Statistic {
        return statistics[indexPath.row]
    }
    
    func getEntryDates() -> Set<Date> {
        return entryDates
    }
    
    func numberOfStatistics() -> Int {
        return statistics.count
    }
    
    private func updateStatistics() {
        let entries = isCurrentMonth ? diaryEntries.filter {
            calendar.isDate($0.date, equalTo: Date(), toGranularity: .month)
        } : diaryEntries
        
        let totalEntries = entries.count
        let goodMoods: Set<Diary.Mood> = [.normal, .okey, .veryGood, .excellent]
        let inGoodMood = entries.filter { goodMoods.contains($0.mood) }.count
        let withPhotos = entries.filter { $0.photoDataUrl != nil }.count
        let totalCharacters = entries.reduce(0) { $0 + $1.textContent.count }
        let averageCharacters = totalEntries == 0 ? 0 : totalCharacters / totalEntries
        
        statistics = [
            Statistic(title: "Total Entries", value: "\(totalEntries)"),
            Statistic(title: "Entries in Good Mood", value: "\(inGoodMood)"),
            Statistic(title: "Entries with Photos", value: "\(withPhotos)"),
            Statistic(title: "Average Characters", value: "\(Int(averageCharacters))")
        ]
    }
    
    func decorationForDateComponents(_ dateComponents: DateComponents) -> UICalendarView.Decoration? {
        let calendar = Calendar.current
        let targetComponents = DateComponents(year: dateComponents.year, month: dateComponents.month, day: dateComponents.day)
        
        for entryDate in getEntryDates() {
            let entryComponents = calendar.dateComponents([.year, .month, .day], from: entryDate)
            if entryComponents == targetComponents {
                return UICalendarView.Decoration.default(color: .systemBlue, size: .large)
            }
        }
        return nil
    }
    
    private func updateEntryDates() {
        let entries = isCurrentMonth ? diaryEntries.filter {
            calendar.isDate($0.date, equalTo: Date(), toGranularity: .month)
        } : diaryEntries
        
        entryDates = Set(entries.map { $0.date })
    }
}
