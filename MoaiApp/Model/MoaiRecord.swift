//
//  PastMoaiRecord.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/07/04.
//

import Foundation
import Firebase

class MoaiRecord {
    
    let amount: Int
    let date:Timestamp
    let getMoneyPerson: [String:String]
//    let getMoneyPersonID: String
    let location: [String:Any]
//    let locationName: String //nilを許容する
//    let location: GeoPoint? //nilを許容する
    let paid: [String]
    let unpaid: [String]
    let note: String
    let createdAt: Timestamp
    
    init(dic: [String: Any]) {
        self.amount = dic["amount"] as? Int ?? 0
        self.date = dic["date"] as? Timestamp ?? Timestamp()
        self.getMoneyPerson = dic["getMoneyPerson"] as? [String:String] ?? ["name":"未定" , "id":"未定"]
//        self.getMoneyPersonID = dic["getMoneyPersonID"] as? String ?? ""
//        self.locationName = dic["locationName"] as? String ?? "未定"
//        self.location = dic["location"] as? GeoPoint
        self.location = dic["location"] as? [String:Any] ?? ["name":"", "geoPoint":GeoPoint(latitude: 0, longitude: 0)]
        self.paid = dic["paid"] as? [String] ?? []   //初期値は空の配列
        self.unpaid = dic["unpaid"] as? [String] ?? []   //初期値は空の配列
        self.note = dic["note"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
    }
    
}
