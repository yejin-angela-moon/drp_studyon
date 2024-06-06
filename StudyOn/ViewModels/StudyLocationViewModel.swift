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

    // func fetchData() {
    //     db.collection("studyLocations").addSnapshotListener { (querySnapshot, error) in
    //         guard let documents = querySnapshot?.documents else {
    //             print("No documents")
    //             return
    //         }

    //         self.studyLocations = documents.compactMap { (queryDocumentSnapshot) -> StudyLocation? in
    //             let data = queryDocumentSnapshot.data()
                
    //             guard let name = data["name"] as? String,
    //                 let title = data["title"] as? String,
    //                 let latitude = data["latitude"] as? Double,
    //                 let longitude = data["longitude"] as? Double,
    //                 let rating = data["rating"] as? Double,
    //                 let images = data["images"] as? [String],
    //                 let commentsData = data["comments"] as? [[String: Any]],
    //                 let hoursData = data["hours"] as? [String: OpeningHours],
    //                 let envFactorData = data["envFactor"] as? EnvFactor ?? nil,
    //                 let num = data["num"] as? Int,
    //                 let category = data["category"] as? String else {
    //                     print("Error parsing document data")
    //                     return nil
    //                 }

    //             let comments = commentsData.compactMap { commentData -> Comment? in
    //                 guard let name = commentData["name"] as? String,
    //                     let content = commentData["content"] as? String,
    //                     let timestamp = commentData["date"] as? Timestamp else {
    //                     return nil
    //                 }
    //                 return Comment(name: name, content: content, date: timestamp.dateValue())
    //             }

    //             let hours = hoursData.compactMapValues { hourData -> OpeningHours? in
    //                 guard let opening = hourData.opening as? String,
    //                     let closing = hourData.closing as? String else {
    //                     return nil
    //                 }
    //                 return OpeningHours(opening: opening, closing: closing)
    //             }

    //             guard let dynamicData = envFactorData.dynamicData as? [String: Double],
    //                 let staticData = envFactorData.staticData as? [String: Double],
    //                 let atmosphere = envFactorData.atmosphere as? [String] else {
    //                 return nil
    //             }

    //             let envFactor = EnvFactor(dynamicData: dynamicData, staticData: staticData, atmosphere: atmosphere)

    //             return StudyLocation(
    //                 name: name, 
    //                 title: title, 
    //                 latitude: latitude, 
    //                 longitude: longitude, 
    //                 rating: rating, 
    //                 comments: comments, 
    //                 images: images, 
    //                 hours: hours, 
    //                 envFactor: envFactor,
    //                 num: num, 
    //                 category: category
    //             )
    //             print("Fetched \(self.studyLocations.count) locations")
    //         }
    //     }
    // }
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
                        OpeningHours(opening: $0.opening ?? "Closed", closing: $0.closing ?? "Closed")
                    }
                    let envFactorData = data["envFactor"] as? [String: Any] ?? [:]
                    let envFactor = envFactorData.map {
                        EnvFactor(
                            dynamicData: $0.dynamicData as? [String: Double] ?? [:],
                            staticData: $0.staticData as? [String: Double] ?? [:],
                            atmosphere: $0.atmosphere as? [String] ?? []
                        )
                    }
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
