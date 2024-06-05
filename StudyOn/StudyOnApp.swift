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
    addSampleData()
    print("Configured Firebase!")
    return true
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
                ], ratingFactors: [
                    "wifi speed": 4.0,
                    "crowdness": 2.5,
                    "noise": 3.0,
                    "spaciousness": 4.5
                ], atmosphere: ["Calm", "Nice music", "Pet-friendly"],num: 4),
                StudyLocation(name: "The London Library", title: "14 St James's Square, St. James's, London SW1Y 4LG", latitude: 51.50733901, longitude: -0.13698200, rating: 2.1, comments: [], images: [], hours: [
                    "Monday": ("09:00", "18:00"),
                    "Tuesday": ("09:00", "18:00"),
                    "Wednesday": ("09:00", "18:00"),
                    "Thursday": ("09:00", "18:00"),
                    "Friday": ("09:00", "18:00"),
                    "Saturday": ("10:00", "16:00"),
                    "Sunday": ("Closed", "Closed")
                ], ratingFactors: [
                    "wifi speed": 4.0,
                    "crowdness": 2.5,
                    "noise": 3.0,
                    "spaciousness": 4.5
                ], atmosphere: ["Calm", "Nice music", "Pet-friendly", "Quiet"], num: 4),
                StudyLocation(name: "Chelsea Library", title: "Chelsea Old Town Hall, King's Rd, London SW3 5EZ", latitude: 51.48738370, longitude: -0.16837240, rating: 0.7, comments: [], images: [], hours: [
                    "Monday": ("09:00", "18:00"),
                    "Tuesday": ("09:00", "18:00"),
                    "Wednesday": ("09:00", "18:00"),
                    "Thursday": ("09:00", "18:00"),
                    "Friday": ("09:00", "18:00"),
                    "Saturday": ("10:00", "16:00"),
                    "Sunday": ("Closed", "Closed")
                ], ratingFactors: [
                    "wifi speed": 4.0,
                    "crowdness": 2.5,
                    "noise": 3.0,
                    "spaciousness": 4.5
                ], atmosphere: ["Calm", "Nice music", "Pet-friendly"], num: 4),
                StudyLocation(name: "Fulham Library", title: "598 Fulham Rd., London SW6 5NX", latitude: 51.478, longitude: -0.2028, rating: 3.5, comments: [], images: [], hours: [
                    "Monday": ("09:00", "18:00"),
                    "Tuesday": ("09:00", "18:00"),
                    "Wednesday": ("09:00", "18:00"),
                    "Thursday": ("09:00", "18:00"),
                    "Friday": ("09:00", "18:00"),
                    "Saturday": ("10:00", "16:00"),
                    "Sunday": ("Closed", "Closed")
                ], ratingFactors: [
                    "wifi speed": 4.0,
                    "crowdness": 2.5,
                    "noise": 3.0,
                    "spaciousness": 4.5
                ], atmosphere: ["Calm", "Nice music", "Pet-friendly"], num: 4),
                StudyLocation(name: "Brompton Library", title: "210 Old Brompton Rd, London SW5 0BS", latitude: 51.490, longitude: -0.188, rating: 4.1, comments: [], images: [], hours: [
                    "Monday": ("09:00", "18:00"),
                    "Tuesday": ("09:00", "18:00"),
                    "Wednesday": ("09:00", "18:00"),
                    "Thursday": ("09:00", "18:00"),
                    "Friday": ("09:00", "18:00"),
                    "Saturday": ("10:00", "16:00"),
                    "Sunday": ("Closed", "Closed")
                ], ratingFactors: [
                    "wifi speed": 4.0,
                    "crowdness": 2.5,
                    "noise": 3.0,
                    "spaciousness": 4.5
                ], atmosphere: ["Calm", "Nice music", "Pet-friendly"], num: 4),
                StudyLocation(name: "Avonmore Library", title:"7 North End Crescent, London W14 8TG", latitude: 51.492, longitude: -0.206, rating: 4.7, comments: [], images: [], hours: [
                    "Monday": ("09:00", "18:00"),
                    "Tuesday": ("09:00", "18:00"),
                    "Wednesday": ("09:00", "18:00"),
                    "Thursday": ("09:00", "18:00"),
                    "Friday": ("09:00", "18:00"),
                    "Saturday": ("10:00", "16:00"),
                    "Sunday": ("Closed", "Closed")
                ], ratingFactors: [
                    "wifi speed": 4.0,
                    "crowdness": 2.5,
                    "noise": 3.0,
                    "spaciousness": 4.5
                ], atmosphere: ["Calm", "Nice music", "Pet-friendly"], num: 4),
                StudyLocation(name: "Charing Cross Hospital Campus Library", title:"St Dunstan's Rd, London W6 8RP", latitude: 51.490, longitude: -0.218, rating: 1.5, comments: [], images: [], hours: [
                    "Monday": ("09:00", "18:00"),
                    "Tuesday": ("09:00", "18:00"),
                    "Wednesday": ("09:00", "18:00"),
                    "Thursday": ("09:00", "18:00"),
                    "Friday": ("09:00", "18:00"),
                    "Saturday": ("10:00", "16:00"),
                    "Sunday": ("Closed", "Closed")
                ], ratingFactors: [
                    "wifi speed": 4.0,
                    "crowdness": 2.5,
                    "noise": 3.0,
                    "spaciousness": 4.5
                ], atmosphere: ["Calm", "Nice music", "Pet-friendly"], num: 4)
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
                    "hours": location.hours.mapValues { ["open": $0.open, "close": $0.close] },
                    "ratingFactors": location.ratingFactors,
                    "atmosphere": location.atmosphere,
                    "num": location.num
                ]
                if let existingDocument = existingDocuments[location.name] {
                                // 기존 문서가 존재하는 경우 업데이트
                                db.collection("studyLocations").document(existingDocument.documentID).setData(locationData, merge: true) { error in
                                    if let error = error {
                                        print("Error updating document: \(error)")
                                    } else {
                                        print("Document updated")
                                    }
                                    group.leave()
                                }
                            } else {
                                // 기존 문서가 존재하지 않는 경우 새로 추가
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
