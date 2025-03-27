import SwiftUI

struct SettingsView: View {
    
    @AppStorage(AppStorageKeysConstants.selectedDateFormatLong) var selectedDateFormatLong = DefaultSettings.selectedDateFormatLong
    
    var body: some View {
        Form {
            Section() {
                Toggle("Show Weekday", isOn: $selectedDateFormatLong)
                Text(DateFormatHelper.formatDate(date: Date(), showWeekday: selectedDateFormatLong))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .listRowSeparator(.hidden)
            .padding(10)
        }
    }
}

#Preview {
    SettingsView()
}
