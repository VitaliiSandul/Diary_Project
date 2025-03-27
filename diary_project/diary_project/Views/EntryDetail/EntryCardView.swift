import SwiftUI
import Combine

struct EntryCardView: View {
    let entry: Diary
    let onDelete: (Diary) -> Void
    @AppStorage(AppStorageKeysConstants.selectedDateFormatLong) var selectedDateFormatLong = DefaultSettings.selectedDateFormatLong
    
    let imageLoaderService = ImageLoaderService()
    
    @State private var loadedImage: UIImage?
    @State private var cancellable: AnyCancellable?
    @State private var isLoading = false
    
    @State private var mapSnapshot: UIImage?
    @State private var mapCancellable: AnyCancellable?
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(DateFormatHelper.formatDate(date: entry.date, showWeekday: selectedDateFormatLong))
                    .font(.subheadline)
                    .fontWeight(.bold)
                Spacer()
                Menu {
                    Button(role: .destructive) {
                        onDelete(entry)
                    } label: {
                        Label("Delete", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.gray.opacity(0.3))
            VStack(alignment: .leading) {
                
                VStack {
                    HStack {
                        if entry.photoDataUrl != nil {
                            if isLoading {
                                ZStack {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 150)
                                        .frame(maxWidth: .infinity)
                                        .cornerRadius(8)
                                        .padding(.horizontal)
                                    
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                }
                            } else if let image = loadedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .cornerRadius(8)
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 150)
                            }
                        }
                        
                        if let mapSnapshot = mapSnapshot, !isLoading {
                            Image(uiImage: mapSnapshot)
                                .resizable()
                                .cornerRadius(10)
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .frame(height: 150)
                        }
                    }
                    .padding()
                    
                    if let cityName = entry.cityName {
                        Text(cityName)
                            .foregroundColor(.gray)
                            .font(.footnote)
                            .padding(.bottom)
                    }
                }
                
                Text(entry.textContent)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                HStack {
                    Text("Mood: ")
                        .fontWeight(.bold)
                    Text(entry.mood.rawValue)
                }
                .padding(.horizontal)
                HStack {
                    Text("Energy: ")
                        .fontWeight(.bold)
                    Image(systemName: "\(entry.energyIcon())")
                    Text("\(Int(entry.energy.rounded()))%")
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .foregroundStyle(.black)
        .background(LinearGradient(
            gradient: Gradient(colors: [.init(hue: 260.0 / 360.0, saturation: 0.01, brightness: 0.98), .init(hue: 200.0 / 360.0, saturation: 0.01, brightness: 0.99)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing)
        )
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.3), radius: 40)
        .padding(.horizontal)
        .onAppear {
            loadImage()
            loadMapSnapshot()
        }
        .onChange(of: entry.photoDataUrl) { oldValue, newValue in
            if newValue != oldValue {
                Task {
                    loadImage()
                }
            } else { return }
        }
        .onChange(of: entry.mapDataUrl) { oldValue, newValue in
            if newValue != oldValue {
                Task {
                    loadMapSnapshot()
                }
            } else { return }
        }
    }
    
    private func loadImage() {
        guard let photoPath = entry.photoDataUrl else {
            loadedImage = nil
            return
        }
        isLoading = true
        
        cancellable = imageLoaderService.loadImage(from: photoPath)
            .sink { image in
                loadedImage = image
                isLoading = false
            }
    }
    
    private func loadMapSnapshot() {
        guard let mapPath = entry.mapDataUrl else {
            mapSnapshot = nil
            return
        }
        
        mapCancellable = imageLoaderService.loadImage(from: mapPath)
            .sink { image in
                mapSnapshot = image
            }
    }
}

struct EntryCardViewPreview: PreviewProvider {
    let selectedDateFormatLong = true
    static var previews: some View {
        EntryCardView(entry: Diary(
            date: Date(),
            textContent: "Some text for diary entry.",
            mood: .normal,
            energy: 78.5
        ), onDelete: { _ in })
        .frame(width: 350, height: 200)
    }
}
