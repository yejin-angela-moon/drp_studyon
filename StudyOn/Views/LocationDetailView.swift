import SwiftUI

struct AtmophereView: View {
    let envFactor: EnvFactor
    
    var body: some View {
        HStack {
            ForEach(envFactor.atmosphere, id: \.self) { item in
                Text("#" + item)
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
    let envFactor: EnvFactor

    var body: some View {
        VStack(alignment: .leading) {
//            Text("Atmosphere")
//                .font(.headline)
//                .padding(.top)
//            ForEach(envFactor.atmosphere, id: \.self) { item in
//                Text(item)
//                    .padding(.leading, 18)
//                    .padding(.vertical, 5)
//            }
//
//            Text("Static Data")
//                .font(.headline)
//                .padding(.top)
            ForEach(envFactor.staticData.sorted(by: >), id: \.key) { key, value in
                HStack {
                    Text("\(key):")
                        .font(.subheadline)
                    Spacer()
                    Text(String(format: "%.1f", value))
                        .font(.subheadline)
                }
                .padding([.leading, .trailing], 18)
                .padding(.vertical, 5)
            }
//
//            Text("Dynamic Data")
//                .font(.headline)
//                .padding(.top)
//            ForEach(envFactor.dynamicData.sorted(by: >), id: \.key) { key, value in
//                HStack {
//                    Text("\(key):")
//                        .font(.subheadline)
//                    Spacer()
//                    Text(String(format: "%.1f", value))
//                        .font(.subheadline)
//                }
//                .padding([.leading, .trailing], 18)
//                .padding(.vertical, 5)
//            }
        }
        .padding()
    }
}

struct OpeningHoursView: View {
    let hours: [String: OpeningHours]

    var body: some View {
        VStack(alignment: .leading) {
            
            ForEach(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"], id: \.self) { (day: String) in
                HStack {
                    Text(day)
                        .font(.headline)
                    Spacer()
                    if let openingHours = hours[day] {
                        VStack(alignment: .trailing) {
                            Text(openingHours.opening + " - " + openingHours.closing)
                                .font(.subheadline)
                        }
                    } else {
                        Text("Closed")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 5)
            }
        }
        .padding(.horizontal)
    }
}

struct LocationDetailView: View {
    @StateObject private var viewModel = StudyLocationViewModel()
    @Binding var studyLocation: StudyLocation?
    @Binding var show: Bool
    
    @State private var userCrowdness: Int = 0
    @State private var userNoise: Int = 0

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
            .padding(.bottom, 8)
            
            Text(studyLocation?.name ?? "")
                            .font(.title)
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            .padding([.leading, .trailing], 18)
                            .padding([.top, .bottom], 5)
            
            HStack(alignment: .center) {
                let score = String(format: "%.1f", studyLocation?.rating ?? 0)
                StarRatingView(rating: studyLocation?.rating ?? 0)
                Text("\(score)")
                    .font(.title2)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .foregroundStyle(.orange)
                    
                
                Text("(\(studyLocation?.comments.count ?? 0))").font(.title3).fontWeight(.medium)
            }
            .padding([.leading, .trailing], 20)
            
            HStack(alignment: .center) {
//                Menu("\(crowdnessLevelToText(userCrowdness: Double(userCrowdness), dataCrowdness: studyLocation?.envFactor.dynamicData["crowdness"] ?? -1))") {
                Menu("\(crowdnessLevelToText(userCrowdness: Double(userCrowdness), dataCrowdness: 1))") {
                    Button("Sparse") { userCrowdness = 1 }
                    Button("Crowded") { userCrowdness = 2 }
                    Button("Full") { userCrowdness = 3 }
                }
                .buttonStyle(.bordered)
                
                Menu("\(noiseLevelToText(userNoise: Double(userNoise), dataNoise: 2))") {
                    Button("Quiet") { userNoise = 1 }
                    Button("Audible") { userNoise = 2 }
                    Button("Loud") { userNoise = 3 }
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Submit") {
                    // Store this answer in the database
                    if let documentID = studyLocation?.documentID {
                        viewModel.submitDynamicData(documentID: documentID, crowdness: userCrowdness, noise: userNoise)
                    } else {
                        print("Current Study Location documentID Not found")
                        return
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding([.leading, .trailing], 20)
            .padding(.top, 10)
            
            ImageSliderView(images: studyLocation?.images ?? []).frame(height: 300)
                .padding([.leading, .trailing], 8)
                .padding([.top, .bottom], 12)
            
            if let envFactor = studyLocation?.envFactor {
                AtmophereView(envFactor: envFactor)
            }
            
            openHoursButton
            if viewModel.showOpenHoursList {
                OpeningHoursView(hours: studyLocation?.hours ?? [:])
                    .padding([.leading, .trailing], 18)
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
        .scrollable()
    }
}

struct StarRatingView: View {
    var rating: Double
    
    var body: some View {
        HStack {
            ForEach(0..<5) { index in
                Image(systemName: "star.fill")
                    .foregroundColor(index < Int(rating.rounded()) ? .orange : .gray)
            }
        }
    }
}

struct ImageSliderView: View {
    let images: [String] // List of image names

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
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 10) {
                ForEach(comments) { comment in
                    CommentRow(comment: comment)
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}

struct CommentRow: View {
    let comment: Comment
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(comment.name)
                .font(.headline)
                .foregroundColor(.blue)
            if let date = comment.date {
                Text(date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Text(comment.content)
                .font(.body)
                .foregroundColor(.primary)
        }
    }
}

// Crowdness (Double) to Text (String) to be shown in the drop down button
func crowdnessLevelToText(userCrowdness: Double, dataCrowdness: Double) -> String {
    let crowdness = userCrowdness == 0 ? dataCrowdness : userCrowdness // if the user has selected the crowdness, use their data
    
    if (crowdness == -1) {
        return "Unknown"
    }
    
    if (crowdness <= 1) {
        return "Sparse"
    } else if (crowdness <= 2) {
        return "Crowded"
    } else {
        return "Full"
    }
}

// Noiseness Level (Double) to Text (String) to be shown in the drop down button
func noiseLevelToText(userNoise: Double, dataNoise: Double) -> String {
    let noise = userNoise == 0 ? dataNoise : userNoise // if user has selected the noise, use their data
    
    if (noise == -1) {
        return "Unknown"
    }
    
    if (noise <= 1) {
        return "Quiet"
    } else if (noise <= 2) {
        return "Audible"
    } else {
        return "Loud"
    }
}

#Preview {
    LocationDetailView(studyLocation: .constant(previewStudyLocation), show: .constant(false))
}

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
                    .font(.headline)
                    .foregroundColor(.primary)
                    .rotationEffect(Angle(degrees: viewModel.showOpenHoursList ? 90 : 0))
                
                Text("Open Hours")
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundColor(.primary)
                    .frame(height: 55, alignment: .leading)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }
    
    private var detailsButton: some View {
        Button(action: viewModel.toggleEnvFactors) {
            HStack {
                Image(systemName: "arrow.right")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .rotationEffect(Angle(degrees: viewModel.showEnvFactors ? 90 : 0))
                
                Text("Details")
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundColor(.primary)
                    .frame(height: 55, alignment: .leading)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }
}

