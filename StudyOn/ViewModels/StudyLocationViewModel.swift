//
//  StudyLocationViewModel.swift
//  StudyOn
//
//  Created by Minseok Chey on 5/31/24.
//

import Foundation
import FirebaseFirestore

class StudyLocationViewModel: ObservableObject {
    @Published var studyLocations: [StudyLocation] = []
    private var db = Firestore.firestore()
        
    func fetchData() {
            db.collection("studyLocations").addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }

                self.studyLocations = documents.map { (queryDocumentSnapshot) -> StudyLocation in
                    let data = queryDocumentSnapshot.data()
                    let name = data["name"] as? String ?? ""
                    let title = data["title"] as? String ?? ""
                    let latitude = data["latitude"] as? Double ?? 0
                    let longitude = data["longitude"] as? Double ?? 0
                    let rating = data["rating"] as? Double ?? 0
                    let images = data["images"] as? [String] ?? []
                    let commentsData = data["comments"] as? [[String: Any]] ?? []
                    let comments = commentsData.map { Comment(name: $0["name"] as? String ?? "", content: $0["content"] as? String ?? "", date: Date()) }
                    let hoursData = data["hours"] as? [String: [String: String]] ?? [:]
                                let hours = hoursData.mapValues {
                                    (open: $0["open"] ?? "Closed", close: $0["close"] ?? "Closed")
                                }
                    return StudyLocation(name: name, title: title, latitude: latitude, longitude: longitude, rating: rating, comments: comments, images: images, hours: hours)
                }
            }
        }
    func addSampleData(completion: @escaping () -> Void) {
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
                StudyLocation(name: "The London Library", title: "14 St James's Square, St. James's, London SW1Y 4LG", latitude: 51.50733901, longitude: -0.13698200, rating: 2.1, comments: [], images: [], hours: [
                    "Monday": ("09:00", "18:00"),
                    "Tuesday": ("09:00", "18:00"),
                    "Wednesday": ("09:00", "18:00"),
                    "Thursday": ("09:00", "18:00"),
                    "Friday": ("09:00", "18:00"),
                    "Saturday": ("10:00", "16:00"),
                    "Sunday": ("Closed", "Closed")
                ]),
                StudyLocation(name: "Chelsea Library", title: "Chelsea Old Town Hall, King's Rd, London SW3 5EZ", latitude: 51.48738370, longitude: -0.16837240, rating: 0.7, comments: [], images: [], hours: [
                    "Monday": ("09:00", "18:00"),
                    "Tuesday": ("09:00", "18:00"),
                    "Wednesday": ("09:00", "18:00"),
                    "Thursday": ("09:00", "18:00"),
                    "Friday": ("09:00", "18:00"),
                    "Saturday": ("10:00", "16:00"),
                    "Sunday": ("Closed", "Closed")
                ]),
                StudyLocation(name: "Fulham Library", title: "598 Fulham Rd., London SW6 5NX", latitude: 51.478, longitude: -0.2028, rating: 3.5, comments: [], images: [], hours: [
                    "Monday": ("09:00", "18:00"),
                    "Tuesday": ("09:00", "18:00"),
                    "Wednesday": ("09:00", "18:00"),
                    "Thursday": ("09:00", "18:00"),
                    "Friday": ("09:00", "18:00"),
                    "Saturday": ("10:00", "16:00"),
                    "Sunday": ("Closed", "Closed")
                ]),
                StudyLocation(name: "Brompton Library", title: "210 Old Brompton Rd, London SW5 0BS", latitude: 51.490, longitude: -0.188, rating: 4.1, comments: [], images: [], hours: [
                    "Monday": ("09:00", "18:00"),
                    "Tuesday": ("09:00", "18:00"),
                    "Wednesday": ("09:00", "18:00"),
                    "Thursday": ("09:00", "18:00"),
                    "Friday": ("09:00", "18:00"),
                    "Saturday": ("10:00", "16:00"),
                    "Sunday": ("Closed", "Closed")
                ]),
                StudyLocation(name: "Avonmore Library", title:"7 North End Crescent, London W14 8TG", latitude: 51.492, longitude: -0.206, rating: 4.7, comments: [], images: [], hours: [
                    "Monday": ("09:00", "18:00"),
                    "Tuesday": ("09:00", "18:00"),
                    "Wednesday": ("09:00", "18:00"),
                    "Thursday": ("09:00", "18:00"),
                    "Friday": ("09:00", "18:00"),
                    "Saturday": ("10:00", "16:00"),
                    "Sunday": ("Closed", "Closed")
                ]),
                StudyLocation(name: "Charing Cross Hospital Campus Library", title:"St Dunstan's Rd, London W6 8RP", latitude: 51.490, longitude: -0.218, rating: 1.5, comments: [], images: [], hours: [
                    "Monday": ("09:00", "18:00"),
                    "Tuesday": ("09:00", "18:00"),
                    "Wednesday": ("09:00", "18:00"),
                    "Thursday": ("09:00", "18:00"),
                    "Friday": ("09:00", "18:00"),
                    "Saturday": ("10:00", "16:00"),
                    "Sunday": ("Closed", "Closed")
                ])
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
                completion()
            }
        }
}
