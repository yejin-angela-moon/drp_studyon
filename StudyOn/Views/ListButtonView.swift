import Foundation
import SwiftUI

struct ListButtonView: View {
    @Binding var listDisplay: Bool
    @Binding var showPopup: Bool
    @Binding var showDetails: Bool
    @State private var buttonOffset = CGSize.zero

    var body: some View {
        Button(action: {
            listDisplay.toggle()
            if listDisplay {
                showPopup = false // Dismiss any popup when switching to list view
                showDetails = false // Dismiss any details view when switching to list view
            }
        }) {
            Label("", systemImage: listDisplay ? "map" : "list.bullet")
                .padding()
                .background(Color.gray)
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
        .padding()
        .offset(x: buttonOffset.width, y: buttonOffset.height)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    self.buttonOffset = gesture.translation
                }
                .onEnded { gesture in
                    self.buttonOffset = self.snapToEdges(translation: gesture.translation)
                }
        )
        .onAppear {
            // Initial position: Adjust based on your specific UI needs.
            // Here, placing it at the lower left edge as a starting point.
            let initialHeight = UIScreen.main.bounds.height / 2 - 70
            buttonOffset = CGSize(width: -UIScreen.main.bounds.width / 2 + 35, height: initialHeight)
        }
    }

    /// Snaps the button to the closest edge of the screen, ensuring it doesn't go off the edges.
    private func snapToEdges(translation: CGSize) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height

        // Determine horizontal snapping: Left or Right
        let edgePadding: CGFloat = 35  // Adjust this to the size of the button for better edge alignment.
        let snapHorizontal = translation.width > 0 ? (screenWidth / 2 - edgePadding) : -(screenWidth / 2 - edgePadding)

        // Determine vertical bounds and snapping
        let maxY = screenHeight - edgePadding * 2  // Adjust vertical limit to prevent off-screen disappearance.
        let minY = edgePadding
        let newVerticalOffset = translation.height  // Translation is now used directly for greater control.
        let snapVertical = min(maxY, max(minY, newVerticalOffset))

        return CGSize(width: snapHorizontal, height: snapVertical)
    }
}

