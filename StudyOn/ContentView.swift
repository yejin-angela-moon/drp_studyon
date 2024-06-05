import SwiftUI
import MapKit
import FirebaseFirestore
struct ContentView: View {
    
    
    //    @State private var libraries = librariesDummy
    
    private var db = Firestore.firestore()
    
    var body: some View {
        
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}


let sampleComments = [
    Comment(name: "Alice", content: "Great place to study!", date: Date()),
    Comment(name: "Bob", content: "Quite noisy during peak hours.", date: Date()),
    Comment(name: "Charlie", content: "Friendly staff and good resources.", date: Date())
]


        
//        NavigationView { // Wrap in NavigationView
//            Map(position: $cameraPosition, selection: $locationSelection) {
//                UserAnnotation() // User's current location
//                
//                ForEach(libraries) { item in
//                    Annotation(item.name, coordinate: item.coordinate) {
//                        CustomMarkerView(rating: item.rating)
//                            .onTapGesture {
//                                locationSelection = item
//                            }
//                    }
//                }
//            }
        
       

    
//    private func searchPlacesOnline() async {
////        let request = MKLocalSearch.Request()
////        request.naturalLanguageQuery = searchText
////        request.region = .userRegion
////        let results = try? await MKLocalSearch(request: request).start()
////        self.results = results?.mapItems ?? []
//        let query = db.collection("studyLocations").whereField("name", isEqualTo: searchText)
//        let snapshot = try? await query.getDocuments()
//        self.studyLocations = snapshot?.documents.map { document -> StudyLocation in
//            let data = document.data()
//            let name = data["name"] as? String ?? ""
//            let title = data["title"] as? JSON.dictionary(forKey: "title") as? String ?? ""
//            let latitude = data["latitude"] as? Double ?? 0
//            let longitude = data["longitude"] as? Double ?? 0
//            let rating = data["rating"] as? Double ?? 0
//            let comments = (data["comments"] as? [[String: Any]])?.map { Comment(dictionary: $0) } ?? []
//            let images = data["images"] as? [String] ?? []
//            return StudyLocation(name: name, title: title, latitude: latitude, longitude: longitude, rating: rating, comments: comments, images: images)
//        } ?? []
//    }



// Dummy data and supporting structs for this example
//let librariesDummy = [
//    StudyLocation(name: "Imperial College London - Abdus Salam Library", title: "Imperial College London, South Kensington Campus, London SW7 2AZ", latitude: 51.49805710, longitude: -0.17824890, rating: 5.0, comments: sampleComments, images: ["imperial1", "imperial2", "imperial3"]),
//    StudyLocation(name: "The London Library", title: "14 St James's Square, St. James's, London SW1Y 4LG", latitude: 51.50733901, longitude: -0.13698200, rating: 2.1, comments: [], images: []),
//    StudyLocation(name: "Chelsea Library", title: "Chelsea Old Town Hall, King's Rd, London SW3 5EZ", latitude: 51.48738370, longitude: -0.16837240, rating: 0.7, comments: [], images: []),
//    StudyLocation(name: "Fulham Library", title: "598 Fulham Rd., London SW6 5NX", latitude: 51.478, longitude: -0.2028, rating: 3.5, comments: [], images: []),
//    StudyLocation(name: "Brompton Library", title: "210 Old Brompton Rd, London SW5 0BS", latitude: 51.490, longitude: -0.188, rating: 4.1, comments: [], images: []),
//    StudyLocation(name: "Avonmore Library", title:"7 North End Crescent, London W14 8TG", latitude: 51.492, longitude: -0.206, rating: 4.7, comments: [], images: []),
//    StudyLocation(name: "Charing Cross Hospital Campus Library", title:"St Dunstan's Rd, London W6 8RP", latitude: 51.490, longitude: -0.218, rating: 1.5, comments: [], images: [])
//]


