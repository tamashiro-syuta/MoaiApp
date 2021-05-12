//
//  User.swift
//  ChatAppWithFirebase
//
//  Created by 玉城秀大 on 2021/05/12.
//

import Foundation
import Firebase

class User {
    
    let email: String
    let username: String
    let createdAt: Timestamp
    let ProfileImageUrl: String
    
    init(dic: [String: Any]) {
        self.email = dic["email"] as? String ?? ""
        self.username = dic["username"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.ProfileImageUrl = dic["ProfileImageUrl"] as? String ?? ""
    }
    
}
