//
//  DateUtils.swift
//  MoaiApp
//
//  Created by 玉城秀大 on 2021/07/26.
//


import UIKit

class DateUtils {
    // String -> Date (たぶん、あんまり使わない)
    class func dateFromString(string: String) -> Date {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.date(from: string)!
    }

    // Date -> String("M 月 d 日（EEE）")
    class func MddEEEFromDate(date: Date) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M 月 dd 日（EEE）"
        return formatter.string(from: date)
    }
    
    // Date -> String("yyyy年 MM 月 dd 日（EEE）")
    class func yyyyMMddEEEFromDate(date: Date) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy 年 MM 月 dd 日（EEE）"
        return formatter.string(from: date)
    }
    
    // Date -> String("yyyyMMdd")
    class func stringFromDateoForSettingRecordID(date: Date) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: date)
    }
    
    // Date -> String("yyyy年 MM 月")
    class func yyyyMMFromDate(date: Date) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy / MM "
        return formatter.string(from: date)
    }
    
    // Date -> String (時刻のみ取得)　ex)20:00 
    class func fetchStartTimeFromDate(date: Date) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    //  yyyymmddの表記から◯年○月◯日の表記に変更
    class func yyyymmddToJPFormat(yyyymmdd:String) -> String {
        var from = yyyymmdd.index(yyyymmdd.startIndex, offsetBy:0)
        var to = yyyymmdd.index(yyyymmdd.startIndex, offsetBy:4)
        let year = yyyymmdd[from..<to]
        
        from = yyyymmdd.index(yyyymmdd.startIndex, offsetBy:5)
        to = yyyymmdd.index(yyyymmdd.startIndex, offsetBy:6)
        let month = yyyymmdd[from..<to]
        
        from = yyyymmdd.index(yyyymmdd.startIndex, offsetBy:7)
        to = yyyymmdd.index(yyyymmdd.startIndex, offsetBy:8)
        let date = yyyymmdd[from..<to]
        
        let dateString = year + "年" +  month + "月" + date + "日"
        return dateString
    }
    
    // 次回の模合の日付をDate型で返す(要修正)
    class func returnNextMoaiDate(weekNum: Int, weekDay:Int) -> Date {
        let cal = Calendar.current
        let now = Date()
        let nextMonth = cal.date(byAdding: .month, value: 1, to: now)

        var components = cal.dateComponents([.year, .month], from: nextMonth!)
        components.weekdayOrdinal = weekNum // 第◯週目
        components.weekday = weekDay  // の◯曜日
        
        let nextMoaiDate = cal.date(from: components)
        
        return nextMoaiDate!
    }
    
}
