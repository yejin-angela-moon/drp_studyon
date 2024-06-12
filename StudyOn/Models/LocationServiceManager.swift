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
        print("here")
        guard let newLocation = locations.last else { return }
        
        if let lastLocation = lastLocation {
            let distance = newLocation.distance(from: lastLocation)
            if distance < 50 { // within 50m range
                if locationStayStartTime == nil {
                    locationStayStartTime = Date()
                } else if let startTime = locationStayStartTime {
                    let duration = Date().timeIntervalSince(startTime)
                    if duration > 5 { // 30 minutes
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
        print("sending notification!!!")
        
        let content = UNMutableNotificationContent()
        content.title = "Hey"
        content.body = "Hello"
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
}
