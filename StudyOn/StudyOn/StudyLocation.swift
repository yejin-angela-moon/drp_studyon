import SwiftUI
import MapKit

struct StudyLocation: Identifiable {
    let id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
    
    let rating: Double
    
//    var pinColor: Color

//    var mapMarker: Marker {
//        Marker(name, coordinate: coordinate, systemImage: "book.circle")
//    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
