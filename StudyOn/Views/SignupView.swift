import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignupView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var name = ""
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
            TextField("Name", text: $name)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(5)
                .padding(.horizontal, 15)
            
            Button(action: signupUser) {
                Text("Sign Up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 220, height: 60)
                    .background(Color.green)
                    .cornerRadius(15.0)
            }
            
            Text(errorMessage)
                .foregroundColor(.red)
                .padding()
            
            NavigationLink("Login", destination: LoginView(isUserLoggedIn: $isUserLoggedIn)
                .environmentObject(userViewModel))
                .padding()
        }
        .navigationTitle("Sign Up")
    }
    
    func signupUser() {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else if let authResult = authResult {
                let newUser = User(
                    id: authResult.user.uid,
                    email: email,
                    password: password,
                    name: name
                )
                userViewModel.saveUser(newUser)
                isUserLoggedIn = true
            }
        }
    }
}
