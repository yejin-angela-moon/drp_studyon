import SwiftUI
import Firebase


struct LocationDetailView: View {
  @EnvironmentObject var viewModel: StudyLocationViewModel
  @Binding var studyLocation: StudyLocation?
  @Binding var show: Bool
  @Binding var userFavorites: Set<String>

  @State private var userCrowdness: Double = 0
  @State private var userNoise: Double = 0

  @State private var isOpen: Bool = true    
  @EnvironmentObject var userViewModel: UserViewModel
  @State private var isFavorite: Bool = false  
  @EnvironmentObject var fontSizeManager: FontSizeManager
  @State private var showConfirmation: Bool = false



  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
       Button {
         show.toggle()
       } label: {
         Image(systemName: "arrowtriangle.left.fill")
           .resizable()
           .frame(width: 24, height: 24)
           .foregroundStyle(.gray, Color(.systemGray6))
       }
       .padding(.leading, 15)
       .padding(.bottom, 25)

      HStack {
        Text(studyLocation?.name ?? "")
          .font(.title)
          .fontWeight(.black)
          .padding(.leading, 15)

        Spacer()

        Button(action: {
          toggleFavorite()
        }) {
          Image(systemName: isFavorite ? "heart.fill" : "heart")
            .resizable()
            .frame(width: 24, height: 24)
            .foregroundColor(isFavorite ? .red : .gray)
        }
        .padding(.trailing, 15)
        .onAppear(){
            userViewModel.fetchUserFavorites() {
                self.isFavorite = userViewModel.userFavorites.contains(studyLocation?.name ?? "")
            }
        }
      }

      HStack {
        Text(isOpen ? "Open" : "Closed")
          .font(.title2)
          .fontWeight(.bold)
          .foregroundStyle(isOpen ? .green : .red)
        Spacer()
      }
      .padding(.leading, 15)
      .padding([.top, .bottom], 5)
      .onAppear {
        isOpen = (studyLocation?.hours.isOpenNow()) != nil
      }

      HStack(alignment: .center) {
        let score = String(format: "%.1f", studyLocation?.rating ?? 0)
        StarRatingView(rating: studyLocation?.rating ?? 0)
        Text("\(score)")
          .font(.title2)
          .fontWeight(.bold)
          .foregroundStyle(.orange)

        Text("(\(studyLocation?.comments.count ?? 0))").font(.title3).fontWeight(.medium)
        Spacer()
      }
      .padding([.leading, .trailing], 15)

