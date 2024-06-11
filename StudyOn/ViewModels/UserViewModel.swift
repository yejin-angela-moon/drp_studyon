import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class UserViewModel: ObservableObject {
    @Published var currentUser: User?
    private var db = Firestore.firestore()
    
    func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(uid).getDocument { (document, error) in
            if let document = document, document.exists {
                do {
                    let userData = try document.data(as: User.self)
                    self.currentUser = userData
                } catch {
                    print("Error decoding user: \(error)")
                }
            } else {
                print("User does not exist")
            }
        }
    }
    
    func saveUser(_ user: User) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        do {
            try db.collection("users").document(uid).setData(from: user) { error in
                if let error = error {
                    print("Error saving user: \(error)")
                } else {
                    print("User saved successfully")
                }
            }
        } catch let error {
            print("Error saving user: \(error)")
        }
    }
    
    func addFavoriteLocation(locationId: String) {
            currentUser?.favoriteLocations.append(locationId)
            objectWillChange.send()
        }
        
    func removeFavoriteLocation(locationId: String) {
        currentUser?.favoriteLocations.removeAll { $0 == locationId }
        objectWillChange.send()
    }
}
