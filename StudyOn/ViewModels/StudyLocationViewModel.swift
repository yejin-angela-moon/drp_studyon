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
                    let hoursData = data["hours"] as? [String: OpeningHours] ?? [:]
                    let hours = hoursData.mapValues {
                        OpeningHours(opening: $0.opening, closing: $0.closing)
                    }
                    let envFactorData = data["envFactor"] as? [String: Any] ?? [:]
                    let envFactor = 
                        EnvFactor(
                            dynamicData: envFactorData["dynamicData"] as? [String: Double] ?? [:],
                            staticData: envFactorData["staticData"] as? [String: Double] ?? [:],
                            atmosphere: envFactorData["atmosphere"] as? [String] ?? []
                        )
                    let num = data["num"] as? Int ?? 0
                    let category = data["category"] as? String ?? ""
                    return StudyLocation(
                        name: name, 
                        title: title, 
                        latitude: latitude, 
                        longitude: longitude, 
                        rating: rating, 
                        comments: comments, 
                        images: images, 
                        hours: hours, 
                        envFactor: envFactor,
                        num: num, 
                        category: category
                    )
                }
            }
        }
}
