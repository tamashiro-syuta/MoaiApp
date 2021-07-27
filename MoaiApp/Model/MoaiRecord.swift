//
//  PastMoaiRecord.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/07/04.
//

import Foundation
import Firebase

class MoaiRecord {
    
    let date:Timestamp
    let startTime:String
    let getMoneyPerson: String
    let getMoneyPersonID: String
    let location: String
    let createdAt: Timestamp
    
    init(dic: [String: Any]) {
        self.date = dic["date"] as? Timestamp ?? Timestamp()
        self.startTime = dic["startTime"] as? String ?? ""
        self.getMoneyPerson = dic["getMoneyPerson"] as? String ?? ""
        self.getMoneyPersonID = dic["getMoneyPersonID"] as? String ?? ""
        self.location = dic["location"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
    }
    
}
