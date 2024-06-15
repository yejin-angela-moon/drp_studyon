import SwiftUI
import Firebase
import FirebaseAuth
import CoreLocation

@main
struct StudyOnApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var userViewModel = UserViewModel()
    @StateObject var studyLocationViewModel = StudyLocationViewModel()
    @State private var isUserLoggedIn: Bool = false

    @StateObject private var fontSizeManager = FontSizeManager()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if isUserLoggedIn {
                    LocationsView()  
                        .environmentObject(studyLocationViewModel)
                        .environmentObject(userViewModel)
                        .environmentObject(NotificationHandlerModel.shared)
                        .environmentObject(fontSizeManager)
                        .onAppear {
                            userViewModel.fetchCurrentUser()
                        }
                } else {
                    AuthView(isUserLoggedIn: $isUserLoggedIn)
                        .environmentObject(studyLocationViewModel)
                        .environmentObject(userViewModel)
                        .environmentObject(fontSizeManager)
                }
            }
        }
    }
}
struct AuthView: View {
    @Binding var isUserLoggedIn: Bool
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var studyLocationViewModel: StudyLocationViewModel
    var body: some View {
        NavigationStack {
            if userViewModel.isUserLoggedIn {
                LocationsView().environmentObject(studyLocationViewModel).environmentObject(userViewModel).environmentObject(NotificationHandlerModel.shared)
            } else {
                LoginView(isUserLoggedIn: $isUserLoggedIn).environmentObject(studyLocationViewModel).environmentObject(userViewModel)
            }
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        addSampleData()
        print("Configured Firebase!")
        LocationServiceManager.shared.startMonitoring()
        
        UNUserNotificationCenter.current().delegate = self
        print("Set UNUserNotificationCenter delegate")
        
        requestNotificationPermissions()
        print("Configure Notification Service!")

        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .sound, .badge])
    }
        
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else if let error = error {
                print("Notification permission denied: \(error.localizedDescription)")
            } else {
                print("Notification permission was not granted.")
            }
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        LocationServiceManager.shared.startMonitoringSignificantLocationChanges()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        LocationServiceManager.shared.startUpdatingLocation()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Navigating according to the information")
        
        DispatchQueue.main.async {
            NotificationHandlerModel.shared.doNavigate = true
        }
        print(NotificationHandlerModel.shared.studyLocation?.name ?? "Not applied")
        
        completionHandler()
    }
}

