//
//  ChatLogView.swift
//  LBTASwiftUIFirebaseChat
//
//  Created by Smith, Mitchel on 5/24/22.
//

import SwiftUI
import Firebase

class ChatLogViewModel: ObservableObject {
    
    @Published var chatText = ""
    @Published var errorMessage = ""
    
    private var defaultText = "New Message"
    let chatUser: ChatUser?
    
    init(_ chatUser: ChatUser?) {
        chatText = defaultText
        self.chatUser = chatUser
    }
    
    func handleSend() {
        print(chatText)
        
        guard let fromID = FirebaseManager.shared.auth
            .currentUser?.uid else { return }
        
        guard let toID = chatUser?.uid else { return }
        
        let document = FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromID)
            .collection(toID)
            .document()
        
        let messageData = ["fromID": fromID, "toID": toID, "text": self.chatText, "timestamp": Timestamp()] as [String: Any]
        
        document.setData(messageData) { error in
            if let error = error {
                self.errorMessage = "Failed to save message into Firestore: \(error)"
            }
             
        }
        
        let recipientDocument = FirebaseManager.shared.firestore
            .collection("messages")
            .document(toID)
            .collection(fromID)
            .document()
        
        
        recipientDocument.setData(messageData) { error in
            if let error = error {
                self.errorMessage = "Failed to save message into Firestore: \(error)"
            }
        }
        chatText = defaultText
    }
    
    func isDefault() -> Bool{
        return chatText == defaultText ? true : false
    }
    func setToDefault() {
        chatText = defaultText
    }
}

struct ChatLogView: View {
    @FocusState private var isMessageFieldFocused: Bool
    
    let chatuser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatuser = chatUser
        self.vm = ChatLogViewModel(chatUser)
    }
    
    @ObservedObject var vm : ChatLogViewModel
    
    var body: some View {
        VStack {
            chatMessagesView
            chatBottomBar
        }
        .navigationTitle(chatuser?.email ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemBackground))
        .onTapGesture {
            isMessageFieldFocused = false
        }
    }
    
    private var chatMessagesView: some View {
        ScrollView {
            ForEach(0..<20) { num in
                HStack{
                    Spacer()
                    HStack{
                        Text("FAKE MESSAGE HOLDER \(num + 1)")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                    
                }.padding(.horizontal)
                    .padding(.top, 12)
            }
            
            HStack { Spacer() }
        }
        .background(Color(.init(white: 0.95, alpha: 1)))
        .padding(.vertical)
    }
    
    private var chatBottomBar: some View {
        
        HStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 24))
                .foregroundColor(Color(.darkGray))
            ScrollView {
                TextEditor(text: $vm.chatText)
                    .foregroundColor(vm.isDefault() ? .gray : .primary)
                    .onTapGesture {
                        if vm.isDefault() {
                            vm.chatText = ""
                        }
                    }
                    .background(Color.blue)
                    .padding()
                    .frame(minWidth: 200, maxWidth: 200, minHeight: 50, maxHeight: 75)
                    .disableAutocorrection(true)
                    .border(Color(.init(white: 0.75, alpha: 1)), width: 1)
                    .focused($isMessageFieldFocused)
                    .onChange(of: isMessageFieldFocused) { newValue in
                        if !isMessageFieldFocused && vm.chatText == "" {
                            vm.setToDefault()
                        }
                    }
            }
            .fixedSize(horizontal: false, vertical: true)
            Button {
                if !vm.isDefault() && vm.chatText != "" {
                    vm.handleSend()
                }
                isMessageFieldFocused = false
            } label: {
                Text("Send")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.blue)
            .cornerRadius(4)
            
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        
    }
}

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            ChatLogView(chatUser: .init(data: ["uid": "1YM8PhuNa2WSaVwDuz46mGs5xL43", "email" : "chaseisbased@gmail.com"]))
        }
    }
}
