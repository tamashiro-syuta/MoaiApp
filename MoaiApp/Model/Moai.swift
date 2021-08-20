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
    
    func switchMoaiDate(weekNum: String, weekDay: String) -> [Int]  {
        var returnWeekAndDayArray:[Int] = []
        switch weekNum {
        case "第１":
            returnWeekAndDayArray.append(1)
        case "第２":
            returnWeekAndDayArray.append(2)
        case "第３":
            returnWeekAndDayArray.append(3)
        case "第４":
            returnWeekAndDayArray.append(4)
        default:
            returnWeekAndDayArray.append(0)
        }
        
        switch weekDay {
        case "日曜日":
            returnWeekAndDayArray.append(1)
        case "月曜日":
            returnWeekAndDayArray.append(2)
        case "火曜日":
            returnWeekAndDayArray.append(3)
        case "水曜日":
            returnWeekAndDayArray.append(4)
        case "木曜日":
            returnWeekAndDayArray.append(5)
        case "金曜日":
            returnWeekAndDayArray.append(6)
        case "土曜日":
            returnWeekAndDayArray.append(7)
        default:
            returnWeekAndDayArray.append(0)
        }

        if returnWeekAndDayArray[0] == 0 || returnWeekAndDayArray[1] == 0 {
            print("変な値になってるよーーーーー")
        }
        
        return returnWeekAndDayArray
    }
    
}
