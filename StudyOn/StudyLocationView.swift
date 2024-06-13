import SwiftUI
import MapKit

struct StudyLocationView: View {
    @Binding var studyLocation: StudyLocation?
    @Binding var show: Bool
    @Binding var showDetails: Bool
    @State private var rating: Double = 3
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(studyLocation?.name ?? "")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(studyLocation?.title ?? "")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                        .lineLimit(/*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/)
                        .padding(.trailing)
                    
                    let score = String(format: "%.1f", studyLocation?.rating ?? 0)
                    Text("\(score) / 5.0")
                }
                .padding([.leading, .trailing], 6)
                .padding([.top, .bottom], 15)
                
                Spacer()
                
                Button {
                    show.toggle()
                    showDetails.toggle()
                    studyLocation = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.gray, Color(.systemGray6))
                }
                .padding(10)
            }
            
            Button("View Details", action: {
                showDetails.toggle()
            })
        }
    }
}


let previewStudyLocation = StudyLocation(
    name: "Imperial College London - Abdus Salam Library", 
    title: "Imperial College London, South Kensington Campus, London SW7 2AZ", 
    latitude: 51.49805710, longitude: -0.17824890, rating: 5.0, 
    comments: sampleComments, 
    images: ["imperial1", "imperial2", "imperial3"], 
    hours: [
    "Monday": OpeningHours("09:00", "18:00"),
    "Tuesday": OpeningHours("09:00", "18:00"),
    "Wednesday": OpeningHours("09:00", "18:00"),
    "Thursday": OpeningHours("09:00", "18:00"),
    "Friday": OpeningHours("09:00", "18:00"),
    "Saturday": OpeningHours("10:00", "16:00"),
    "Sunday": OpeningHours("Closed", "Closed")
], envFactor: previewEnvFactor, num:4, category: "library")
#Preview {
    StudyLocationView(studyLocation: .constant(previewStudyLocation), show: .constant(false), showDetails: .constant(false))
}

let previewEnvFactor = EnvFactor(
    dynamicData: [
        "crowdedness": 2.5,
        "noise": 3.0,
    ], 
    staticData: [
        "wifi speed": 4.0,
        "spaciousness": 4.5,
        "socket no": 5.0,
    ],
    atmosphere: ["Calm", "Nice music", "Pet-friendly"]
)