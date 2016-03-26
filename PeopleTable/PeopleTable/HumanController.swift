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
    init(humans:[Human]){
        self.humans = humans
        
        var ids:[Int] = []
        for human in humans{
            ids.append(human.id)
        }
        let orderedSet = NSOrderedSet(array: ids)
        if let uniqueValues = orderedSet.array as? [Int]{
            if uniqueValues.count == ids.count{
                return
            }
        }
        fatalError()
        
    }
    
    
    func startCreatingRandomTable(calendar:NSDate, rules:Rules){
        
        print("Start: \(NSDate())")
        rules.view()
        
        // 今月の最終日の取得
        let lastDayInThisMonth:NSDateComponents = getLastDay(calendar)
        
        
        // 今月の最終日の取得
        let theNumberOfADay:Int = lastDayInThisMonth.day
        // 今月の最終日の曜日
        let weekDayOfADay = WeekDay(rawValue: lastDayInThisMonth.weekday-1)!
        
        var inValid:Bool
        let table:MonthTable = MonthTable(dayOfLastDay: theNumberOfADay, weekDayOfLastDay:weekDayOfADay, humans:humans, rules:rules)
        
        repeat{
            inValid = false
            do{
                try table.createTable()
                // 月テーブルの評価
                try rules.monthRule[.RuleA]?.satisfyRule(objects: [table, humans])
                try rules.monthRule[.RuleB]?.satisfyRule(objects: [table, humans])
                try rules.monthRule[.RuleC]?.satisfyRule(objects: [table.days, humans])
                
                
            }catch let error as Rule.RuleError where error == Rule.RuleError.NotSarisfiedForMonthTable{
                inValid = true
            }catch{
                fatalError()
            }
        }while inValid
        
        // 結果の確認
        table.viewTable()
        
        print("Finish: \(NSDate())")
        
    }
    
    private func getLastDay(date:NSDate) -> NSDateComponents{
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US") // ロケールの設定
        
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
        let dataComps = calendar.components([.Year, .Month, .Day], fromDate: date)
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        print("指定した月:\(date)")
        let nextMonthFirstDay = (dateFormatter.dateFromString("\(dataComps.year)/\(dataComps.month+1)/01 09:00:00"))!
        let finalDayInThisMonth = NSDate(timeInterval: -1*24*60*60, sinceDate:nextMonthFirstDay)
        print("指定した月の最終日:\(finalDayInThisMonth)")
        let lastDayInThisMonth = calendar.components([.Year, .Month, .Day, .Weekday], fromDate: finalDayInThisMonth)
        
        return lastDayInThisMonth
    }
    
    
}