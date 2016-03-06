//
//  HumanControll.swift
//  Toutyoku
//
//  Created by yuya on 2016/03/01.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Foundation


class HumanController{
    
    let humans:[Human]
    
    
    /// 担当者の情報(名前と担当不可曜日)を作成
    init(){
        humans = [
            Human(name: .A, unableWeekDays: [.Sunday, .Monday], isSuper:true, practiceRule: (mustWeekDays: [], max: 0)),
            Human(name: .B, unableWeekDays: [.Tuesday, .Thursday], isSuper:true, practiceRule: (mustWeekDays: [], max: 0)),
            Human(name: .C, unableWeekDays: [.Tuesday, .Wednesday], isSuper:true, practiceRule: (mustWeekDays: [], max: 0)),
            Human(name: .D, unableWeekDays: [], isSuper:true, practiceRule: (mustWeekDays: [], max: 0)),
            Human(name: .E, unableWeekDays: [], isSuper:true, practiceRule: (mustWeekDays: [], max: 0)),
            Human(name: .F, unableWeekDays: [], isSuper:true, practiceRule: (mustWeekDays: [], max: 0)),
            Human(name: .G, unableWeekDays: [], isSuper:false, practiceRule: (mustWeekDays: [.Tuesday, .Thursday], max: 2)),
            Human(name: .H, unableWeekDays: [], isSuper:false, practiceRule: (mustWeekDays: [.Tuesday, .Thursday], max: 2)),
            Human(name: .I, unableWeekDays: [], isSuper:false, practiceRule: (mustWeekDays: [.Tuesday, .Thursday], max: 2)),
            Human(name: .J, unableWeekDays: [], isSuper:false, practiceRule: (mustWeekDays: [], max: 0)),
            Human(name: .K, unableWeekDays: [], isSuper: false, practiceRule: (mustWeekDays: [], max: 0))]
    }
    
    
    func startCreatingRandomTable(){
        
        // 今月の最終日の取得
        let lastDayInThisMonth:NSDateComponents = getLastDayInThisMonth()
        
        
        // 今月の最終日の取得
        let theNumberOfADay:Int = lastDayInThisMonth.day
        // 今月の最終日の曜日
        let weekDayOfADay = WeekDay(rawValue: lastDayInThisMonth.weekday-1)!
        
        var valid:Bool
        var table:MonthTable
        repeat{
            table = MonthTable(dayOfLastDay: theNumberOfADay, weekDayOfLastDay:weekDayOfADay, humans:humans)
            
            valid = Rule.MonthRule.RuleA.satisfyRule(objects: [table, humans])
            if valid{
                valid = Rule.MonthRule.RuleB.satisfyRule(objects: [table, humans])
            }
        }while !valid
        
        
        
        
        
        
        table.viewTable()
    }
    
    
    /// You can get [.Year, .Month, .Day, .Weekday] from returned value
    private func getLastDayInThisMonth() -> NSDateComponents{
        let now = NSDate() // 現在日時の取得
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US") // ロケールの設定
        
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        let dataComps = calendar.components([.Year, .Month, .Day], fromDate: now)
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        print(now)
        let nextMonthFirstDay = (dateFormatter.dateFromString("\(dataComps.year)/\(dataComps.month+1)/01 09:00:00"))!
        print(nextMonthFirstDay)
        let finalDayInThisMonth = NSDate(timeInterval: -1*24*60*60, sinceDate:nextMonthFirstDay)
        let lastDayInThisMonth = calendar.components([.Year, .Month, .Day, .Weekday], fromDate: finalDayInThisMonth)
        
        
        return lastDayInThisMonth
    }
    
    
    
}