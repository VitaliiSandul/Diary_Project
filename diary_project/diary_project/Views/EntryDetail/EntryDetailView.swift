import PhotosUI
import SwiftUI
import Combine
import MapKit

struct EntryDetailView: View {
    @ObservedObject var diaryViewModel: DiaryViewModel
    @Binding var diaryEntry: Diary
    let isAddNewEntryScreen: Bool
    @Binding var showingDetailView: Bool
    @State private var isDatePickerVisible: Bool = false
    @FocusState private var isFocused: Bool
    @State private var mapSnapshot: UIImage?
    @StateObject private var locationManager = LocationManager()
    
    @AppStorage(AppStorageKeysConstants.selectedDateFormatLong) var selectedDateFormatLong = DefaultSettings.selectedDateFormatLong
    
    @MainActor @State private var isLoading = false
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var isPhotosPickerVisible: Bool = false
    @State private var photoDataUrl: String? = nil
    @State private var isRandomPhotoPressed: Bool = false
    @State private var loadedImage: UIImage? = nil
    @State private var cancellables = Set<AnyCancellable>()
    @State private var diaryState: Diary
    @State private var isRecentDownloadsVisible: Bool = false
    @State private var selectedDownloadedPhoto: String?
    
    private let imageLoaderService = ImageLoaderService()
    private let snapshotManager = SnapshotManager()
    
    init(diaryViewModel: DiaryViewModel, diaryEntry: Binding<Diary>, isAddNewEntryScreen: Bool, showingDetailView: Binding<Bool>) {
        self.diaryViewModel = diaryViewModel
        self._diaryEntry = diaryEntry
        self.isAddNewEntryScreen = isAddNewEntryScreen
        self._showingDetailView = showingDetailView
        self._diaryState = State(initialValue: diaryEntry.wrappedValue)
    }
    
    var body: some View {
        NavigationStack{
            VStack{
                VStack {
                    
                    VStack {
                        HStack {
                            if diaryEntry.photoDataUrl != nil {
                                if isLoading {
                                    ZStack {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .cornerRadius(10)
                                            .frame(maxHeight: 200)
                                        
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                            .scaleEffect(2.0)
                                    }
                                } else if let image = loadedImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .cornerRadius(10)
                                        .scaledToFit()
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 200)
                                }
                            }
                            
                            if let mapSnapshot = mapSnapshot {
                                Image(uiImage: mapSnapshot)
                                    .resizable()
                                    .cornerRadius(10)
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 200)
                            }
                        }
                        .padding()
                        
                        if let cityName = diaryEntry.cityName {
                            Text(cityName)
                                .foregroundColor(.gray)
                                .font(.footnote)
                                .padding(.bottom)
                        }
                    }
                    
                    HStack {
                        if isAddNewEntryScreen {
                            Text("Date: ")
                            Text(DateFormatHelper.formatDate(date: diaryEntry.date, showWeekday: selectedDateFormatLong))
                            Spacer()
                        } else {
                            Text("Choose date: ")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Button(action: {
                            isFocused = false
                            isDatePickerVisible.toggle()
                        }, label: {
                            Image(systemName: "calendar")
                        })
                    }
                    .padding(.horizontal, 24.0)
                    
                    if isDatePickerVisible {
                        DatePickerView(selectedDate: $diaryEntry.date, isDatePickerVisible: $isDatePickerVisible)
                    }
                    
                    ScrollView {
                        TextField("Diary note:", text: $diaryEntry.textContent)
                            .focused($isFocused)
                            .padding(.horizontal, 24.0)
                            .onTapGesture {
                                isDatePickerVisible = false
                            }
                        
                        if isFocused {
                            Button("Done") {
                                isFocused = false
                                isDatePickerVisible = false
                            }
                        }
                    }
                    .frame(maxHeight: 300)
                }
                
                Spacer()
                
                VStack {
                    HStack {
                        Text("Mood:").bold()
                        Text(diaryEntry.mood.rawValue)
                        Spacer()
                    }
                    .padding(.leading, 24.0)
                    
                    MoodSelectorView(selectedMood: $diaryEntry.mood, moodItems: Diary.Mood.allCases)
                    
                    EnergyLevelView(diaryEntry: $diaryEntry)
                }
            }
            .photosPicker(isPresented: $isPhotosPickerVisible, selection: $photosPickerItem)
            .navigationTitle(
                isAddNewEntryScreen == true ? "Add entry" : DateFormatHelper.formatDate(date: diaryState.date, showWeekday: selectedDateFormatLong)
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: {
                            addLocation()
                            print("Add Location pressed")
                        }) {
                            Label("Add Location", systemImage: "location.viewfinder")
                        }
                        
