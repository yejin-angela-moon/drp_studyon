import CoreLocation
import UserNotifications

class LocationServiceManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationServiceManager()  // Singleton instance
    
    private var locationManager: CLLocationManager = CLLocationManager()
    private var lastLocation: CLLocation?
    private var locationStayStartTime: Date?
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        if let lastLocation = lastLocation {
            let distance = newLocation.distance(from: lastLocation)
            if distance < 50 { // within 50m range
                if locationStayStartTime == nil {
                    locationStayStartTime = Date()
                } else if let startTime = locationStayStartTime {
                    let duration = Date().timeIntervalSince(startTime)
                    if duration > 1800 { // 30 minutes
                        sendNotification()
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
        let content = UNMutableNotificationContent()
        content.title = "You've stayed in the same place for a while"
        content.body = "You've been in the same location for more than 30 minutes."
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func startMonitoringLocation() {
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func stopMonitoringLocation() {
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
    }
}
