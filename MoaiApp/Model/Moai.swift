//
//  Moai.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/06/25.
//

import Foundation
import Firebase

class Moai {
    
    let groupName:String
    let menbers:[String]
    let week: String
    let day: String
    let amount: String
    let createdAt: Timestamp
    let password: String
    let next: [Bool]
    
    init(dic: [String: Any]) {
        self.groupName = dic["groupName"] as? String ?? ""
        self.menbers = dic["menbers"] as? [String] ?? [""]
        self.week = dic["week"] as? String ?? ""
        self.day = dic["day"] as? String ?? ""
        self.amount = dic["amount"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.password = dic["password"] as? String ?? ""
        self.next = dic["next"] as? [Bool] ?? [false]
    }
    
}
