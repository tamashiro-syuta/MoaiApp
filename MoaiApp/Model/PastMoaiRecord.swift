//
//  PastMoaiRecord.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/07/04.
//

import Foundation
import Firebase

class PastMoaiRecord {
    
    let date:String
    let getMoneyPerson: String
    let location: String
    let createdAt: Timestamp
    
    init(dic: [String: Any]) {
        self.date = dic["date"] as? String ?? ""
        self.getMoneyPerson = dic["getMoneyPerson"] as? String ?? ""
        self.location = dic["location"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
    }
    
}
