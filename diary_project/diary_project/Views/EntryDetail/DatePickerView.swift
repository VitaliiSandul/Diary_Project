import SwiftUI

struct DatePickerView: View {
    @Binding var selectedDate: Date
    @Binding var isDatePickerVisible: Bool
    
    var body: some View {
        DatePicker("Select a date", selection: $selectedDate, displayedComponents: .date)
            .datePickerStyle(.graphical)
            .frame(width: 320)
            .padding()
            .onChange(of: selectedDate) {
                isDatePickerVisible = false
            }
    }
}

#Preview {
    DatePickerView(selectedDate: .constant(Date()), isDatePickerVisible: .constant(true))
}
