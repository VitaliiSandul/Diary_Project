import SwiftUI

struct AddEntryDetailView: View {
    @ObservedObject var diaryViewModel: DiaryViewModel
    @State var newEntry = DiaryViewModel.getRandomEntity()
    @State private var isDatePickerVisible: Bool = true
    @State private var showingDetailView: Bool = false
    
    @Binding var showingAddView: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                EntryDetailView(diaryViewModel: diaryViewModel, diaryEntry: $newEntry, isAddNewEntryScreen: true, showingDetailView: $showingDetailView)
            }
            .frame(maxHeight: .infinity)
            .scrollDisabled(false)
            .navigationTitle("Add Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingAddView.toggle()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        diaryViewModel.diaryEntries.append(newEntry)
                        showingAddView.toggle()
                    }
                }
                
            }
        }
    }
}

#Preview {
    struct AddEntryDetailViewPreview: View {
        @State private var showingAddView = true
        
        var body: some View {
            AddEntryDetailView(diaryViewModel: DiaryViewModel(), showingAddView: $showingAddView)
        }
    }
    
    return AddEntryDetailViewPreview()
}
