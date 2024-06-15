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
  @State private var isLibrarySelected: Bool = false
  @State private var isCafeSelected: Bool = false
  @State private var hasResults: Bool = true
  @State private var autoCompleteSuggestions: [String] = []
  @State private var isShowingLocationDetail = false
  @State private var selectedLocation: StudyLocation? = nil
  @State private var listDisplay = false // Toggle state for map or list view
  @State private var navigateToDetails: Bool = false
  @State private var isFavorite: Bool = false
  @State private var userFavorites = Set<String>()
  @EnvironmentObject var fontSizeManager: FontSizeManager

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
          viewModel.allStudyLocations.filter {
            selectedFilter == nil || $0.category == selectedFilter 
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
    TextField("Search For Study Location", text: $searchText)
      .font(.system(size: fontSizeManager.subheadlineSize))
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
          .font(.system(size: fontSizeManager.bodySize))
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
      .font(.system(size: fontSizeManager.headlineSize))

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
      .font(.system(size: fontSizeManager.headlineSize))
  } 

  var body: some View {
        ZStack(alignment: .top) {
            if !listDisplay {
                mapLayer
                    .ignoresSafeArea()
            } else {
                listView
                    .padding(.top, 60)
            }

            VStack(spacing: 0) {
                searchTextField
                autoCompleteList

                HStack {
                    libraryToggleButton
                    cafeToggleButton
                    Spacer()
                    fontSizeUpButton
                    fontSizeDownButton
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
                    StudyLocationView(studyLocation: $locationSelection, show: $showPopup, showDetails: $showDetails)
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
        }
        .onAppear {
            viewModel.fetchData()
            fetchUserFavorites()
        }
    }
    
    var listView: some View {
        ListView(searchText: $searchText, selectedFilter: $selectedFilter)
            .environmentObject(fontSizeManager)
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
    let allSuggestions = viewModel.allStudyLocations.map { $0.name }
    autoCompleteSuggestions = allSuggestions.filter {
      $0.lowercased().contains(searchText.lowercased())
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
    @EnvironmentObject var fontSizeManager: FontSizeManager

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
        .font(.system(size: fontSizeManager.bodySize))
        .background(isCategorySelected ? Color.orange : Color.gray)
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
