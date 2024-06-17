import SwiftUI

enum StarRounding: Int {
    case roundToHalfStar = 0
    case ceilToHalfStar = 1
    case floorToHalfStar = 2
    case roundToFullStar = 3
    case ceilToFullStar = 4
    case floorToFullStar = 5
}

struct StarSwipeView: View {
    @Binding var rating: Double
    var color: Color
    var starRounding: StarRounding
    var starSize: CGFloat = 44
    
    private let fullStar = Image(systemName: "star.fill")
    private let halfStar = Image(systemName: "star.lefthalf.fill")
    private let emptyStar = Image(systemName: "star")
    
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<5) { index in
                self.star(for: index)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: self.starSize, height: self.starSize)
                    .foregroundColor(self.color)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                self.updateRating(from: value, in: index)
                            }
                    )
            }
        }
    }
    
    private func star(for index: Int) -> Image {
        let threshold = Double(index) + 1
        switch starRounding {
        case .roundToHalfStar:
            if rating >= threshold - 0.25 {
                return fullStar
            } else if rating >= threshold - 0.75 {
                return halfStar
            } else {
                return emptyStar
            }
        case .ceilToHalfStar:
            if rating > threshold - 0.5 {
                return fullStar
            } else if rating > threshold - 1 {
                return halfStar
            } else {
                return emptyStar
            }
        case .floorToHalfStar:
            if rating >= threshold {
                return fullStar
            } else if rating >= threshold - 0.5 {
                return halfStar
            } else {
                return emptyStar
            }
        case .roundToFullStar:
            return rating >= threshold - 0.5 ? fullStar : emptyStar
        case .ceilToFullStar:
            return rating > threshold - 1 ? fullStar : emptyStar
        case .floorToFullStar:
            return rating >= threshold ? fullStar : emptyStar
        }
    }
    
    private func updateRating(from value: DragGesture.Value, in index: Int) {
        let newRating = Double(index) + Double(value.location.x / self.starSize)
        switch starRounding {
        case .roundToHalfStar, .ceilToHalfStar, .floorToHalfStar:
            rating = (newRating * 2).rounded() / 2
        case .roundToFullStar, .ceilToFullStar, .floorToFullStar:
            rating = newRating.rounded()
        }
    }
}

struct StarSwipeViewPreview: View {
    @State private var rating: Double = 3.1
    
    var body: some View {
        VStack {
//            Text("Star Swipe View")
//                .font(.title)
//                .padding()
            
            StarSwipeView(rating: $rating, color: .orange, starRounding: .ceilToHalfStar, starSize: 60)
//                .frame(height: 60)
                .padding()
//                .border(Color.gray, width: 1)
            
//            Slider(value: $rating, in: 0...5, step: 0.1)
//                .padding()
        }
    }
}

struct StarSwipeViewPreview_Previews: PreviewProvider {
    static var previews: some View {
        StarSwipeViewPreview()
    }
}
