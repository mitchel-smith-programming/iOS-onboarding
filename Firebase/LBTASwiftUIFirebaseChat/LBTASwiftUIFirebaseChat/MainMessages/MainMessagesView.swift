//
//  MainMessagesView.swift
//  LBTASwiftUIFirebaseChat
//
//  Created by Smith, Mitchel on 5/12/22.
//

import SwiftUI
import SDWebImageSwiftUI

class MainMessagesViewModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var isUserCurrenltyLoggedOut = false
    init() {
        
        DispatchQueue.main.async {
            self.isUserCurrenltyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        
        fetchCurrentUser()
    }
    
    func fetchCurrentUser() {
        
        guard let uid =  FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find uid"
            return
            
        }
        self.errorMessage = "\(uid)"
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, err in
            if let err = err {
                self.errorMessage = "Failed to fetch current user: \(err)"
                print("Failed to fetch current user:", err)
                return
            }
            
            guard let data = snapshot?.data() else {
                self.errorMessage = "No data found"
                return
            }
            
            self.chatUser = .init(data: data)
            
            
            
        }
        
    }
    
 
    
    func handleSignOut() {
        isUserCurrenltyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
    
}


struct MainMessagesView: View {
    
    @State var shouldShowLogOutOptions = false
    @State var shouldNavigateToChatLogView = false
    
    @ObservedObject private var vm = MainMessagesViewModel()
    
    private var customNavBar: some View {
        HStack(spacing: 16) {
            WebImage(url: URL(string: vm.chatUser?.profileImageURL ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: 44, height: 44)
                .clipped()
                .cornerRadius(44)
                .overlay(RoundedRectangle(cornerRadius: 44)
                    .stroke(Color(.label), lineWidth: 1)
                )
                .shadow(radius: 5)
            
            VStack(alignment: .leading, spacing: 4) {
                let username = vm.chatUser?.email.replacingOccurrences(of: "@gmail.com", with: "") ?? ""
                Text(username)
                    .font(.system(size: 24, weight: .bold))
                HStack{
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    Text("online")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.lightGray))
                }
            }
            Spacer()
            Button{
                shouldShowLogOutOptions.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.label))
            }
            
        }.padding()
            .actionSheet(isPresented: $shouldShowLogOutOptions) {
                .init(title: Text("Settings"), message: Text("What do you want to do?"), buttons: [
                    .destructive(Text("Sign Out"), action: {
                        print("Handle Sign Out")
                        vm.handleSignOut()
                        
                        
                    }),
                    //.default(Text("DEFAULT BUTTON")),
                    .cancel()
                                                                                                  ])
            }
            .fullScreenCover(isPresented: $vm.isUserCurrenltyLoggedOut, onDismiss: nil) {
                LoginView(didCompleteLoginProcess: {
                    self.vm.isUserCurrenltyLoggedOut = false
                    self.vm.fetchCurrentUser()
                })
                
            }
    }
    
    private var messagesView: some View {
        ScrollView {
            ForEach(0..<10, id: \.self) { num in
                VStack{
                    NavigationLink {
                        Text("Destination")
                    } label: {
                        HStack{
                            Image(systemName: "person.fill")
                                .font(.system(size: 32))
                                .padding(8)
                                .overlay(RoundedRectangle(cornerRadius: 44)
                                    .stroke(Color.black, lineWidth: 1)
                                )
                            VStack {
                                Text("Username")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Message sent to user")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(.lightGray))
                            }
                            Spacer()
                            
                            Text("22d")
                                .font(.system(size: 14, weight: .semibold))
                                
                        }
                    }
                    Divider()
                        .padding(.vertical, 8)
                }.padding(.horizontal)
                
            }.padding(.bottom, 50)
            
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // custom nav bar
                //Text("User: \(vm.ChatUser?.uid ?? "")")
                
                customNavBar
                messagesView
                NavigationLink("", isActive: $shouldNavigateToChatLogView) {
                    ChatLogView(chatUser: self.chatUser)
                }
            }.overlay(
                newMessageButton, alignment: .bottom)
            .navigationBarHidden(true)
        }
    }
    
    @State var shouldShowNewMessageScreen = false
    
    private var newMessageButton: some View {
        Button {
            shouldShowNewMessageScreen.toggle()
        } label: {
            HStack {
                Spacer()
                Text("+ New Message")
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical)
                .background(Color.blue)
                .cornerRadius(32)
                .padding(.horizontal)
                .shadow(radius: 15)
        }
        .fullScreenCover(isPresented: $shouldShowNewMessageScreen) {
            CreateNewMessageView { user in
                print(user.email)
                self.shouldNavigateToChatLogView.toggle()
                self.chatUser = user
            }
        }
    }
    
    @State var chatUser: ChatUser?
}

struct MainMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessagesView()
            .preferredColorScheme(.dark)
    }
}
