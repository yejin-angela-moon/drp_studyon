import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @Binding var isUserLoggedIn: Bool
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(5)
                .padding(.horizontal, 15)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(5)
                .padding(.horizontal, 15)
            
            Button(action: loginUser) {
                Text("Login")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 220, height: 60)
                    .background(Color.blue)
                    .cornerRadius(15.0)
            }
            
            Text(errorMessage)
                .foregroundColor(.red)
                .padding()
            
            NavigationLink("Sign Up", destination: SignupView(isUserLoggedIn: $isUserLoggedIn)
                .environmentObject(userViewModel))
                .padding()
        }
        .navigationTitle("Login")
    }
    
    func loginUser() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                isUserLoggedIn = true
                userViewModel.fetchCurrentUser()
            }
        }
    }
}
