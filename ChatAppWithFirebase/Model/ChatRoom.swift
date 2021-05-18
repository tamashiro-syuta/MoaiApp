//
//  ChatRoom.swift
//  ChatAppWithFirebase
//
//  Created by 玉城秀大 on 2021/05/15.
//

import Foundation
import Firebase

class ChatRoom {
    
    let latestMessageId: String?
    let menbers: [String?]
    let createdAt: Timestamp
    
    var partnerUser: User?
    
    init(dic: [String: Any]) {
        self.latestMessageId = dic["latestMessageId"] as? String ?? ""
        self.menbers = dic["menbers"] as? [String] ?? [String]()
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
    }
    
}
