import SwiftUI
import MapKit
import Firebase

struct LocationsView: View {
    @StateObject private var viewModel = StudyLocationViewModel()
    @State private var cameraPosition: MapCameraPosition = .region(.userRegion)
    @State private var searchText = "" // Search text in the search text field
    @State private var results = [MKMapItem]()
    @State private var locationSelection: StudyLocation?
    @State private var showPopup = false // Show small pop up of StudyLocationView
    @State private var showDetails = false // Show LocationDetailView
    @State private var selectedFilter: String? = nil
    @State private var isLibrarySelected: Bool = false
    @State private var isCafeSelected: Bool = false
    @State private var hasResults: Bool = true 
    
    private var db = Firestore.firestore()
    
    var body: some View {
        ZStack(alignment: .top) {
            mapLayer
                .ignoresSafeArea()
            VStack(spacing: 0) {
                searchTextField
                    
                HStack {
                    libraryToggleButton
                    cafeToggleButton
                    Spacer()
                }
                .padding()
            }
            
            .onSubmit(of: .text) { // Handling search query
                print("Search for location: \(searchText)")
                Task { await searchPlacesOnline() }
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

    private func searchPlacesOnline() async {
        let results = viewModel.filterLocations(by: searchText)
        if results.isEmpty {
            hasResults = false // No results, hide markers
        } else {
            hasResults = true // Results found, show markers
            viewModel.studyLocations = results
        }
    }
}

#Preview {
    LocationsView()
}

struct ButtonToggleStyle: ToggleStyle {
    @Binding var filter: String?
    var category: String
    @Binding var isCategorySelected: Bool
    var otherCategory: String
    @Binding var isOtherCategorySelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            isCategorySelected.toggle()
            if isCategorySelected {
                isOtherCategorySelected = false
                filter = category
            } else {
                filter = nil
            }
        }) {
            configuration.label
                .padding(8)
                .font(.system(size: 14))
                .background(isCategorySelected ? Color.orange : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
}

extension LocationsView {
    private var mapLayer: some View {
        Map(position: $cameraPosition, selection: $locationSelection) {
            UserAnnotation()
            
            if hasResults {
                ForEach(viewModel.studyLocations) { item in
                    Annotation(item.name, coordinate: item.coordinate) {
                        CustomMarkerView(rating: item.rating, category: item.category)
                            .onTapGesture {
                                locationSelection = item
                                showPopup = true // show popup when an annotation is tapped
                            }
                    }
                }
            }
        }
    }
    
    private var searchTextField: some View {
        TextField("Search For Study Location", text: $searchText)
            .font(.subheadline)
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .padding(.top, 6)
            .padding(.horizontal)
            .shadow(radius: 10)
    }
    
    private var libraryToggleButton: some View {
        Toggle("Library", isOn: $isLibrarySelected)
            .toggleStyle(
                ButtonToggleStyle(
                    filter: $selectedFilter, 
                    category: "library", 
                    isCategorySelected: $isLibrarySelected, 
                    otherCategory: "cafe", 
                    isOtherCategorySelected: $isCafeSelected
                )
            )
            .font(.headline)

    }
    
    private var cafeToggleButton: some View {
        Toggle("Cafe", isOn: $isCafeSelected)
            .toggleStyle(
                ButtonToggleStyle(
                    filter: $selectedFilter, 
                    category: "cafe", 
                    isCategorySelected: $isCafeSelected, 
                    otherCategory: "library", 
                    isOtherCategorySelected: $isLibrarySelected
                )
            )
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
