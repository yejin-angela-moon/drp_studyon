import SwiftUI
import MapKit

struct StudyLocationView: View {
    @EnvironmentObject var viewModel: StudyLocationViewModel
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var notificationHandler: NotificationHandlerModel
    @State var studyLocation: StudyLocation?
    @Binding var show: Bool
    @Binding var showDetails: Bool
    @Binding var userFavorites: Set<String>
    @State private var rating: Double = 3
    @State private var navigateToDetails: Bool = false
    @EnvironmentObject var fontSizeManager: FontSizeManager
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Spacer()
                    Button {
                        show.toggle()
                        showDetails = false
                        notificationHandler.doNavigate = false
                        studyLocation = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.gray, Color(.systemGray6))
                    }
                    .padding([.top], 20)
                    .padding([.trailing], 10)
                }
                HStack(alignment: .bottom, spacing: 0) {
                    VStack(alignment: .leading, spacing: 12.0) {
                        imageSection
                        nameSection
                        titleSection

                        HStack(alignment: .center, spacing: 10) {
                            let score = String(format: "%.1f", studyLocation?.rating ?? 0)
                            StarRatingView(rating: studyLocation?.rating ?? 0, color: .orange, starRounding: .ceilToHalfStar, starSize: 20)
                            Text("\(score)")
                              .font(.title2)
                              .fontWeight(.bold)
                              .foregroundStyle(.orange)
//                              .padding(10)
    //                        Text("\(score) / 5.0")
                        }
                        .onChange(of: showDetails) { _, doShow in
                            if !doShow {
                                viewModel.fetchData()
                                let docID = studyLocation?.documentID ?? ""
                                studyLocation = viewModel.findLocationByDocumentID(documentIDKey: docID)
                            }
                        }
                    }
                }
                .padding(20)
                .background(RoundedRectangle(cornerRadius: 10)
                    .fill(.ultraThinMaterial)
                    .offset(y: 65))
                .cornerRadius(10)
                .onAppear {
                    if notificationHandler.doNavigate {
                        showDetails = true
                    }
                }
                .onChange(of: notificationHandler.doNavigate, {oldValue, newValue in
                    print("changed!")
                    showDetails = newValue
                })
                
                Button("View Details") {
                    showDetails = true
                }
                .fullScreenCover(isPresented: $showDetails) {
                    if let studyLocation = studyLocation {
                        LocationDetailView(studyLocation: studyLocation, show: $showDetails, userFavorites: $userFavorites)
                            .environmentObject(viewModel)
                            .environmentObject(userViewModel)
                    }
                }
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            viewModel.fetchData()
        }
    }
}
    
let previewStudyLocation = StudyLocation(
    documentID: "JQwhtqVLyl1U5XX4iF1H",
    name: "Imperial College London - Abdus Salam Library",
    title: "Imperial College London, South Kensington Campus, London SW7 2AZ", 
    latitude: 51.49805710, 
    longitude: -0.17824890, 
    rating: 5.0, 
    comments: sampleComments, 
    images: ["imperial1", "imperial2", "imperial3"], 
    hours: previewOpeningHours, 
    envFactor: previewEnvFactor, 
    num:4, 
    category: "Library"
)
//#Preview {
//    StudyLocationView(studyLocation: .constant(previewStudyLocation), show: .constant(false), showDetails: .constant(false))
//}

let previewOpeningHours = [
    "Monday": OpeningHours(opening: "09:00", closing: "18:00"),
    "Tuesday": OpeningHours(opening: "09:00", closing: "18:00"),
    "Wednesday": OpeningHours(opening: "09:00", closing: "18:00"),
    "Thursday": OpeningHours(opening: "09:00", closing: "18:00"),
    "Friday": OpeningHours(opening: "09:00", closing: "18:00"),
    "Saturday": OpeningHours(opening: "10:00", closing: "16:00"),
    "Sunday": OpeningHours(opening: "Closed", closing: "Closed")
]

let previewEnvFactor = EnvFactor(
    dynamicData: [
        "crowdedness": 2.5,
        "noise": 3.0,

    ], 
    staticData: [
        "wifi speed": 4.0,
        "# tables": 5,
        "socket no": 5.0,
        "# PCs": 10,
        "# meeting rooms": 1
    ],
    atmosphere: ["Calm", "Nice music", "Pet-friendly"]
)


extension StudyLocationView {
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(studyLocation?.name ?? "")
                .font(.system(size: fontSizeManager.titleSize))
            .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var imageSection: some View {
        ZStack {
            if let imageName = studyLocation?.images.first {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .cornerRadius(10)
            }
        }
        .padding(6)
        .background(Color.white)
        .cornerRadius(10)
    }
    
    private var titleSection: some View {
        VStack {
            Text(studyLocation?.title ?? "")
                .font(.system(size: fontSizeManager.captionSize))
                .foregroundStyle(.gray)
                .lineLimit(/*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/)
            .padding(.trailing)
        }
    }
    
    private var backButton: some View {
        Button {
//            vm.sheetLocation = nil
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: fontSizeManager.titleSize))
                .padding(16)
                .foregroundColor(.primary)
                .background(.thickMaterial)
                .cornerRadius(10)
                .shadow(radius: 4)
                .padding()
        }
    }

}
