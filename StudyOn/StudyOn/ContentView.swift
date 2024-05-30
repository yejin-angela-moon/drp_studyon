import SwiftUI
import MapKit

struct ContentView: View {
    @State private var cameraPosition: MapCameraPosition = .region(.userRegion)
    @State private var searchText = ""
    @State private var results = [MKMapItem]()
    @State private var libraries = librariesDummy
    
    var body: some View {
        Map(position: $cameraPosition) {
            UserAnnotation() // User's current location
            
//            Marker("Imperial", coordinate: .userLocation)
            ForEach(libraries, id: \.self) { location in
                Marker(location.name, systemImage: "book.fill", coordinate: location.coordinate)
                    .tint(location.markerColor)
            }
            
            ForEach(results, id: \.self) { item in
                let placemark = item.placemark
                Marker(placemark.name ?? "", coordinate: placemark.coordinate)
            }
        }
        .overlay(alignment: .top) {
            TextField("Search For Study Location", text: $searchText)
                .font(.subheadline)
                .padding(12)
                .background(.white)
                .padding(.top, 6)
                .padding(.leading, 8)
                .padding(.trailing, 58)
                .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
        }
        .onSubmit(of: /*@START_MENU_TOKEN@*/.text/*@END_MENU_TOKEN@*/) {
            print("Search for location: \(searchText)")
            Task { await searchPlacesOnline() }
            print(self.results)
        }
        .mapControls {
            MapUserLocationButton().padding()
        }
    }
}

extension CLLocationCoordinate2D {
    static var userLocation: CLLocationCoordinate2D {
        return .init(latitude:51.4988, longitude: -0.1749) // ICL Location
    }
}

extension MKCoordinateRegion {
    static var userRegion: MKCoordinateRegion {
        return .init(center: .userLocation,
                     latitudinalMeters: 10000,
                     longitudinalMeters: 10000)
    }
}

extension ContentView {
    func searchPlacesOnline() async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
//        request.region = viewingRegion ?? .userRegion
        request.region = .userRegion
        let results = try? await MKLocalSearch(request: request).start()
        self.results = results?.mapItems ?? []
    }
}

let librariesDummy: [StudyLocation] =
    [StudyLocation(name: "Imperial College London - Abdus Salam Library", latitude: +51.49805710, longitude: -0.17824890, rating: 5.0),
    StudyLocation(name: "The London Library", latitude: +51.50733901, longitude: -0.13698200, rating: 2.1),
     StudyLocation(name: "Chelsea Library", latitude: +51.48738370, longitude: -0.16837240, rating: 0.7),
    StudyLocation(name: "Fulham Library", latitude: 51.478, longitude: -0.2028, rating: 3.5),
    StudyLocation(name: "Brompton Library", latitude: 51.490, longitude: -0.188, rating: 4.1),
    StudyLocation(name: "Avonmore Library", latitude: 51.492, longitude: -0.206, rating: 4.7),
    StudyLocation(name: "Charing Cross Hospital Campus Library", latitude: 51.490, longitude: -0.218, rating: 1.5)]


#Preview {
    ContentView()
}
