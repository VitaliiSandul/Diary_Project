import SwiftUI

struct AppMainScreenView: View {
    @ObservedObject private var diaryViewModel = DiaryViewModel()
    @State var selectedEntry: Diary = DiaryViewModel.getRandomEntity()
    @State var showingDetailView = false
    @State var showingAddView = false
    @AppStorage(AppStorageKeysConstants.selectedDateFormatLong) var selectedDateFormatLong = DefaultSettings.selectedDateFormatLong
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var landscapeIsCompact: Bool {
        horizontalSizeClass == .compact && verticalSizeClass == .compact ||
        horizontalSizeClass == .regular && verticalSizeClass == .compact
    }
    
    init() {
        print("AppMainScreenView init")
        
        do {
            diaryViewModel.diaryEntries = try diaryViewModel.readDataFromJson() ?? []
        }
        catch {
            print("\(error.localizedDescription)")
            diaryViewModel.diaryEntries = []
        }
        
        diaryViewModel.addDefaultImage()
    }
    
    var body: some View {
        TabView {
            NavigationView {
                ScrollView {
                    if landscapeIsCompact {
                        LandscapeMainScreenView(diaryViewModel: diaryViewModel, selectedEntry: $selectedEntry, showingDetailView: $showingDetailView, showingAddView: $showingAddView)
                    } else {
                        PortraitMainScreenView(diaryViewModel: diaryViewModel, selectedEntry: $selectedEntry, showingDetailView: $showingDetailView, showingAddView: $showingAddView)
                    }
                }
                .navigationTitle("Diary")
                .navigationBarItems(trailing: Button(action: {
                    self.showingAddView = true
                }, label: {
                    Image(systemName: "plus")
                }))
                .sheet(isPresented: $showingAddView) {
                    AddEntryDetailView(diaryViewModel: diaryViewModel, showingAddView: $showingAddView)
                }
                .sheet(isPresented: $showingDetailView) {
                    EntryDetailView(diaryViewModel: diaryViewModel, diaryEntry: $selectedEntry, isAddNewEntryScreen: false, showingDetailView: $showingDetailView)
                }
            }
            .tabItem {
                Label("Diary", systemImage: "note.text")
            }
            
            NavigationView {
                SummaryView(diaryEntries: diaryViewModel.diaryEntries)
                    .navigationTitle("Summary")
            }
            .tabItem {
                Label("Summary", systemImage: "chart.bar.doc.horizontal.fill")
            }
            
            NavigationView {
                SettingsView(selectedDateFormatLong: selectedDateFormatLong)
                    .navigationTitle("Settings")
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            saveData()
        }
    }
    
    private func saveData() {
        do {
            try diaryViewModel.writeDataToJson(diaryEntries: diaryViewModel.diaryEntries)
        }
        catch {
            print("\(error.localizedDescription)")
        }
    }
    
}

#Preview {
    AppMainScreenView()
}

#Preview(traits: .landscapeLeft) {
    AppMainScreenView()
}
