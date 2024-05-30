import SwiftUI
import MapKit

struct StudyLocation: Hashable {
    let id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
    
    let rating: Double
    
    var markerColor: Color {
        colorForRating(rating)
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

func colorForRating(_ rating: Double) -> Color {
    // Ensure the rating is clamped between 0 and 5
    let clampedRating = min(max(rating, 0), 5)
    
    // Calculate the green component (it increases as the rating increases)
    let green = clampedRating / 5.0
    
    // Calculate the red component (it decreases as the rating increases)
    let red = (5.0 - clampedRating) / 5.0
    
    // Return the interpolated color
    return Color(red: red, green: green, blue: 0.0)
}
