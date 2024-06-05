//
//  LocationsView.swift
//  StudyOn
//
//  Created by Yejin Moon on 03/06/2024.
//

import SwiftUI
import MapKit



struct LocationsView: View {
    @StateObject private var viewModel = StudyLocationViewModel()
    @State private var cameraPosition: MapCameraPosition = .region(.userRegion)
    @State private var searchText = "" // Search text in the search text field
    @State private var results = [MKMapItem]()
    @State private var locationSelection: StudyLocation?
    @State private var showPopup = false // Show small pop up of StudyLocationView
    @State private var showDetails = false // Show LocationDetailView
    
    var body: some View {
        
        ZStack {
            maplayer
            .overlay(alignment: .top) { // Search Text Field
            searchTextField
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
                viewModel.addSampleData {
                    viewModel.fetchData()
                }
            }
        }
    }
}

#Preview {
    LocationsView()
}

extension LocationsView {
    private var maplayer: some View {
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
    }
    
    private var searchTextField: some View {
        TextField("Search For Study Location", text: $searchText)
            .font(.subheadline)
            .padding(12)
            .background(Color.white)
            .padding(.top, 6)
            .padding(.leading, 8)
            .padding(.trailing, 58)
            .shadow(radius: 10)
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
