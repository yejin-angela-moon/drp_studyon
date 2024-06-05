import SwiftUI

struct RatingView: View {
    let ratingFactors: [String: Double]

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(ratingFactors.sorted(by: >), id: \.key) { key, value in
                HStack {
                    Text(key)
                        .font(.headline)
                    Spacer()
                    HStack {
                        ForEach(0..<5) { index in
                            Image(systemName: "star.fill")
                                .foregroundColor(index < Int(value.rounded()) ? .yellow : .gray)
                                .frame(width: 24, height: 24)
                        }
                        Text(String(format: "%.1f", value))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                }
                .padding([.leading, .trailing], 18)
                .padding(.vertical, 5)
            }
        }
        .padding()
    }
}
struct LocationDetailView: View {
    @Binding var studyLocation: StudyLocation?
    @Binding var show: Bool
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
                            .font(.largeTitle)
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            .padding([.leading, .trailing], 18)
                            .padding([.top, .bottom], 5)
            
            HStack(alignment: .center) {
                let score = String(format: "%.1f", studyLocation?.rating ?? 0)
                Text("\(score)")
                    .font(.title2)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .foregroundStyle(.orange)
                    
                
                Text("(\(studyLocation?.comments.count ?? 0))").font(.title3).fontWeight(.medium)
            }
            .padding([.leading, .trailing], 20)
            
            ImageSliderView(images: studyLocation?.images ?? []).frame(height: 300)
                .padding([.leading, .trailing], 8)
                .padding([.top, .bottom], 12)
            
            if let ratingFactors = studyLocation?.ratingFactors {
                            RatingView(ratingFactors: ratingFactors)
                        }
            
            VStack(alignment: .leading) {
                            Text("Open Hours")
                                .font(.largeTitle)
                                .padding()
                            
                            ForEach(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"], id: \.self) { day in
                                HStack {
                                    Text(day)
                                        .font(.headline)
                                    Spacer()
                                    if let hours = studyLocation?.hours[day] {
                                        Text("\(hours.open) - \(hours.close)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding([.leading, .trailing], 18)
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
