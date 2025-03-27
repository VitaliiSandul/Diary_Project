import Foundation
import MapKit
import CoreLocation

struct Diary: CustomDebugStringConvertible, Identifiable, Hashable, Codable {
    var id: UUID
    var date: Date
    var textContent: String
    var mood: Mood
    var energy: Double
    var photoDataUrl: String?
    var location: CLLocationCoordinate2D?
    var cityName: String?
    var mapDataUrl: String?
    
    init(id: UUID = UUID(),
         date: Date = Date(),
         textContent: String  = "Write note into your diary.",
         mood: Mood = .okey,
         energy: Double = 50.0,
         photoDataUrl: String? = "default_image.jpg",
         location: CLLocationCoordinate2D? = nil,
         cityName: String? = "",
         mapDataUrl: String? = nil
    ) {
        self.id = id
        self.date = date
        self.textContent = textContent
        self.mood = mood
        self.energy = energy
        self.photoDataUrl = photoDataUrl
        self.location = location
        self.cityName = cityName
        self.mapDataUrl = mapDataUrl
    }
    
    enum Mood: String, CaseIterable, Codable {
        case awful = "😡 Awful"
        case veryBad = "😫Very bad"
        case bad = "😞 Bad"
        case normal = "😐 Normal"
        case okey = "🙂 Okey"
        case veryGood = "😃 Very good"
        case excellent = "🤩 Excellent"
    }
    
    var debugDescription: String {
        return """
        =========================================
        Your note was saved:
        Date: \(date.formatted())
        Note: \(textContent)
        Mood: \(mood.rawValue)
        Energy: \(Int(energy.rounded())) %
        =========================================
        """
    }
}

extension Diary {
    func energyIcon() -> String {
        switch Int(self.energy.rounded()) {
        case 0..<5: "battery.0percent"
        case 5..<45: "battery.25percent"
        case 45..<70: "battery.50percent"
        case 70..<95: "battery.75percent"
        case 95...100: "battery.100percent"
        default: "battery.0percent"
        }
    }
}

extension CLLocationCoordinate2D: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
    
    private enum CodingKeys: String, CodingKey {
        case latitude, longitude
    }
}

extension CLLocationCoordinate2D: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
    
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