      HStack(alignment: .center) {
        Menu(
          "\(crowdnessLevelToText(userCrowdness: userCrowdness, dataCrowdness: studyLocation?.envFactor.dynamicData["crowdedness"] ?? -1))"
        ) {
          Button("Sparse") { userCrowdness = 1 }
          Button("Crowded") { userCrowdness = 2 }
          Button("Full") { userCrowdness = 3 }
        }
        .buttonStyle(.bordered)

        Menu(
          "\(noiseLevelToText(userNoise: userNoise, dataNoise: studyLocation?.envFactor.dynamicData["noise"] ?? -1))"
        ) {
          Button("Quiet") { userNoise = 1 }
          Button("Audible") { userNoise = 2 }
          Button("Loud") { userNoise = 3 }
        }
        .buttonStyle(.bordered)
 
        Spacer()

        Button("Submit") {
          let crowdness =
            userCrowdness == 0
            ? studyLocation?.envFactor.dynamicData["crowdedness"] ?? 0 : userCrowdness

          let noise =
            userNoise == 0 ? studyLocation?.envFactor.dynamicData["noise"] ?? 0 : userNoise
            
          NotificationHandlerModel.shared.allowDynamicDataSubmit = false

          Task {
            await viewModel.submitDynamicData(
              studyLocation: studyLocation, crowdness: crowdness, noise: noise)
          }

          withAnimation {
            showConfirmation = true
          }

          DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation {
                showConfirmation = false
            }
          }
        }
        .disabled(!NotificationHandlerModel.shared.allowDynamicDataSubmit)
        .buttonStyle(.borderedProminent)
      }
      .padding([.leading, .trailing], 20)
      .padding(.top, 10)

      ImageSliderView(images: studyLocation?.images ?? []).frame(height: 300)
        .padding([.leading, .trailing], 8)
        .padding([.top, .bottom], 12)

      if let envFactor = studyLocation?.envFactor {
        AtmosphereView(envFactor: envFactor)
      }

      openHoursButton
      if viewModel.showOpenHoursList {
        OpeningHoursView(hours: studyLocation?.hours ?? [:])
          .padding([.leading, .trailing], 18)
      }
        if studyLocation?.category == "cafe" {
            Text("Preferred Study Time: Mon-Fri 10:00 - 15:00")
                .font(.system(size: fontSizeManager.bodySize))
                .padding()
        }

      detailsButton
      if viewModel.showEnvFactors {
        if let envFactor = studyLocation?.envFactor {
          EnvView(envFactor: envFactor)
        }
      }

      VStack {
        Text("Comments")
          .font(.largeTitle)
          .padding()

        CommentsView(comments: studyLocation?.comments ?? [])
      }
      .padding(.bottom, 20)
    }
    .overlay(
      VStack {
        if showConfirmation {
          HStack {
            Spacer()
            HStack {
              Image(systemName: "checkmark")
                .foregroundColor(.white)
              Text("Submitted")
                .foregroundColor(.white)
            }
            .padding()
            .background(Color.gray)
            .cornerRadius(8)
            Spacer()
          }
          .transition(.opacity)
          .padding(.top, 200)
        }
        Spacer()
      }
    )
    .scrollable()
  }

  private func toggleFavorite() {
    if isFavorite {
      userViewModel.removeFavoriteLocation(locationId: studyLocation?.name ?? "")
        userFavorites.remove(studyLocation?.name ?? "")
    } else {
      userViewModel.addFavoriteLocation(locationId: studyLocation?.name ?? "")
        userFavorites.insert(studyLocation?.name ?? "")
    }
    isFavorite.toggle()  
  }

  private func checkIfFavorite() -> Bool {  
    guard let user = userViewModel.currentUser, let location = studyLocation else { return false }
    return user.favoriteLocations.contains(location.id.uuidString)
  }
}

//#Preview {
//  LocationDetailView(studyLocation: .constant(previewStudyLocation), show: .constant(false))
//}

struct AtmosphereView: View {
    @EnvironmentObject var fontSizeManager: FontSizeManager
    
  let envFactor: EnvFactor

  var body: some View {
    HStack {
      ForEach(envFactor.atmosphere, id: \.self) { item in
        Text("#" + item)
                    .font(.system(size: fontSizeManager.bodySize))
          .padding(.vertical, 5)
          .padding(.horizontal, 10)
          .background(Color.black)
          .foregroundColor(.white)
          .cornerRadius(10)
      }
    }
    .padding(.leading, 15)
  }
}

struct EnvView: View {
    @EnvironmentObject var fontSizeManager: FontSizeManager
    
  let envFactor: EnvFactor

  var body: some View {
    VStack(alignment: .leading) {
      ForEach(envFactor.staticData.sorted(by: >), id: \.key) { key, value in
        HStack {
          Text("\(key):")
            .font(.system(size: fontSizeManager.subheadlineSize))
          Spacer()
          Text(String(format: "%.1f", value))
            .font(.system(size: fontSizeManager.subheadlineSize))
        }
        .padding([.leading, .trailing], 18)
        .padding(.vertical, 5)
      }
    }
    .padding()
  }
}

struct OpeningHoursView: View {
    @EnvironmentObject var fontSizeManager: FontSizeManager
    
  let hours: [String: OpeningHours]
    
  var body: some View {
    VStack(alignment: .leading) {

      ForEach(
        ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"], id: \.self
      ) { (day: String) in
        HStack {
          Text(day)
            .font(.system(size: fontSizeManager.headlineSize))
          Spacer()
          if let openingHours = hours[day] {
            VStack(alignment: .trailing) {
              Text(openingHours.opening + " - " + openingHours.closing)
                .font(.system(size: fontSizeManager.subheadlineSize))
            }
          } else {
            Text("Closed")
              .font(.system(size: fontSizeManager.subheadlineSize))
              .foregroundColor(.gray)
          }
        }
        .padding(.vertical, 5)
      }
    }
    .padding(.horizontal)
  }
}