func addSampleData() {
    
    let db = Firestore.firestore()
    
    db.collection("studyLocations").getDocuments { snapshot, error in
        guard let documents = snapshot?.documents else {
            print("No documents")
            return
        }
        
        let existingDocuments = documents.reduce(into: [String: DocumentSnapshot]()) { result, document in
                    if let name = document.data()["name"] as? String {
                        result[name] = document
                    }
                }
            
            let sampleEnvFactors = EnvFactor(
                dynamicData: [
                    "crowdedness": 2.5,
                    "noise": 3.0,
                ], 
                staticData: [
                    "wifi speed": 4.0,
                    "# tables": 5,
                    "socket no": 5.0,
                    "# PCs": 10,
                    "# meeting rooms": 1
                ],
                atmosphere: ["Calm", "Nice music", "Pet-friendly"]
            )

            let sampleEnvFactors2 = EnvFactor(
                dynamicData: [
                    "crowdedness": 1.5,
                    "noise": 5.0
                ],
                staticData: [
                    "wifi speed": 5.0,
                    "# tables": 3,
                    "socket no": 10.0,
                    "# PCs": 6,
                    "# meeting rooms": 2
                ],
                atmosphere: ["Lively", "Cozy", "Pet-friendly"]
            )
            
            let sampleComments = [
                Comment(name: "Alice", content: "Great place to study!", date: Date()),
                Comment(name: "Bob", content: "Quite noisy during peak hours.", date: Date()),
                Comment(name: "Charlie", content: "Friendly staff and good resources.", date: Date())
            ]

            let sampleHours = [
                "Monday": OpeningHours(opening: "09:00", closing: "18:00"),
                "Tuesday": OpeningHours(opening: "09:00", closing: "18:00"),
                "Wednesday": OpeningHours(opening: "09:00", closing: "18:00"),
                "Thursday": OpeningHours(opening: "09:00", closing: "18:00"),
                "Friday": OpeningHours(opening: "09:00", closing: "18:00"),
                "Saturday": OpeningHours(opening: "10:00", closing: "16:00"),
                "Sunday": OpeningHours(opening: "Closed", closing: "Closed")
            ]
            
            let sampleLocations = [
                StudyLocation(
                    name: "Imperial College London - Abdus Salam Library", 
                    title: "Imperial College London, South Kensington Campus, London SW7 2AZ", 
                    latitude: 51.49805710, 
                    longitude: -0.17824890, 
                    rating: 5.0, 
                    comments: sampleComments, 
                    images: ["imperial1", "imperial2", "imperial3"], 
                    hours: sampleHours, 
                    envFactor: EnvFactor(dynamicData: ["crowdedness": 2.5, "noise": 3.0], staticData: ["wifi speed": 4.0, "spaciousness": 4.5, "socket no": 5.0], atmosphere: ["Calm", "Quiet"]),
                    num: 4,
                    category: "library"
                ),
                StudyLocation(
                    name: "The London Library", 
                    title: "14 St James's Square, St. James's, London SW1Y 4LG", 
                    latitude: 51.50733901, 
                    longitude: -0.13698200, 
                    rating: 2.1, 
                    comments: [], 
                    images: [], 
                    hours: sampleHours,
                    envFactor: sampleEnvFactors2, 
                    num: 4, 
                    category: "library"
                ),
                StudyLocation(
                    name: "Chelsea Library", 
                    title: "Chelsea Old Town Hall, King's Rd, London SW3 5EZ", 
                    latitude: 51.48738370, 
                    longitude: -0.16837240, 
                    rating: 0.7, 
                    comments: [], 
                    images: [], 
                    hours: sampleHours, 
                    envFactor: sampleEnvFactors, 
                    num: 4, 
                    category: "library"
                ),
                StudyLocation(
                    name: "Fulham Library", 
                    title: "598 Fulham Rd., London SW6 5NX", 
                    latitude: 51.478, 
                    longitude: -0.2028, 
                    rating: 3.5, 
                    comments: [], 
                    images: [], 
                    hours: sampleHours, 
                    envFactor: sampleEnvFactors2, 
                    num: 4, 
                    category: "library"
                ),
                StudyLocation(
                    name: "Brompton Library", 
                    title: "210 Old Brompton Rd, London SW5 0BS", 
                    latitude: 51.490, 
                    longitude: -0.188, 
                    rating: 4.1, 
                    comments: [], 
                    images: [], 
                    hours: sampleHours, 
                    envFactor: sampleEnvFactors, 
                    num: 4, 
                    category: "library"
                ),
                StudyLocation(
                    name: "Avonmore Library", 
                    title:"7 North End Crescent, London W14 8TG", 
                    latitude: 51.492, 
                    longitude: -0.206, 
                    rating: 4.7, 
                    comments: [], 
                    images: [], 
                    hours: sampleHours, 
                    envFactor: sampleEnvFactors2,
                    num: 4, 
                    category: "library"
                ),
                StudyLocation(
                    name: "Charing Cross Hospital Campus Library", 
                    title:"St Dunstan's Rd, London W6 8RP", 
                    latitude: 51.490, 
                    longitude: -0.218, 
                    rating: 1.5, 
                    comments: [], 
                    images: [], 
                    hours: sampleHours, 
                    envFactor: sampleEnvFactors,
                    num: 4, 
                    category: "library"
                ),
                StudyLocation(
                    name: "Starbucks Coffee",
                    title: "19 Old Brompton Rd, London SW7 3HZ",
                    latitude: 51.499,
                    longitude: -0.174,
                    rating: 3.9,
                    comments: [],
                    images: [],
                    hours: sampleHours,
                    envFactor: sampleEnvFactors,
                    num: 4,
                    category: "cafe"
                ),
                StudyLocation(
                    name: "Caffe Nero",
                    title:"119/121 Gloucester Rd, London SW7 4TE",
                    latitude: 51.496,
                    longitude: -0.181,
                    rating: 4.2,
                    comments: [],
                    images: [],
                    hours: sampleHours,
                    envFactor: sampleEnvFactors2,
                    num: 4,
                    category: "cafe"
                ),
                StudyLocation(
                    name: "Pret A Manger",
                    title:"99 Gloucester Rd, London SW7 4SS",
                    latitude: 51.498,
                    longitude: -0.181,
                    rating: 4.1,
                    comments: [],
                    images: [],
                    hours: sampleHours,
                    envFactor: sampleEnvFactors,
                    num: 4,
                    category: "cafe"
                )
            ]
            
            let group = DispatchGroup()
            
            for location in sampleLocations {
                group.enter()
                let locationData: [String: Any] = [
                    "name": location.name,
                    "title": location.title,
                    "latitude": location.latitude,
                    "longitude": location.longitude,
                    "rating": location.rating,
                    "images": location.images,
                    "comments": location.comments.map { ["name": $0.name, "content": $0.content, "date": Timestamp(date: Date())] },
                    "hours": location.hours.mapValues { ["open": $0.opening, "close": $0.closing] },
                    "envFactors": [
                        "dynamicData": location.envFactor.dynamicData,
                        "staticData": location.envFactor.staticData,
                        "atmosphere": location.envFactor.atmosphere
                    ],
                    "num": location.num,
                    "category": location.category
                ]
                if let existingDocument = existingDocuments[location.name] {
                                // if original document exists, add to an existing instance
                                db.collection("studyLocations").document(existingDocument.documentID).setData(locationData, merge: true) { error in
                                    if let error = error {
                                        print("Error updating document: \(error)")
                                    } else {
                                        print("Document updated")
                                    }
                                    group.leave()
                                }
                            } else {
                                // if original document does not exist, create new instance
                                db.collection("studyLocations").addDocument(data: locationData) { error in
                                    if let error = error {
                                        print("Error adding document: \(error)")
                                    } else {
                                        print("Document added")
                                    }
                                    group.leave()
                                }
                            }
            }
            
            group.notify(queue: .main) {
                print("All sample data added.")
            }
    }
}
