//
//  ContentView.swift
//  LBTASwiftUIFirebaseChat
//
//  Created by Smith, Mitchel on 5/3/22.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseStorage


struct LoginView: View {
    
    let didCompleteLoginProcess: () -> ()
    
    @State private var isLoginMode = true
    @State private var email = ""
    @State private var password = ""
    @State private var shouldShowImagePicker = false
    
    var body: some View {
        NavigationView{
            ScrollView{
                VStack{
                    Picker(selection: $isLoginMode, label: Text("Picker here")){
                        Text("Login")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                    }.pickerStyle(SegmentedPickerStyle())
                    
                    if !isLoginMode{
                        Button{
                            shouldShowImagePicker.toggle()
                        } label: {
                            
                            VStack{
                                if let image = self.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 72, height: 72)
                                        .cornerRadius(32)
                                        
                                }
                                else{
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 72))
                                        .padding()
                                        .background(Color.clear)
                                        .foregroundColor(Color.black)
                                }
                            }
                        }
                        .overlay(Circle()
                            .stroke(Color.black, lineWidth: 2)
                        )
                    }
                    
                    Group{
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        SecureField("Password", text: $password)
                    }
                    .background(Color.white)
                    .padding(.vertical, 2)
                    .disableAutocorrection(true)
                    
                    
                    Button{
                        handleAction()
                    } label: {
                        HStack{
                            Spacer()
                            Text(isLoginMode ? "Login" : "Create Account")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                            
                            Spacer()
                        }
                        .background(Color.blue)
                        .cornerRadius(15)
                        .font(.system(size:18, weight: .semibold))
                    }
                    Text(self.loginStatusMessage)
                        .foregroundColor((self.wasCreationSuccessful ?? false ? .green : .red))
                    
                }
                .navigationTitle(isLoginMode ? "Login" : "Create Account")
                .padding(12)
            }
            .background(Color.gray.opacity(0.1))
            
        }.ignoresSafeArea()
            .navigationViewStyle(StackNavigationViewStyle())
            .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
                ImagePicker(image: $image)
            }
    }
    
    @State var image: UIImage?
    
    private func handleAction(){
        if isLoginMode{
            loginUser()
            //print("Should Log into Firebase with email: \(email)")
        }
        else{
            createNewAccount()
            //print("Should regiser new credentials to Firebase")
        }
    }
    private func loginUser() {
        
        FirebaseManager.shared.auth.signIn(withEmail: self.email, password: self.password) { result, err in
            if let err = err {
                print("Failed to login user:", err)
                self.loginStatusMessage = "Failed to login user: \(err)"
                self.wasCreationSuccessful = false
                return
            }
            
            print("Successfully logged in user: \(result?.user.uid ?? "")")
            self.loginStatusMessage = "Successfully logged in user: \(result?.user.uid ?? "")"
            self.wasCreationSuccessful = true
            
            self.didCompleteLoginProcess()
        }
    }
    
    @State var loginStatusMessage = ""
    @State var wasCreationSuccessful: Bool?
    
    private func createNewAccount() {
        if self.image == nil {
            self.loginStatusMessage = "You must select an avatar image"
            return
        }
        FirebaseManager.shared.auth.createUser(withEmail: self.email, password: self.password) { result, err in
            if let err = err {
                print("Failed to create user:", err)
                self.loginStatusMessage = "Failed to create user: \(err)"
                self.wasCreationSuccessful = false
                return
            }
            
            print("Successfully created user: \(result?.user.uid ?? "")")
            self.loginStatusMessage = "Successfully created user: \(result?.user.uid ?? "")"
            self.wasCreationSuccessful = true
            
            self.persistImageToStorage()
        }
        
    }
    
    private func persistImageToStorage() {
        //let filename = UUID().uuidString
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid
        else { return }
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else { return }
        ref.putData(imageData, metadata: nil) { metadata, err in
            if let err = err {
                self.loginStatusMessage = "Failed to push image to Storage: \(err)"
                self.wasCreationSuccessful = false
                return
            }
            
            ref.downloadURL { url, err in
                if let err = err {
                    self.loginStatusMessage = "Failed to retrieve download URL: \(err)"
                    self.wasCreationSuccessful = false
                    return
                }
                
                self.loginStatusMessage = "Successfully srored image with url: \(url?.absoluteString ?? "")"
                self.wasCreationSuccessful = true
                
                guard let url = url else { return }
                storeUserInformation(imageProfileURL: url)
            }
        }
    }
    
    private func storeUserInformation(imageProfileURL: URL) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        let userData = [ "email": self.email, "uid": uid, "profileImageURL" : imageProfileURL.absoluteString]
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).setData(userData) { err in
                if let err = err {
                    print(err)
                    self.loginStatusMessage = "\(err)"
                    self.wasCreationSuccessful = false
                    return
                }
                print("Success")
            }
       loginUser()
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginView(didCompleteLoginProcess: {
                
                
            })
        }
    }
}
