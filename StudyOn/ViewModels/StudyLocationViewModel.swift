import FirebaseAuth
import FirebaseFirestore
import SwiftUI

class StudyLocationViewModel: ObservableObject {
  @Published var studyLocations: [StudyLocation] = []
  @Published var showOpenHoursList: Bool = false
  @Published var showEnvFactors: Bool = false
  var allStudyLocations: [StudyLocation] = []
  private var db = Firestore.firestore()
  @Published var userFavorites: [String] = []

  init() {
    fetchData()
    fetchUserFavorites()
  }

  func fetchData() {
    db.collection("studyLocations").addSnapshotListener { (querySnapshot, error) in
      guard let documents = querySnapshot?.documents else {
        print("No documents found")
        return
      }

      self.allStudyLocations = documents.map { (queryDocumentSnapshot) -> StudyLocation in
        let documentID = queryDocumentSnapshot.documentID

        let data = queryDocumentSnapshot.data()
        let name = data["name"] as? String ?? ""
        let title = data["title"] as? String ?? ""
        let latitude = data["latitude"] as? Double ?? 0
        let longitude = data["longitude"] as? Double ?? 0
        let rating = data["rating"] as? Double ?? 0
        let images = data["images"] as? [String] ?? []
        let commentsData = data["comments"] as? [[String: Any]] ?? []
        let comments = commentsData.map {
          Comment(
            name: $0["name"] as? String ?? "", content: $0["content"] as? String ?? "", date: Date()
          )
        }
        var hours: [String: OpeningHours] = [:]
        if let hoursData = data["hours"] as? [String: [String: String]] {
          for (day, times) in hoursData {
            if let opening = times["open"], let closing = times["close"] {
              hours[day] = OpeningHours(opening: opening, closing: closing)
            }
          }
        }
        //                let hoursData = data["hours"] as? [String: OpeningHours] ?? [:]
        //                let hours = hoursData.mapValues {
        //                    OpeningHours(opening: $0.opening, closing: $0.closing)
        //                }

        let envFactorData = data["envFactors"] as? [String: Any] ?? [:]
        let envFactor =
          EnvFactor(
            dynamicData: (envFactorData["dynamicData"] as? [String: Double] ?? [:]),
            staticData: envFactorData["staticData"] as? [String: Double] ?? [:],
            atmosphere: envFactorData["atmosphere"] as? [String] ?? []
          )
        let num = data["num"] as? Int ?? 0
        let category = data["category"] as? String ?? ""
        return StudyLocation(
          documentID: documentID,
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
      self.studyLocations = self.allStudyLocations
    }
  }

  func fetchUserFavorites() {
    guard let userId = Auth.auth().currentUser?.uid else { return }
    db.collection("users").document(userId).getDocument { document, error in
      if let document = document, document.exists {
        if let user = try? document.data(as: User.self) {
          print(document)
          self.userFavorites = user.favoriteLocations
        }
      }
    }
  }

  func isFavorite(locationId: String) -> Bool {
    return userFavorites.contains(locationId)
  }

  func filterLocations(by searchText: String) -> [StudyLocation] {
    if searchText.isEmpty {
      return allStudyLocations
    } else {
      let lowercasedSearchText = searchText.lowercased()
      return allStudyLocations.filter { location in
        location.name.lowercased().contains(lowercasedSearchText)
          || location.envFactor.atmosphere.contains {
            $0.lowercased().contains(lowercasedSearchText)
          }
      }
    }
  }

  func toggleOpenHoursList() {
    withAnimation(.easeInOut) {
      showOpenHoursList.toggle()
    }
  }

  func toggleEnvFactors() {
    withAnimation(.easeInOut) {
      showEnvFactors.toggle()
    }
  }

  func submitDynamicData(studyLocation: StudyLocation?, crowdness: Double, noise: Double) async {
    if let documentID = studyLocation?.documentID {
      print(documentID)
      print(crowdness)
      print(noise)
      print(studyLocation?.dynamicReviewTime ?? [])
      print(studyLocation?.crowdednessReview ?? [])
      print(studyLocation?.noiseReview ?? [])

      var reviewTime = studyLocation?.dynamicReviewTime ?? []
      var crowdednessReview = studyLocation?.crowdednessReview ?? []
      var noiseReview = studyLocation?.noiseReview ?? []

      //            let newData = [
      //                "time": reviewTime.append(Timestamp()),
      //                "crowdedness": crowdednessReview.append(crowdness),
      //                "noise": noiseReview.append(noise)
      //            ]

      do {
        //                try await db.collection("studyLocations").document(documentID).setData(["dynamicReview": newData], merge: true)
        try await db.collection("studyLocations").document(documentID).updateData([
          "dynamicReviews": FieldValue.arrayUnion([encodeReview(crowdness: crowdness, noise: noise)]
          )
        ])
        //                try await db.collection("studyLocations").document(documentID).collection("dynamicReview").document("time").setData(["a": Timestamp()])
        //                setData(["dynamicReview": newData], merge: true)

        print("Document successfully updated")
      } catch {
        print("Error updating document for submit: \(error)")
      }

    } else {
      print("No studyLocation found")
      return
    }
  }
}

func encodeReview(crowdness: Double, noise: Double) -> String {
  let res = "\(Timestamp())___\(crowdness),\(noise)"
  print(res)
  return res
}
