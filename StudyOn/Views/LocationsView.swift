import Firebase
import MapKit
import SwiftUI

struct LocationsView: View {
    @EnvironmentObject var viewModel: StudyLocationViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var notificationHandler: NotificationHandlerModel
    @State private var cameraPosition: MapCameraPosition = .region(.userRegion)
    @State private var searchText = ""  // Search text in the search text field
    @State private var results = [MKMapItem]()
    @State private var locationSelection: StudyLocation?
    @State private var showPopup = false  // Show small pop up of StudyLocationView
    @State private var showDetails = false  // Show LocationDetailView
    @State private var selectedFilter: String? = nil
    @State private var hasResults: Bool = true
    @State private var autoCompleteSuggestions: [String] = []
    @State private var isShowingLocationDetail = false
    @State private var selectedLocation: StudyLocation? = nil
    @State private var listDisplay = false // Toggle state for map or list view
    @State private var navigateToDetails: Bool = false
    @State private var isFavorite: Bool = false
    @State private var userFavorites = Set<String>()
    @EnvironmentObject var fontSizeManager: FontSizeManager
    @FocusState private var isInputActive: Bool
    @State private var selectedAtmospheres: [String] = []

    private var db = Firestore.firestore()
    
    private func fetchUserFavorites() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists, let favorites = document.data()?["favoriteLocations"] as? [String] {
                DispatchQueue.main.async {
                    self.userFavorites = Set(favorites)
                }
            } else {
                print("Failed to fetch favorites: \(String(describing: error))")
            }
        }
    }

    private var mapLayer: some View {
        Map(position: $cameraPosition, selection: $locationSelection) {
            UserAnnotation()
            
            if hasResults {
                ForEach(
                    viewModel.studyLocations.filter {
                        selectedFilter == nil || $0.category == selectedFilter || (selectedFilter == "fav" && userFavorites.contains($0.name))
                    }
                ) { item in
                    Annotation(item.name, coordinate: item.coordinate) {
                        CustomMarkerView(
                            name: item.name, rating: item.rating, category: item.category, isFavorite: userFavorites.contains(item.name)
                        )
                        .environmentObject(fontSizeManager)
                        .onTapGesture {
                            locationSelection = item
                            showPopup = true  // show popup when an annotation is tapped
                        }
                    }
                }
            }
        }
    }

    private var searchTextField: some View {
        ZStack(alignment: .leading) {
            TextField("Search For Study Location", text: $searchText)
                .font(.system(size: fontSizeManager.subheadlineSize))
                .padding(.leading, selectedAtmospheres.isEmpty ? 10 : CGFloat(selectedAtmospheres.joined(separator: "").count * 8 + 30 + selectedAtmospheres.count * 50))
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .padding(.vertical, 6)
                .shadow(radius: 10)
                .onChange(of: searchText) { newValue in
                    updateFilteredLocations()
                    updateAutoCompleteSuggestions()
                }
                .onSubmit {
                    isInputActive = false  // Dismiss keyboard on submit
                }
                .focused($isInputActive)
            
            HStack(spacing: 4) {
                // Display selected atmosphere tags over the search box
                ForEach(selectedAtmospheres, id: \.self) { tag in
                    HStack {
                        Text("#\(tag)")
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(8)
                        Button(action: {
                            selectedAtmospheres.removeAll { $0 == tag }
                            updateFilteredLocations()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .padding(.leading, 8)
            .padding(.vertical, 6)
        }
        .padding(.horizontal)
    }
    
    private var autoCompleteList: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(autoCompleteSuggestions.prefix(10), id: \.self) { suggestion in  // Display up to 10 suggestions
                    Text(suggestion)
                        .font(.system(size: fontSizeManager.bodySize))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .onTapGesture {
                            if searchText.hasPrefix("#") {
                                selectedAtmospheres.append(suggestion)
                                searchText = ""
                                autoCompleteSuggestions = []
                                updateFilteredLocations()
                            } else {
                                searchText = suggestion
                                autoCompleteSuggestions = []
                                Task { await searchPlacesOnline() }
                            }
                            isInputActive = false
                        }
                }
            }
        }
        .frame(maxHeight: CGFloat(min(autoCompleteSuggestions.count, 5) * 52))  // Dynamically adjust height
        .background(Color.white)
        .cornerRadius(8)
        .padding(.horizontal)
        .shadow(radius: 10)
    }



    var body: some View {
        ZStack(alignment: .top) {
            if !listDisplay {
                mapLayer
                    .ignoresSafeArea()
            } else {
                listView
                    .padding(.top, 110)
            }

            VStack(spacing: 0) {
                searchTextField

                HStack {
                    libraryToggleButton
                    cafeToggleButton
                    favoritesToggleButton
                    Spacer()
                    fontSizeUpButton
                    fontSizeDownButton
                }
                .padding()
            }
            .mapControls {
                MapUserLocationButton().padding() // Move to current location
            }
            .onChange(of: notificationHandler.doNavigate, { oldValue, newValue in
                print("notification handler activated in LocationsView")
                if newValue { // The user pressed the notification
                    self.locationSelection = notificationHandler.studyLocation
                } else {
                    self.locationSelection = nil
                }
            })
            .onChange(of: locationSelection, { oldValue, newValue in
                // when a marker is selected
                print("Show details")
                showPopup = newValue != nil
            })
            
            if showPopup {
                VStack {
                    Spacer()
                    StudyLocationView(studyLocation: $locationSelection, show: $showPopup, showDetails: $showDetails, userFavorites: $userFavorites)
                        .frame(height: UIScreen.main.bounds.height / 2 - 60)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 10)
                        .transition(.move(edge: .bottom))
                        .environmentObject(viewModel)
                        .environmentObject(userViewModel)
                        .environmentObject(notificationHandler)
                }
                .edgesIgnoringSafeArea(.bottom)
                .zIndex(2)
            }
            
            ListButtonView(listDisplay: $listDisplay, showPopup: $showPopup, showDetails: $showDetails)
                .padding(.top, 50) // Ensure it is visible and does not overlap with other UI
                .zIndex(1) // Keep it on top of other content

            if !autoCompleteSuggestions.isEmpty {
                autoCompleteList
                    .zIndex(3) // Ensure it is on top of everything
                    .padding(.top, 60) // Adjust the position to appear below the search bar
            }
        }
        .onAppear {
            viewModel.fetchData()
            fetchUserFavorites()
        }
        .onReceive(userViewModel.$userFavorites) { updatedFavorites in
            self.userFavorites = Set(updatedFavorites)
        }
        .onTapGesture {
            isInputActive = false
            self.hideKeyboard()
        }
    }
    
    var listView: some View {
        ListView(searchText: $searchText, selectedFilter: $selectedFilter, userFavorites: $userFavorites, showDetails: $showDetails)
            .environmentObject(fontSizeManager)
    }

    private func updateFilteredLocations() {
        if searchText.isEmpty && selectedAtmospheres.isEmpty {
            viewModel.studyLocations = viewModel.allStudyLocations
        } else if !selectedAtmospheres.isEmpty {
            let results = viewModel.allStudyLocations.filter { location in
                selectedAtmospheres.allSatisfy { atmosphere in
                    location.envFactor.atmosphere.contains { $0.localizedCaseInsensitiveContains(atmosphere) }
                }
            }
            viewModel.studyLocations = results
        } else {
            let results = viewModel.allStudyLocations.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
            viewModel.studyLocations = results
        }
        hasResults = !viewModel.studyLocations.isEmpty
    }

    private func searchPlacesOnline() async {
        let results = viewModel.filterLocations(by: searchText)
        if results.isEmpty {
            hasResults = false  // No results, hide markers
        } else {
            hasResults = true  // Results found, show markers
            viewModel.studyLocations = results
        }
    }

    private func updateAutoCompleteSuggestions() {
        if searchText.hasPrefix("#") {
            let query = searchText.dropFirst().lowercased()
            let allAtmospheres = viewModel.allStudyLocations.flatMap { $0.envFactor.atmosphere }
            autoCompleteSuggestions = Array(Set(allAtmospheres.filter { $0.lowercased().contains(query) }))
        } else {
            let allSuggestions = viewModel.allStudyLocations.map { $0.name }
            autoCompleteSuggestions = allSuggestions.filter {
                $0.lowercased().contains(searchText.lowercased())
            }
        }
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

struct RoundedToggleStyle: ToggleStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            configuration.label
                .padding(8)
                .background(configuration.isOn ? Color.green : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
}

extension CLLocationCoordinate2D {
    static var userLocation: CLLocationCoordinate2D {
        return .init(latitude: 51.4988, longitude: -0.1749)  // ICL Location
    }
}

extension MKCoordinateRegion {
    static var userRegion: MKCoordinateRegion {
        return .init(
            center: .userLocation,
            latitudinalMeters: 10000,
            longitudinalMeters: 10000)
    }
}

extension LocationsView {
    private var libraryToggleButton: some View {
        Toggle("Library", isOn: Binding<Bool>(
            get: { selectedFilter == "library" },
            set: { newValue in
                selectedFilter = newValue ? "library" : nil
            }
        ))
        .toggleStyle(RoundedToggleStyle())
        .font(.system(size: fontSizeManager.headlineSize))
    }

    private var cafeToggleButton: some View {
        Toggle("Cafe", isOn: Binding<Bool>(
            get: { selectedFilter == "cafe" },
            set: { newValue in
                selectedFilter = newValue ? "cafe" : nil
            }
        ))
        .toggleStyle(RoundedToggleStyle())
        .font(.system(size: fontSizeManager.headlineSize))
    }
    
    private var favoritesToggleButton: some View {
        Toggle("Favorites", isOn: Binding<Bool>(
            get: { selectedFilter == "fav" },
            set: { newValue in
                selectedFilter = newValue ? "fav" : nil
            }
        ))
        .toggleStyle(RoundedToggleStyle())
        .font(.system(size: fontSizeManager.headlineSize))
    }
    
    private var fontSizeUpButton: some View {
        Button(action: {
            if fontSizeManager.titleSize < fontSizeManager.maxTitleSize {
                fontSizeManager.titleSize += 2
                fontSizeManager.headlineSize += 2
                fontSizeManager.captionSize += 2
                fontSizeManager.title2Size += 2
                fontSizeManager.title3Size += 2
                fontSizeManager.subheadlineSize += 2
                fontSizeManager.bodySize += 2
            }
        }) {
            Text("A+")
                .font(.title2)
        }
    }
    
    private var fontSizeDownButton: some View {
        Button(action: {
            if fontSizeManager.titleSize > fontSizeManager.minTitleSize {
                fontSizeManager.titleSize -= 2
                fontSizeManager.headlineSize -= 2
                fontSizeManager.captionSize -= 2
                fontSizeManager.title2Size -= 2
                fontSizeManager.title3Size -= 2
                fontSizeManager.subheadlineSize -= 2
                fontSizeManager.bodySize -= 2
            }
        }) {
            Text("A-")
                .font(.title2)
        }
    }
}
