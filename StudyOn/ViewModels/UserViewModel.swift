import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

class UserViewModel: ObservableObject {
  @Published var currentUser: User?
  @Published var isUserLoggedIn: Bool = false
  @Published var userFavorites: [String] = []

  private var db = Firestore.firestore()
    
    init() {
        autoLogin()
    }

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
    
    func fetchUserFavorites(completion: @escaping () -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                if let user = try? document.data(as: User.self) {
                    self.userFavorites = user.favoriteLocations
                    completion() // 클로저 호출
                }
            }
        }
    }


    func isFavorite(locationId: String) -> Bool {
      return userFavorites.contains(locationId)
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
    
    func autoLogin() {
        guard let emailData = KeychainService.load(key: "email"),
              let passwordData = KeychainService.load(key: "password"),
              let email = String(data: emailData, encoding: .utf8),
              let password = String(data: passwordData, encoding: .utf8) else {
            DispatchQueue.main.async {
                self.isUserLoggedIn = false
            }
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.isUserLoggedIn = false
                print("Auto login failed: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.isUserLoggedIn = true
                    self.fetchCurrentUser()
                }
            }
        }
    }
}

