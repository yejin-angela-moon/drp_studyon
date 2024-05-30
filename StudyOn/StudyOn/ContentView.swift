import SwiftUI
import MapKit

struct ContentView: View {
    @State private var cameraPosition: MapCameraPosition = .region(.userRegion) // initial camera position
    @State private var searchText = "" // Search text in the search text field
    @State private var results = [MKMapItem]()
    @State private var locationSelection: StudyLocation?
    @State private var showDetails = false // Show details about the locationSelection (StudyLocationView)
    
    @State private var libraries = librariesDummy
    
    var body: some View {
        Map(position: $cameraPosition, selection: $locationSelection) {
            UserAnnotation() // User's current location
            
            ForEach(libraries) { item in
                Annotation(item.name, coordinate: item.coordinate) {
                    CustomMarkerView(rating: item.rating)
                        .onTapGesture {
                            locationSelection = item
                        }
                }
            }
            
            // For Search result, currently unused
//            ForEach(results, id: \.self) { item in
//                let placemark = item.placemark
//                Annotation(placemark.name ?? "", coordinate: placemark.coordinate) {
//                    CustomMarkerView(rating: 0.0) // Default rating for search results
//                        .onTapGesture {
//                            // Handle tap on search result
//                        }
//                }
//            }
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
            Task { await searchPlacesOnline() }
            print(self.results)
        }
        .mapControls {
            MapUserLocationButton().padding() // Move to current location
        }
        .onChange(of: locationSelection, { oldValue, newValue in
            // when a marker is selected
            print("Show details")
            showDetails = newValue != nil
        })
        .sheet(isPresented: $showDetails, content: {
            StudyLocationView(studyLocation: $locationSelection, show: $showDetails)
                .presentationDetents([.height(340)])
                .presentationBackgroundInteraction(.enabled(upThrough: .height(340)))
                .presentationCornerRadius(12)
        })
//        .sheet(item: $mapSelection) { location in
//            StudyLocationRatingView(studyLocation: location)
//        }
    }

    private func searchPlacesOnline() async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = .userRegion
        let results = try? await MKLocalSearch(request: request).start()
        self.results = results?.mapItems ?? []
    }
}

// Dummy data and supporting structs for this example
let librariesDummy = [
    StudyLocation(name: "Imperial College London - Abdus Salam Library", title: "Imperial College London, South Kensington Campus, London SW7 2AZ", latitude: 51.49805710, longitude: -0.17824890, rating: 5.0),
    StudyLocation(name: "The London Library", title: "14 St James's Square, St. James's, London SW1Y 4LG", latitude: 51.50733901, longitude: -0.13698200, rating: 2.1),
    StudyLocation(name: "Chelsea Library", title: "Chelsea Old Town Hall, King's Rd, London SW3 5EZ", latitude: 51.48738370, longitude: -0.16837240, rating: 0.7),
    StudyLocation(name: "Fulham Library", title: "598 Fulham Rd., London SW6 5NX", latitude: 51.478, longitude: -0.2028, rating: 3.5),
    StudyLocation(name: "Brompton Library", title: "210 Old Brompton Rd, London SW5 0BS", latitude: 51.490, longitude: -0.188, rating: 4.1),
    StudyLocation(name: "Avonmore Library", title:"7 North End Crescent, London W14 8TG", latitude: 51.492, longitude: -0.206, rating: 4.7),
    StudyLocation(name: "Charing Cross Hospital Campus Library", title:"St Dunstan's Rd, London W6 8RP", latitude: 51.490, longitude: -0.218, rating: 1.5)
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

//struct StudyLocationRatingView: View {
//    @State private var rating: Double = 3
//    var studyLocation: StudyLocation
//
//    var body: some View {
//        VStack {
//            Text("Rate \(studyLocation.name)")
//            Slider(value: $rating, in: 1...5, step: 1)
//            Text("Rating: \(Int(rating))")
//            Button(action: {
//                // Save rating to your backend or local storage
//                print("Rating for \(studyLocation.name): \(Int(rating))")
//            }) {
//                Text("Submit Rating")
//            }
//        }
//        .padding()
//    }
//}

#Preview {
    ContentView()
}
