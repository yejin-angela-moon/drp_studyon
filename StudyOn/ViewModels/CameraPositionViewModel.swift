import Foundation
import MapKit
import SwiftUI

class CameraPositionViewModel: ObservableObject {
    @AppStorage("savedLatitude") private var savedLatitude: Double = 51.4988  // Default to ICL location
    @AppStorage("savedLongitude") private var savedLongitude: Double = -0.1749
    @AppStorage("savedLatitudeDelta") private var savedLatitudeDelta: Double = 0.1
    @AppStorage("savedLongitudeDelta") private var savedLongitudeDelta: Double = 0.1

    @Published var cameraPosition: MapCameraPosition

    init() {
        self.cameraPosition = .automatic
        resetCameraPosition()
    }

    public func resetCameraPosition() {
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: savedLatitude, longitude: savedLongitude),
            span: MKCoordinateSpan(latitudeDelta: savedLatitudeDelta, longitudeDelta: savedLongitudeDelta)
        )
        DispatchQueue.main.async {
            self.cameraPosition = .region(region)
        }
    }
}