                        if diaryState.mapDataUrl != nil {
                            Button(role: .destructive) {
                                diaryState.location = nil
                                diaryEntry.location = diaryState.location
                                diaryState.cityName = nil
                                diaryEntry.cityName = diaryState.cityName
                                diaryState.mapDataUrl = nil
                                diaryEntry.mapDataUrl = diaryState.mapDataUrl
                                mapSnapshot = nil
                                print("Delete Location pressed")
                            }
                            label: {
                                Label("Delete Location", systemImage: "location.slash")
                            }
                        }
                    }
                    label: {
                        Image(systemName: "location")
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: {
                            isPhotosPickerVisible.toggle()
                            print("Add Photo pressed")
                            
                        }) {
                            Label("Add Photo", systemImage: "photo.badge.plus")
                        }
                        
                        Button(action: {
                            fetchRandomImage()
                            print("Random Image pressed")
                        }) {
                            Label("Random Image", systemImage: "square.and.arrow.down")
                        }
                        
                        Button(action: {
                            isRecentDownloadsVisible.toggle()
                            print("Recent Downloads… pressed")
                        }) {
                            Label("Recent Downloads…", systemImage: "photo.on.rectangle.angled")
                        }
                        
                        if diaryState.photoDataUrl != nil {
                            Button(role: .destructive) {
                                diaryState.photoDataUrl = nil
                                diaryEntry.photoDataUrl = diaryState.photoDataUrl
                                print("Delete Image pressed")
                            }
                            label: {
                                Label("Delete Image", systemImage: "trash")
                            }
                        }
                    }
                    label: {
                        Image(systemName: "photo")
                    }
                }
                
                if !isAddNewEntryScreen {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showingDetailView.toggle()
                        }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Update") {
                            updateDiaryEntries(updatedEntry: diaryEntry)
                            showingDetailView.toggle()
                        }
                    }
                }
            }
            .sheet(isPresented: $isRecentDownloadsVisible) {
                NavigationView {
                    RecentDownloadsView { photoPath in
                        selectedDownloadedPhoto = photoPath
                        diaryState.photoDataUrl = photoPath
                        diaryEntry.photoDataUrl = photoPath
                        loadImageFromPath()
                        isRecentDownloadsVisible = false
                    } onCancel: {
                        isRecentDownloadsVisible = false
                    }
                }
            }
            .onChange(of: photosPickerItem) { oldValue, newValue in
                guard let item = newValue else { return }
                Task {
                    isLoading = true
                    await handlePhotoSelection(item: item)
                    loadImageFromPath()
                    isLoading = false
                }
            }
            .onChange(of: diaryState){ oldValue, newValue in
                loadImageFromPath()
            }
            .onChange(of: selectedDownloadedPhoto) { newValue in
                if let photoPath = newValue {
                    diaryState.photoDataUrl = photoPath
                    diaryEntry.photoDataUrl = photoPath
                    loadImageFromPath()
                }
            }
            .onAppear{
                diaryState = diaryEntry
                loadImageFromPath()
                
                if let location = diaryEntry.location {
                    generateSnapshot(for: location)
                }
            }
        }
    }
    
    func updateDiaryEntries(updatedEntry: Diary) {
        if let index = diaryViewModel.diaryEntries.firstIndex(where: { $0.id == updatedEntry.id }) {
            var newDiaryEntries = diaryViewModel.diaryEntries
            newDiaryEntries[index] = updatedEntry
            diaryViewModel.diaryEntries = newDiaryEntries
        }
    }
    
    private func fetchRandomImage() {
        isLoading = true
        imageLoaderService.fetchRandomImageURL()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching random image URL: \(error)")
                }
                isLoading = false
            }, receiveValue: { randomURL in
                diaryState.photoDataUrl = randomURL
                diaryEntry.photoDataUrl = randomURL
                RecentDownloadsManager.shared.addDownloadedPhoto(url: randomURL)
            })
            .store(in: &cancellables)
    }
    
    private func handlePhotoSelection(item: PhotosPickerItem) async {
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                let fileURL = imageLoaderService.saveImageToInternalStorage(data: data)
                diaryState.photoDataUrl = fileURL?.lastPathComponent
                diaryEntry.photoDataUrl = diaryState.photoDataUrl
            }
        } catch {
            print("Error loading image: \(error)")
        }
    }
    
    private func loadImageFromPath() {
        loadedImage = nil
        
        guard let photoPath = diaryState.photoDataUrl else {
            return
        }
        
        imageLoaderService
            .loadImage(from: photoPath)
            .sink { image in
                loadedImage = image
            }
            .store(in: &cancellables)
    }
    
    private func addLocation() {
        locationManager.startLocationServices()
        
        guard let currentLocation = locationManager.currentLocation else {
            print("Location not available")
            return
        }
        
        locationManager.fetchAddress(for: currentLocation) { address in
            DispatchQueue.main.async {
                diaryEntry.cityName = address
                diaryEntry.location = currentLocation.coordinate
                generateSnapshot(for: currentLocation.coordinate)
            }
        }
    }
    
    private func generateSnapshot(for location: CLLocationCoordinate2D) {
        Task {
            if let snapshot = await snapshotManager.generateSnapshot(for: location) {
                mapSnapshot = snapshot
                
                if let mapDataUrl = snapshotManager.saveSnapshot(snapshot) {
                    diaryState.mapDataUrl = mapDataUrl
                    diaryEntry.mapDataUrl = mapDataUrl
                }
            } else {
                print("Failed to generate snapshot")
            }
        }
    }
}

#Preview {
    struct EntryDetailViewPreview: View {
        @State var diaryEntry: Diary = Diary(
            date: Date(),
            textContent: "Third diary text",
            mood: .okey,
            energy: 50.0)
        
        @State var showingDetailView = true
        
        var body: some View {
            EntryDetailView(diaryViewModel: DiaryViewModel(), diaryEntry: $diaryEntry, isAddNewEntryScreen: false, showingDetailView: $showingDetailView)
        }
    }
    
    return EntryDetailViewPreview()
}
