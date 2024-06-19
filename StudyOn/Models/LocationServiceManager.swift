import CoreLocation
import UserNotifications

class LocationServiceManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationServiceManager()  // Singleton instance
    
    private let studyLocationViewModel = StudyLocationViewModel()
    private var locationManager: CLLocationManager = CLLocationManager()
    private var lastLocation: CLLocation?
    private var locationStayStartTime: Date?
    private var nearbyStudyLocation: StudyLocation?
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        print(newLocation.coordinate)
        
        if let lastLocation = lastLocation {
            let distance = newLocation.distance(from: lastLocation)
            if distance < 50 { // within 50m range
                if locationStayStartTime == nil {
                    locationStayStartTime = Date()
                } else if let startTime = locationStayStartTime {
                    let duration = Date().timeIntervalSince(startTime)
                    if duration > 30 { // 30
                        nearbyStudyLocation = studyLocationViewModel.findNearbyStudyLocation(from: lastLocation, within: CLLocationDistance(50)) // within 50m range
                        if let nearbyLocation = nearbyStudyLocation {
                            print(nearbyLocation.name)
                            NotificationHandlerModel.shared.studyLocation = nearbyLocation
                            NotificationHandlerModel.shared.allowDynamicDataSubmit = true
                            sendNotification()
                        } else {
                            print("no nearby locations found")
                        }
                        locationStayStartTime = nil // Reset the timer
                    }
                }
            } else {
                locationStayStartTime = nil // Reset if the user moved
            }
        }
        
        lastLocation = newLocation
    }
    
    private func sendNotification() {
        print("sending notification!!!")
        
        guard let foundLocation = nearbyStudyLocation else {
            print("notification not sent as nearbyStudyLocation variable was nil")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Rate this study location!"
        content.body = "You seem to be at \(foundLocation.name). \nPlease rate this location and share your experience!"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "MY_NOTIFICATION_CATEGORY"
       
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding notification: \(error.localizedDescription)")
            } else {
                print("Notification added successfully!")
            }
        }
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func startMonitoringSignificantLocationChanges() {
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func stopMonitoringSignificantLocationChanges() {
        locationManager.stopMonitoringSignificantLocationChanges()
    }

    func startMonitoring() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
    }
}
