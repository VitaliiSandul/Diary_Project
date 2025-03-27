import SwiftUI

struct PortraitMainScreenView: View {
    @ObservedObject var diaryViewModel: DiaryViewModel
    @Binding var selectedEntry: Diary
    @Binding var showingDetailView: Bool
    @Binding var showingAddView: Bool
    @AppStorage(AppStorageKeysConstants.selectedDateFormatLong) var selectedDateFormatLong = DefaultSettings.selectedDateFormatLong
    
    var body: some View {
        LazyVStack(spacing: 16) {
            ForEach(diaryViewModel.diaryEntries.sorted {$0.date > $1.date}) { entry in
                
                if let index = diaryViewModel.diaryEntries.firstIndex(where: {$0.id == entry.id}) {
                    EntryCardView(entry: entry, onDelete: { removeEntry(entryId: $0.id) })
                        .onTapGesture{
                            selectedEntry = diaryViewModel.diaryEntries[index]
                            self.showingDetailView = true
                        }
                }
            }
        }
    }
    
    func removeEntry(entryId: UUID) {
        if let index = diaryViewModel.diaryEntries.firstIndex(where: {$0.id == entryId}) {
            diaryViewModel.diaryEntries.remove(at: index)
        }
    }
}

#Preview {
    struct PortraitMainScreenViewPreview: View {
        @State var diaryEntry: Diary = Diary(
            date: Date(),
            textContent: "Diary text example",
            mood: .okey,
            energy: 50.0)
        
        @State var showingDetailView = true
        @State var showingAddView = false
        
        var body: some View {
            
            PortraitMainScreenView(
                diaryViewModel: DiaryViewModel(),
                selectedEntry: $diaryEntry,
                showingDetailView: $showingDetailView,
                showingAddView: $showingAddView
            )
        }
    }
    
    return PortraitMainScreenViewPreview()
}
