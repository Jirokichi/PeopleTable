//
//  DateUtil.swift
//  PeopleTable
//
//  Created by yuya on 2016/03/23.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Foundation

class DateUtil{
    
    /// 引数の月の初日のNSDateComponent(Year, Month, Day, Weekday)の取得
    static func getFirstDay(_ date:Date) -> DateComponents{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US") // ロケールの設定
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let dataComps = (calendar as NSCalendar).components([.year, .month, .day], from: date)
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        let dateStr = "\(dataComps.year ?? 2017)/\(dataComps.month ?? 12)/01 09:00:00"
        let thisMonthFirstDay = (dateFormatter.date(from: dateStr))!
        let dayComponent = (calendar as NSCalendar).components([.year, .month, .day, .weekday], from: thisMonthFirstDay)
        
        return dayComponent
    }

    
    /// 引数の月の最終日のNSDateComponent(Year, Month, Day, Weekday)の取得
    static func getLastDay(_ date:Date) -> DateComponents{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US") // ロケールの設定
        
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let dataComps = (calendar as NSCalendar).components([.year, .month, .day], from: date)
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        var nextMonth = dataComps.month!+1
        if nextMonth > 12{
            nextMonth = 1
        }
        
        let nextMonthFirstDay = (dateFormatter.date(from: "\(dataComps.year!)/\((nextMonth))/01 09:00:00"))!
        let finalDayInThisMonth = Date(timeInterval: -1*24*60*60, since:nextMonthFirstDay)
        let dayComponent = (calendar as NSCalendar).components([.year, .month, .day, .weekday], from: finalDayInThisMonth)
        
        return dayComponent
    }
}

enum WeekDay:Int{
    case sunday = 0
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6
    
    
    func string() -> String{
        switch self{
        case .sunday:
            return "日"
        case .monday:
            return "月"
        case .tuesday:
            return "火"
        case .wednesday:
            return "水"
        case .thursday:
            return "木"
        case .friday:
            return "金"
        case .saturday:
            return "土"
        }
    }
}
