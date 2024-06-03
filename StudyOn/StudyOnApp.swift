//
//  StudyOnApp.swift
//  StudyOn
//
//  Created by Victor Kang on 5/29/24.
//

import SwiftUI
import Firebase

@main
struct StudyOnApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
//                RootView()
                //AuthenticationView()
            }
            //ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    addSampleDataToFirestore()
    print("Configured Firebase!")
    return true
  }
    
    func addSampleDataToFirestore() {
        let db = Firestore.firestore()
        
        // Check if sample data already exists
        db.collection("studyLocations").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("No documents")
                return
            }
            
            if documents.isEmpty {
                // Add sample data only if collection is empty
                let sampleComments = [
                    Comment(name: "Alice", content: "Great place to study!", date: Date()),
                    Comment(name: "Bob", content: "Quite noisy during peak hours.", date: Date()),
                    Comment(name: "Charlie", content: "Friendly staff and good resources.", date: Date())
                ]
                
                let sampleLocations = [
                    StudyLocation(name: "Imperial College London - Abdus Salam Library", title: "Imperial College London, South Kensington Campus, London SW7 2AZ", latitude: 51.49805710, longitude: -0.17824890, rating: 5.0, comments: sampleComments, images: ["imperial1", "imperial2", "imperial3"], hours: [
                        "Monday": ("09:00", "18:00"),
                        "Tuesday": ("09:00", "18:00"),
                        "Wednesday": ("09:00", "18:00"),
                        "Thursday": ("09:00", "18:00"),
                        "Friday": ("09:00", "18:00"),
                        "Saturday": ("10:00", "16:00"),
                        "Sunday": ("Closed", "Closed")
                    ]),
                    // Add more sample data as needed
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
                        "hours": location.hours.mapValues { ["open": $0.open, "close": $0.close] }
                    ]
                    db.collection("studyLocations").addDocument(data: locationData) { error in
                        if let error = error {
                            print("Error adding document: \(error)")
                        } else {
                            print("Document added")
                        }
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    print("All sample data added.")
                }
            } else {
                print("Sample data already exists. No need to add.")
            }
        }
    }

}
