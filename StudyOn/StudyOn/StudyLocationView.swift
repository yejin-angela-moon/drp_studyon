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
                    studyLocation = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.gray, Color(.systemGray6))
                }
                .padding(10)
            }
            
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
        }
    }
}



let sampleComments = [
    Comment(name: "Alice", content: "Great place to study!", date: Date()),
    Comment(name: "Bob", content: "Quite noisy during peak hours.", date: Date()),
    Comment(name: "Charlie", content: "Friendly staff and good resources.", date: Date())
]

let previewStudyLocation = StudyLocation(name: "Imperial College London - Abdus Salam Library", title: "Imperial College London, South Kensington Campus, London SW7 2AZ", latitude: 51.49805710, longitude: -0.17824890, rating: 5.0, comments: sampleComments, images: ["imperial1", "imperial2", "imperial3"])
#Preview {
    StudyLocationView(studyLocation: .constant(previewStudyLocation), show: .constant(false))
}
