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
    @State private var autoCompleteSuggestions: [String] = []
    @State private var listDisplay = false // Toggle state for map or list view
    
    private var db = Firestore.firestore()
    
    
    var body: some View {
        ZStack(alignment: .top) {
            if !listDisplay {
                mapLayer
                    .ignoresSafeArea()
            } else {
                listView // You will need to implement this view
            }

            VStack(spacing: 0) {
                searchTextField
                autoCompleteList

                HStack {
                    libraryToggleButton
                    cafeToggleButton
                    Spacer()
                }
                .padding()
            }
            .onChange(of: searchText) {
                Task {
                    await searchPlacesOnline()
                    updateAutoCompleteSuggestions()
                }
            }
            .onSubmit(of: .text) {
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

            ListButtonView(listDisplay: $listDisplay, showPopup: $showPopup, showDetails: $showDetails)
                .padding(.top, 50) // Ensure it is visible and does not overlap with other UI
                .zIndex(1) // Keep it on top of other content
        }
        .onAppear {
            viewModel.fetchData()
        }
    }
    
    private var listView: some View {
        // Here you will need to implement the list view displaying the locations
        Text("List View Placeholder")
    }
    
    // var body: some View {
    //     ZStack(alignment: .top) {
    //         mapLayer
    //             .ignoresSafeArea()
    //         VStack(spacing: 0) {
    //             searchTextField
    //             autoCompleteList
                    
    //             HStack {
    //                 libraryToggleButton
    //                 cafeToggleButton
    //                 Spacer()
    //             }
    //             .padding()
    //         }
    //         .onChange(of: searchText) {
    //             Task {await searchPlacesOnline()}
    //             updateAutoCompleteSuggestions()
    //         }
            
    //         .onSubmit(of: .text) { // Handling search query
    //             Task { await searchPlacesOnline() }
    //         }
    //         .mapControls {
    //             MapUserLocationButton().padding() // Move to current location
    //         }
    //         .onChange(of: locationSelection, { oldValue, newValue in
    //             // when a marker is selected
    //             print("Show details")
    //             showPopup = newValue != nil
    //         })
    //         .sheet(isPresented: $showDetails, content: {
    //             LocationDetailView(studyLocation: $locationSelection, show: $showDetails)
    //                 .presentationBackgroundInteraction(.disabled)
                
    //         })
    //         .sheet(isPresented: $showPopup, content: {
    //             StudyLocationView(studyLocation: $locationSelection, show: $showPopup, showDetails: $showDetails)
    //                 .presentationDetents([.height(340)])
    //                 .presentationBackgroundInteraction(.enabled(upThrough: .height(340)))
    //                 .presentationCornerRadius(12)
    //         })
    //         .onAppear {
    //             viewModel.fetchData()
    //         }
    //     }
    // }

    private func searchPlacesOnline() async {
        let results = viewModel.filterLocations(by: searchText)
        if results.isEmpty {
            hasResults = false // No results, hide markers
        } else {
            hasResults = true // Results found, show markers
            viewModel.studyLocations = results
        }
    }
    
    private func updateAutoCompleteSuggestions() {
            let allSuggestions = viewModel.allStudyLocations.map { $0.name }
            autoCompleteSuggestions = allSuggestions.filter { $0.lowercased().contains(searchText.lowercased()) }
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
                ForEach(viewModel.studyLocations.filter { selectedFilter == nil || $0.category == selectedFilter}) { item in
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
    
    private var autoCompleteList: some View {
            VStack {
                ForEach(autoCompleteSuggestions, id: \.self) { suggestion in
                    Text(suggestion)
                        .padding()
                        .background(Color.white)
                        .onTapGesture {
                            searchText = suggestion
                            Task { await searchPlacesOnline() }
                        }
                }
            }
            .background(Color.white)
            .cornerRadius(8)
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
            .font(.headline)
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
