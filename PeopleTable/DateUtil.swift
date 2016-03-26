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
    static func getFirstDay(date:NSDate) -> NSDateComponents{
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US") // ロケールの設定
        
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        let dataComps = calendar.components([.Year, .Month, .Day], fromDate: date)
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        let thisMonthFirstDay = (dateFormatter.dateFromString("\(dataComps.year)/\(dataComps.month)/01 09:00:00"))!
        let dayComponent = calendar.components([.Year, .Month, .Day, .Weekday], fromDate: thisMonthFirstDay)
        
        return dayComponent
    }
    
    /// 引数の月の最終日のNSDateComponent(Year, Month, Day, Weekday)の取得
    static func getLastDay(date:NSDate) -> NSDateComponents{
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US") // ロケールの設定
        
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        let dataComps = calendar.components([.Year, .Month, .Day], fromDate: date)
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        var nextMonth = dataComps.month+1
        if nextMonth > 12{
            nextMonth = 1
        }
        
        let nextMonthFirstDay = (dateFormatter.dateFromString("\(dataComps.year)/\((nextMonth))/01 09:00:00"))!
        let finalDayInThisMonth = NSDate(timeInterval: -1*24*60*60, sinceDate:nextMonthFirstDay)
        let dayComponent = calendar.components([.Year, .Month, .Day, .Weekday], fromDate: finalDayInThisMonth)
        
        return dayComponent
    }
}

enum WeekDay:Int{
    case Sunday = 0
    case Monday = 1
    case Tuesday = 2
    case Wednesday = 3
    case Thursday = 4
    case Friday = 5
    case Saturday = 6
}