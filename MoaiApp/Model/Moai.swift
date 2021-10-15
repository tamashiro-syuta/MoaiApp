//
//  Moai.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/06/25.
//

import Foundation
import Firebase

//余裕があれば、membersを構造体にして、「.」で参照できるようにしたい
//struct Members:Codable {
//    let id:String
//    let name:String
//    let next:Bool
//    let saving:Bool
//
//    init(dic: [String: Any]) {
//        self.id = dic["id"] as? String ?? ""
//        self.name = dic["name"] as? String ?? ""
//        self.next = dic["next"] as? Bool ?? false
//        self.saving = dic["saving"] as? Bool ?? false
//    }
//}

class Moai {
    
    let groupName:String
    //プロパティは、id、name、next、savingの4つ（nextとsavingはBool型で、返ってくる時は1(true),2(false)で返ってくる）
    let members:[ [String:Any] ]
    let week: String
    let day: String
    let amount: Int
    let defaultStartTime:[String:Int]
    let createdAt: Timestamp
    let password: String
    
    
    init(dic: [String: Any]) {
        self.groupName = dic["groupName"] as? String ?? ""
        self.members = dic["members"] as? [ [String:Any] ] ?? []
        self.week = dic["week"] as? String ?? ""
        self.day = dic["day"] as? String ?? ""
        self.amount = dic["amount"] as? Int ?? 0
        self.defaultStartTime = dic["startTime"] as? [String:Int] ?? ["hour":20, "minute":00]
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.password = dic["password"] as? String ?? ""
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
