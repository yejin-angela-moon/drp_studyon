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
    
    private var db = Firestore.firestore()
    
    var body: some View {
        ZStack(alignment: .top) {
            maplayer
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
    
    private func searchPlacesOnline() async {
        let query: Query
        if searchText.isEmpty {
            query = db.collection("studyLocations")
        } else {
            query = db.collection("studyLocations").whereField("envFactors.atmosphere", arrayContains: searchText)
        }
        
        do {
            let snapshot = try await query.getDocuments()
            guard !snapshot.isEmpty else {
                print("No documents found for query: \(searchText)")
                return
            }
            self.viewModel.studyLocations = snapshot.documents.map { document -> StudyLocation in
                let data = document.data()
                print("Document data: \(data)") // 디버깅을 위해 출력
                let name = data["name"] as? String ?? ""
                let title = data["title"] as? String ?? ""
                let latitude = data["latitude"] as? Double ?? 0
                let longitude = data["longitude"] as? Double ?? 0
                let rating = data["rating"] as? Double ?? 0
                let images = data["images"] as? [String] ?? []
                let commentsData = data["comments"] as? [[String: Any]] ?? []
                let comments = commentsData.map { commentData in
                    let name = commentData["name"] as? String ?? ""
                    let content = commentData["content"] as? String ?? ""
                    let date = (commentData["date"] as? Timestamp)?.dateValue() ?? Date()
                    return Comment(name: name, content: content, date: date)
                }
                let hoursData = data["hours"] as? [String: [String: String]] ?? [:]
                let hours = hoursData.mapValues {
                    OpeningHours(opening: $0["open"] ?? "Closed", closing: $0["close"] ?? "Closed")
                }
                let envFactorData = data["envFactors"] as? [String: Any] ?? [:]
                let envFactor = EnvFactor(
                    dynamicData: envFactorData["dynamicData"] as? [String: Double] ?? [:],
                    staticData: envFactorData["staticData"] as? [String: Double] ?? [:],
                    atmosphere: envFactorData["atmosphere"] as? [String] ?? []
                )
                let num = data["num"] as? Int ?? 0
                let category = data["category"] as? String ?? ""
                return StudyLocation(
                    name: name,
                    title: title,
                    latitude: latitude,
                    longitude: longitude,
                    rating: rating,
                    comments: comments,
                    images: images,
                    hours: hours,
                    envFactor: envFactor,
                    num: num,
                    category: category
                )
            }
            print("Search results: \(self.viewModel.studyLocations)")
        } catch {
            print("Error getting documents: \(error)")
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
    private var maplayer: some View {
        Map(position: $cameraPosition, selection: $locationSelection) {
            UserAnnotation()
            
            ForEach(filteredLocations) { item in
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
    
    private var filteredLocations: [StudyLocation] {
        if let selectedFilter = selectedFilter {
            return viewModel.studyLocations.filter { $0.category.lowercased() == selectedFilter }
        } else {
            return viewModel.studyLocations
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
                            .toggleStyle(ButtonToggleStyle(filter: $selectedFilter, category: "cafe", isCategorySelected: $isCafeSelected, otherCategory: "library", isOtherCategorySelected: $isLibrarySelected))
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
