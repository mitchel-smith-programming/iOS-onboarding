//
//  ChatUser.swift
//  LBTASwiftUIFirebaseChat
//
//  Created by Smith, Mitchel on 5/13/22.
//

import Foundation

struct ChatUser: Identifiable {
    var id: String { uid }
    
    let uid, email, profileImageURL: String
    
    init(data: [String: Any]) {
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.profileImageURL = data["profileImageURL"] as? String ?? ""
    }
}
