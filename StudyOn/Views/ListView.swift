import Foundation
import SwiftUI

struct ListView: View {
    @ObservedObject var viewModel: StudyLocationViewModel
    @Binding var searchText: String
    @Binding var selectedFilter: String?

    var body: some View {
        List(viewModel.studyLocations.filter(shouldShowLocation), id: \.documentID) { location in
            HStack {
                // Image
                if let firstImageUrl = location.images.first, !firstImageUrl.isEmpty {
                    Image("imperial1")  // Assume the image name directly corresponds to an asset in Assets.xcassets
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .cornerRadius(10)
                        .background(Color.gray.opacity(0.3))
                    // AsyncImage(url: URL(string: firstImageUrl)) { phase in
                    //     if let image = phase.image {
                    //         image.resizable().aspectRatio(contentMode: .fill)
                    //     } else if phase.error != nil {
                    //         Image(systemName: "photo.fill").foregroundColor(.gray)
                    //     } else {
                    //         ProgressView()
                    //     }
                    // }
                    // .frame(width: 100, height: 100)
                    // .cornerRadius(10)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                }

                // Details
                VStack(alignment: .leading, spacing: 5) {
                    Text(location.name)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Rating: \(String(format: "%.1f", location.rating))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    HStack {
                        ForEach(location.envFactor.atmosphere, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(5)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(5)
                        }
                    }
                }
                .padding(.leading, 10)
            }
            .frame(height: 120)
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 5)
        }
        .listStyle(PlainListStyle())
    }

    private func shouldShowLocation(_ location: StudyLocation) -> Bool {
        (selectedFilter == nil || location.category == selectedFilter) &&
        (searchText.isEmpty || location.name.localizedCaseInsensitiveContains(searchText))
    }
}
