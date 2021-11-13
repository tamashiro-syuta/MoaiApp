//
//  PastMoaiRecord.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/11/16.
//

import Foundation
import Firebase

class Savings {
    
    let ID: String
    let paidAmounts: [ Dictionary<String,Any> ]
    
    init(dic: [String: Any]) {
        self.ID = dic["ID"] as? String ?? "積み立てなし"
        self.paidAmounts = dic["paidAmounts"] as? [ Dictionary<String,Any> ] ?? [ ["積み立てなし":0] ]
    }
    
}
