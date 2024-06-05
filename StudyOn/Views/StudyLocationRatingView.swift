import SwiftUI

struct StudyLocationRatingView: View {
    @State private var rating: Double = 3
    var studyLocation: StudyLocation

    var body: some View {
        VStack {
            Text("Rate \(studyLocation.name)")
            Slider(value: $rating, in: 1...5, step: 1)
            Text("Rating: \(Int(rating))")
            Button(action: {
                // Save rating to your backend or local storage
                print("Rating for \(studyLocation.name): \(Int(rating))")
            }) {
                Text("Submit Rating")
            }
        }
        .padding()
    }
}
