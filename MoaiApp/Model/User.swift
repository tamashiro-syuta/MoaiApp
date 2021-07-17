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
    let profileImageUrl: String
    let moais: [String]
    let password: String
    
    //chatを開始する時に使うため
    var uid: String?
    
    init(dic: [String: Any]) {
        self.email = dic["email"] as? String ?? ""
        self.username = dic["username"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.profileImageUrl = dic["profileImageUrl"] as? String ?? ""
        self.moais = dic["moais"] as? [String] ?? [""]
        self.password = dic["password"] as? String ?? ""
    }
    
}
