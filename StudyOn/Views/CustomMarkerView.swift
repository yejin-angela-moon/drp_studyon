import SwiftUI

struct CustomMarkerView: View {
    var name: String
    var rating: Double
    var category: String
    @EnvironmentObject var fontSizeManager: FontSizeManager
    
    var body: some View {
            libraryIcon
                .shadow(radius: 3)
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
    CustomMarkerView(name: previewStudyLocation.name, rating: previewStudyLocation.rating, category: previewStudyLocation.category)
}

extension CustomMarkerView {
    private var libraryIcon: some View {
        VStack(spacing: 0) {
            Image(systemName: imageForCategory(category))
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .font(.system(size: fontSizeManager.headlineSize))
                .foregroundColor(.white)
                .padding(6)
                .background(colorForRating(rating))
                .cornerRadius(36)
            
            Image(systemName: "triangle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 10, height: 10)
                .foregroundColor(colorForRating(rating))
                .rotationEffect(Angle(degrees: 180))
                .offset(y: -3)
                .padding(.bottom, 35)
            
        }
    }
}
