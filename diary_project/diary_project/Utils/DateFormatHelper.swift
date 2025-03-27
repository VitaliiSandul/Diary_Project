import Foundation

struct DateFormatHelper {
    static let formatter = DateFormatter()
    
    static func formatDate(date: Date, showWeekday: Bool) -> String {
        formatter.dateFormat = showWeekday ? "EEEE, dd MMMM" : "dd MMMM"
        return formatter.string(from: date)
    }
}
