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
    class func stringFromDate(date: Date) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M 月 d 日（EEE）"
        return formatter.string(from: date)
    }
    
    // Date -> String("M 月 d 日（EEE）")
    class func stringFromDateoForSettingNextID(date: Date) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyyMMdd"
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
}
