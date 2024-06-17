import FirebaseAuth
import CoreLocation
import FirebaseFirestore
import SwiftUI

class StudyLocationViewModel: ObservableObject {
  @Published var studyLocations: [StudyLocation] = []
  @Published var showOpenHoursList: Bool = false
  @Published var showEnvFactors: Bool = false
  var allStudyLocations: [StudyLocation] = []
  private var db = Firestore.firestore()

  init() {
    fetchData()
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
          
        let dynamicReviews = data["dynamicReviews"] as? [String] ?? []
//        print(dynamicReviews)
        let crowdednessReviews = dynamicReviews.map(parseCrowdedness)
        let noiseReviews = dynamicReviews.map(parseNoise)
//        print(crowdednessReviews)
//        print(noiseReviews)
          
        let envFactorData = data["envFactors"] as? [String: Any] ?? [:]
        let envFactor =
          EnvFactor(
//            dynamicData: (envFactorData["dynamicData"] as? [String: Double] ?? [:]),
            dynamicData: ["crowdedness": averageOfFirstFive(values: crowdednessReviews),
                          "noise": averageOfFirstFive(values: noiseReviews)],
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
    
    func findNearbyStudyLocation(from location: CLLocation, within distance: CLLocationDistance) -> StudyLocation? {
        for studyLocation in allStudyLocations {
            let studyLocationCoordinate = CLLocation(latitude: studyLocation.latitude, longitude: studyLocation.longitude)
            if location.distance(from: studyLocationCoordinate) <= distance {
                return studyLocation
            }
        }
        return nil
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

        print("Document dynamic data successfully updated")
      } catch {
        print("Error updating document for submit: \(error)")
      }

    } else {
      print("No studyLocation found")
      return
    }
  }
    
    func submitRating(studyLocation: StudyLocation?, rating: Double, ratingNum: Int) async {
        if let documentID = studyLocation?.documentID {
          print(documentID)
            
          print(studyLocation?.rating ?? [])
          print(studyLocation?.num ?? 0)
          print(rating)
          print(ratingNum)
            
          do {
            try await db.collection("studyLocations").document(documentID).updateData([
              "rating": rating,
              "num": ratingNum
            ])
              
            print("Document rating successfully updated")
          } catch {
            print("Error updating document for submit rating: \(error)")
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

func parseCrowdedness(from input: String) -> Double {
    let components = input.split(separator: "___")
    
    guard components.count == 2 else {
        print("Failed to split main components")
        return 0
    }
    
    let dataComponents = components[1].split(separator: ",")
    
    guard dataComponents.count > 0,
          let crowdedness = Double(dataComponents[0]) else {
        print("Failed to parse crowdedness")
        return 0
    }
    
    return crowdedness
}

func parseNoise(from input: String) -> Double {
    let components = input.split(separator: "___")
    
    guard components.count == 2 else {
        print("Failed to split main components")
        return 0
    }
    
    let dataComponents = components[1].split(separator: ",")
    
    guard dataComponents.count > 1,
          let noise = Double(dataComponents[1]) else {
        print("Failed to parse noise")
        return 0
    }
    
    return noise
}

func averageOfFirstFive(values: [Double]) -> Double {
    // Check if the list is empty
    guard !values.isEmpty else {
        return 0.0
    }
    
    // Get the first 5 values or as many as available if the list is smaller than 5
    let limitedValues = Array(values.prefix(5))
    
    // Calculate the average
    let sum = limitedValues.reduce(0.0, +)
    let average = sum / Double(limitedValues.count)
    
    return average
}

class FontSizeManager: ObservableObject {
    @Published var titleSize: CGFloat = 28
    let maxTitleSize: CGFloat = 34
    let minTitleSize: CGFloat = 26
    @Published var title2Size: CGFloat = 22
    @Published var title3Size: CGFloat = 19
    @Published var headlineSize: CGFloat = 17
    @Published var subheadlineSize: CGFloat = 15
    @Published var bodySize: CGFloat = 14
    @Published var captionSize: CGFloat = 12
}
