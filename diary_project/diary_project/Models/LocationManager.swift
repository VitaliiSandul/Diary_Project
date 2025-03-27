import Foundation
import CoreLocation

final class LocationManager: NSObject, ObservableObject {
    private var locationManager: CLLocationManager
    private lazy var geocoder = CLGeocoder()
    private  var currentAddress: String?
    
    @Published var currentLocation: CLLocation?
    
    init(locationManager: CLLocationManager = CLLocationManager()) {
        self.locationManager = locationManager
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func startLocationServices() {
        if locationManager.authorizationStatus == .authorizedAlways ||  locationManager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func fetchAddress(for location: CLLocation, completion: @escaping (String) -> Void) {
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    print("Error fetching address: \(error.localizedDescription)")
                    completion("Address Unknown")
                    return
                }
                
                guard let placemark = placemarks?.first else {
                    completion("Address Unknown")
                    return
                }

                let address = placemark.locality ?? "Address Unknown"
                self.currentAddress = address
                completion(address)
            }
        }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if locationManager.authorizationStatus == .authorizedAlways ||  locationManager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocation = manager.location else { return }
        currentLocation = locValue
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        guard let clError = error as? CLError else { return }
        
        switch clError {
        case CLError.denied:
            print("Access denied")
        default:
            print("Catch all error")
        }
    }
}
