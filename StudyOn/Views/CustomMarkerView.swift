import SwiftUI

struct CustomMarkerView: View {
  var name: String
  var rating: Double
  var category: String
    @EnvironmentObject var fontSizeManager: FontSizeManager
    var isFavorite: Bool

  var body: some View {
        libraryIcon
          .shadow(radius: 1)
  }

  func colorForRating(_ rating: Double) -> Color {
    let clampedRating = min(max(rating, 0), 5)
    let normalizedRating = clampedRating / 5.0
        
    let red: Double
        let green: Double
        
        if normalizedRating <= 0.5 {
            red = 1.0
            green = normalizedRating * 2.0
        } else {
            red = (1.0 - normalizedRating) * 2.0
            green = 1.0
        }
            
    return Color(red: red * 0.85, green: green * 0.85, blue: 0.0)
  }

  private func imageForCategory(_ category: String) -> String {
      if (isFavorite) {
          return "heart.fill"
      }
    switch category {
    case "library":
      return "book.fill"
    case "cafe":
      return "cup.and.saucer.fill"
    default:
      return "book.fill"
    }
  }
}

#Preview {
    CustomMarkerView(name: previewStudyLocation.name,
    rating: previewStudyLocation.rating, category: previewStudyLocation.category, isFavorite: true)
}

struct HeartShape: Shape {
    func path(in rect: CGRect) -> Path {
        let size = min(rect.width, rect.height)
        let xOffset = (rect.width > rect.height) ? (rect.width - rect.height) / 2.0 : 0.0
        let yOffset = (rect.height > rect.width) ? (rect.height - rect.width) / 2.0 : 0.0

        func offsetPoint(p: CGPoint) -> CGPoint {
            return CGPoint(x: p.x + xOffset, y: p.y+yOffset)
        }
        var path = Path()

        path.move(to: offsetPoint(p: (CGPoint(x: (size * 0.50), y: (size * 0.25)))))
        path.addCurve(to: offsetPoint(p: CGPoint(x: 0, y: (size * 0.25))),
                      control1: offsetPoint(p: CGPoint(x: (size * 0.50), y: (-size * 0.10))),
                      control2: offsetPoint(p: CGPoint(x: 0, y: 0)))
        path.addCurve(to: offsetPoint(p: CGPoint(x: (size * 0.50), y: size)),
                      control1: offsetPoint(p: CGPoint(x: 0, y: (size * 0.60))),
                      control2: offsetPoint(p: CGPoint(x: (size * 0.50), y: (size * 0.80))))
        path.addCurve(to: offsetPoint(p: CGPoint(x: size, y: (size * 0.25))),
                      control1: offsetPoint(p: CGPoint(x: (size * 0.50), y: (size * 0.80))),
                      control2: offsetPoint(p: CGPoint(x: size, y: (size * 0.60))))
        path.addCurve(to: offsetPoint(p: CGPoint(x: (size * 0.50), y: (size * 0.25))),
                      control1: offsetPoint(p: CGPoint(x: size, y: 0)),
                      control2: offsetPoint(p: CGPoint(x: (size * 0.50), y: (-size * 0.10))))
        return path
    }
}

extension CustomMarkerView {
  private var libraryIcon: some View {
    VStack(spacing: 0) {


      Image(systemName: imageForCategory(category))
        .resizable()
        .scaledToFit()
        .frame(width: 25, height: 25)
        .font(.system(size: fontSizeManager.headlineSize))
        .foregroundColor(.white)
        .padding(6)
        .background(isFavorite ? .pink : colorForRating(rating))
        .cornerRadius(36)

      Image(systemName: "triangle.fill")
        .resizable()
        .scaledToFit()
        .frame(width: 10, height: 10)
        .foregroundColor(isFavorite ? .pink : colorForRating(rating))
        .rotationEffect(Angle(degrees: 180))
        .offset(y: -3)
        .padding(.bottom, 35)

    }
  }
}
