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
    let locationName: String //nilを許容する
    let location: GeoPoint? //nilを許容する
    let createdAt: Timestamp
    
    init(dic: [String: Any]) {
        self.date = dic["date"] as? Timestamp ?? Timestamp()
        self.startTime = dic["startTime"] as? String ?? ""
        self.getMoneyPerson = dic["getMoneyPerson"] as? String ?? ""
        self.getMoneyPersonID = dic["getMoneyPersonID"] as? String ?? ""
        self.locationName = dic["locationName"] as? String ?? "未設定"
        self.location = dic["location"] as? GeoPoint
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
    }
    
}
