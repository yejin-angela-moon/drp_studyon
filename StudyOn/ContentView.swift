import SwiftUI
import MapKit
import FirebaseFirestore
struct ContentView: View {
    @StateObject private var viewModel = StudyLocationViewModel()
    @State private var cameraPosition: MapCameraPosition = .region(.userRegion) // initial camera position
    @State private var searchText = "" // Search text in the search text field
    @State private var results = [MKMapItem]()
    @State private var locationSelection: StudyLocation?
    @State private var showPopup = false // Show small pop up of StudyLocationView
    @State private var showDetails = false // Show LocationDetailView
        
    private var db = Firestore.firestore()
    
    var body: some View {
        
        NavigationView {
            Map(position: $cameraPosition, selection: $locationSelection) {
                UserAnnotation()
                
                ForEach(viewModel.studyLocations) { item in
                    Annotation(item.name, coordinate: item.coordinate) {
                        CustomMarkerView(rating: item.rating)
                            .onTapGesture {
                                locationSelection = item
                                showPopup = true // show popup when an annotation is tapped
                            }
                    }
                }
            }
            .overlay(alignment: .top) { // Search Text Field
                TextField("Search For Study Location", text: $searchText)
                    .font(.subheadline)
                    .padding(12)
                    .background(Color.white)
                    .padding(.top, 6)
                    .padding(.leading, 8)
                    .padding(.trailing, 58)
                    .shadow(radius: 10)
            }
            .onSubmit(of: .text) { // Handling search query
                print("Search for location: \(searchText)")
//                Task { await searchPlacesOnline() }
                print(self.results)
            }
            .mapControls {
                MapUserLocationButton().padding() // Move to current location
            }
            .onChange(of: locationSelection, { oldValue, newValue in
                // when a marker is selected
                print("Show details")
                showPopup = newValue != nil
            })
            .sheet(isPresented: $showDetails, content: {
                LocationDetailView(studyLocation: $locationSelection, show: $showDetails)
                    .presentationBackgroundInteraction(.disabled)
                
            })
            .sheet(isPresented: $showPopup, content: {
                StudyLocationView(studyLocation: $locationSelection, show: $showPopup, showDetails: $showDetails)
                    .presentationDetents([.height(340)])
                    .presentationBackgroundInteraction(.enabled(upThrough: .height(340)))
                    .presentationCornerRadius(12)
            })
            .onAppear {
                    viewModel.fetchData()
                }
            }
        }
    }

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


let sampleComments = [
    Comment(name: "Alice", content: "Great place to study!", date: Date()),
    Comment(name: "Bob", content: "Quite noisy during peak hours.", date: Date()),
    Comment(name: "Charlie", content: "Friendly staff and good resources.", date: Date())
]

struct CustomMarkerView: View {
    var rating: Double
    
    var body: some View {
        VStack {
            Image(systemName: "book.fill")
                .foregroundColor(.white)
                .padding(6)
                .background(colorForRating(rating))
                .clipShape(Circle())
        }
        .shadow(radius: 3)
    }

    func colorForRating(_ rating: Double) -> Color {
        let clampedRating = min(max(rating, 0), 5)
        let green = clampedRating / 5.0
        let red = (5.0 - clampedRating) / 5.0
        return Color(red: red, green: green, blue: 0.0)
    }
}

extension CLLocationCoordinate2D {
    static var userLocation: CLLocationCoordinate2D {
        return .init(latitude: 51.4988, longitude: -0.1749) // ICL Location
    }
}

extension MKCoordinateRegion {
    static var userRegion: MKCoordinateRegion {
        return .init(center: .userLocation,
                     latitudinalMeters: 10000,
                     longitudinalMeters: 10000)
    }
}

#Preview {
    ContentView()
}