struct StarRatingView: View {
  var rating: Double

  var body: some View {
    HStack(spacing: 2) {
      ForEach(0..<5) { index in
        Image(systemName: "star.fill")
          .foregroundColor(index < Int(rating.rounded()) ? .orange : .gray)
      }
    }
  }
}

struct ImageSliderView: View {
  let images: [String]  // List of image names

  var body: some View {
    TabView {
      ForEach(images, id: \.self) { imageName in
        Image(imageName)
          .resizable()
          .scaledToFill()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .clipped()
      }
    }
    .tabViewStyle(PageTabViewStyle())
  }
}

struct CommentsView: View {
    let comments: [Comment]
    @EnvironmentObject var fontSizeManager: FontSizeManager
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 10) {
                ForEach(comments) { comment in
                    CommentRow(comment: comment)
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .font(.system(size: fontSizeManager.bodySize))
                }
            }
            .padding()
        }
    }
}

struct CommentRow: View {
    let comment: Comment
    @EnvironmentObject var fontSizeManager: FontSizeManager
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(comment.name)
                .font(.system(size: fontSizeManager.headlineSize))
                .foregroundColor(.blue)
            if let date = comment.date {
                Text(date, style: .date)
                    .font(.system(size: fontSizeManager.subheadlineSize))
                    .foregroundColor(.gray)
            }
            Text(comment.content)
                .font(.system(size: fontSizeManager.bodySize))
                .foregroundColor(.primary)
        }
    }
}

// Crowdness (Double) to Text (String) to be shown in the drop down button
func crowdnessLevelToText(userCrowdness: Double, dataCrowdness: Double) -> String {
  let crowdness = userCrowdness == 0 ? dataCrowdness : userCrowdness  // if the user has selected the crowdness, use their data

  if crowdness == -1 {
    return "Unknown"
  }

  if crowdness <= 1 {
    return "Sparse"
  } else if crowdness <= 2 {
    return "Crowded"
  } else {
    return "Full"
  }
}

// Noiseness Level (Double) to Text (String) to be shown in the drop down button
func noiseLevelToText(userNoise: Double, dataNoise: Double) -> String {
  let noise = userNoise == 0 ? dataNoise : userNoise  // if user has selected the noise, use their data

  if noise == -1 {
    return "Unknown"
  }

  if noise <= 1 {
    return "Quiet"
  } else if noise <= 2 {
    return "Audible"
  } else {
    return "Loud"
  }
}

//#Preview {
//  LocationDetailView(studyLocation: .constant(previewStudyLocation), show: .constant(false))
//}

extension View {
  func scrollable() -> some View {
    ScrollView {
      self
    }
  }
}

extension LocationDetailView {
    private var openHoursButton: some View {
        Button(action: viewModel.toggleOpenHoursList) {
            HStack {
                Image(systemName: "arrow.right")
                    .font(.system(size: fontSizeManager.headlineSize))
                    .foregroundColor(.primary)
                    .rotationEffect(Angle(degrees: viewModel.showOpenHoursList ? 90 : 0))
                Text("Open Hours")
                    .font(.system(size: fontSizeManager.title2Size))
                    .fontWeight(.black)
                    .foregroundColor(.primary)
                    .frame(height: 55, alignment: .leading)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding([.leading, .top], 5)
        }
    }
    
    private var detailsButton: some View {
        Button(action: viewModel.toggleEnvFactors) {
            HStack {
                Image(systemName: "arrow.right")
                    .font(.system(size: fontSizeManager.headlineSize))
                    .foregroundColor(.primary)
                    .rotationEffect(Angle(degrees: viewModel.showEnvFactors ? 90 : 0))
                
                Text("Details")
                    .font(.system(size: fontSizeManager.title2Size))
                    .fontWeight(.black)
                    .foregroundColor(.primary)
                    .frame(height: 55, alignment: .leading)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.leading, 5)
        }
    }
}



