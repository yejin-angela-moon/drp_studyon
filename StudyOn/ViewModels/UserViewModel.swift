import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

class UserViewModel: ObservableObject {
  @Published var currentUser: User?

  private var db = Firestore.firestore()

  func fetchCurrentUser() {
    guard let userId = Auth.auth().currentUser?.uid else {
      print("No user is currently logged in.")
      return
    }
    let docRef = db.collection("users").document(userId)
    docRef.getDocument { (document, error) in
      if let document = document, document.exists {
        do {
          self.currentUser = try document.data(as: User.self)
        } catch {
          print("Error decoding user: \(error.localizedDescription)")
        }
      } else {
        print("User does not exist")
      }
    }
  }

  func addFavoriteLocation(locationId: String) {
    guard let user = currentUser, let userId = user.id else { return }
    var updatedFavorites = user.favoriteLocations
    if !updatedFavorites.contains(locationId) {
      updatedFavorites.append(locationId)
      updateFavoriteLocations(userId: userId, favoriteLocations: updatedFavorites)
    }
  }

  func removeFavoriteLocation(locationId: String) {
    guard let user = currentUser, let userId = user.id else { return }
    var updatedFavorites = user.favoriteLocations
    updatedFavorites.removeAll { $0 == locationId }
    updateFavoriteLocations(userId: userId, favoriteLocations: updatedFavorites)
  }

  private func updateFavoriteLocations(userId: String, favoriteLocations: [String]) {
    let docRef = db.collection("users").document(userId)
    docRef.updateData(["favoriteLocations": favoriteLocations]) { error in
      if let error = error {
        print("Error updating favorite locations: \(error.localizedDescription)")
      } else {
        self.currentUser?.favoriteLocations = favoriteLocations
        print("Favorite locations successfully updated")
      }
    }
  }

  func saveUser(_ user: User) {
    guard let uid = Auth.auth().currentUser?.uid else { return }

    do {
      try db.collection("users").document(uid).setData(from: user) { error in
        if let error = error {
          print("Error saving user: \(error.localizedDescription)")
        } else {
          print("User saved successfully")
        }
      }
    } catch let error {
      print("Error saving user: \(error.localizedDescription)")
    }
  }
}
