//
//  StudyLocationView.swift
//  StudyOn
//
//  Created by Victor Kang on 5/30/24.
//

import SwiftUI
import MapKit

struct StudyLocationView: View {
    @Binding var studyLocation: StudyLocation?
    @Binding var show: Bool
    @Binding var showDetails: Bool
    @State private var rating: Double = 3
    
    var body: some View {
        Spacer()
        HStack(alignment: .bottom, spacing: 0) {
            VStack(alignment: .leading, spacing: 16.0) {
                imageSection
                nameSection
                titleSection
                
                let score = String(format: "%.1f", studyLocation?.rating ?? 0)
                Text("\(score) / 5.0")
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 10)
            .fill(.ultraThinMaterial)
            .offset(y: 65))
        .cornerRadius(10)
        Button {
            show.toggle()
            showDetails = false
            studyLocation = nil
        } label: {
            Image(systemName: "xmark.circle.fill")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(.gray, Color(.systemGray6))
        }
        .padding(10)
        Button("View Details", action: {
            showDetails.toggle()
        })
    }
    
    
    
    //        VStack {
    //            HStack(alignment: .top) {
    //                VStack(alignment: .leading) {
    //                    nameSection
    //
    //                    titleSection
    //
    //                    let score = String(format: "%.1f", studyLocation?.rating ?? 0)
    //                    Text("\(score) / 5.0")
    //                }
    //                .padding([.leading, .trailing], 6)
    //                .padding([.top, .bottom], 15)
    //
    //                Spacer()
    //
    //                Button {
    //                    show.toggle()
    //                    showDetails.toggle()
    //                    studyLocation = nil
    //                } label: {
    //                    Image(systemName: "xmark.circle.fill")
    //                        .resizable()
    //                        .frame(width: 24, height: 24)
    //                        .foregroundStyle(.gray, Color(.systemGray6))
    //                }
    //                .padding(10)
    //            }
    //
    //            Button("View Details", action: {
    //                showDetails.toggle()
    //            })
    //
    //            Slider(value: $rating, in: 1...5, step: 1).padding([.leading, .trailing], 30)
    //            Text("Rating: \(Int(rating))")
    //            Button(action: {
    //                // Should save rating to the backend
    //                print("Rating for \(studyLocation?.name ?? "nil"): \(Int(rating))")
    //
    ////                studyLocation?.rating = rating
    //                show.toggle()
    //                studyLocation = nil
    //            }) {
    //                Text("Submit Rating")
    //            }.padding(10)
    //        }
    //    }
    //}
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
#Preview {
    StudyLocationView(studyLocation: .constant(previewStudyLocation), show: .constant(false), showDetails: .constant(false))
}

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
        "crowdness": 2.5,
        "noise": 3.0,

    ], 
    staticData: [
        "wifi speed": 4.0,
        "spaciousness": 4.5,
        "socket no": 5.0,
    ],
    atmosphere: ["Calm", "Nice music", "Pet-friendly"]
)


extension StudyLocationView {
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(studyLocation?.name ?? "")
                .font(.title2)
            .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var imageSection: some View {
        ZStack {
            if let imageName = previewStudyLocation.images.first {
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
                .font(.footnote)
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
                .font(.headline)
                .padding(16)
                .foregroundColor(.primary)
                .background(.thickMaterial)
                .cornerRadius(10)
                .shadow(radius: 4)
                .padding()
        }
    }

}
