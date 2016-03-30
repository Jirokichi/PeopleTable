//
//  MonthTable.swift
//  Toutyoku
//
//  Created by yuya on 2016/03/01.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Foundation


class MonthTable{
    var days:[DayInfo] // 今月の情報(日付、曜日、2人の担当者)を格納する変数
    let dayOfLastDay:Int // 月の最終日
    let weekDayOfLastDate:WeekDay // 月の最終日の曜日
    let humans:[Human]
    let rules:Rules
    
    /// 月の最終日の情報をもとに月の担当者を含めたカレンダーを作成する
    /// ここでは、最低条件のみ反映して担当者を決定する
    init(dayOfLastDay:Int, weekDayOfLastDay:WeekDay, humans:[Human], rules:Rules){
        self.days = []
        self.weekDayOfLastDate = weekDayOfLastDay
        self.dayOfLastDay = dayOfLastDay
        self.humans = humans
        self.rules = rules
    }
    
    func createTable() throws{
        days.removeAll()
        for human in humans{
            human.workingCountInAMonth = 0
        }
        
        for (var i = 0; i < dayOfLastDay; i++){
            let day = DayInfo(day: i+1, weekday: getWeekDay(i+1))
            let toutyokus:[Human]
            if i == 0{
                toutyokus = try Human.selectTwoHumansInADay(humans, rules:rules, checkingDay:i+1, weekday: day.weekday, previousDaysInfo: [])
            }else if i == 1{
                toutyokus = try Human.selectTwoHumansInADay(humans, rules:rules, checkingDay:i+1, weekday: day.weekday, previousDaysInfo: [days[i-1]])
            }else{
                toutyokus = try Human.selectTwoHumansInADay(humans, rules:rules, checkingDay:i+1, weekday: day.weekday, previousDaysInfo: [days[i-1], days[i-2]])
            }
            day.setHumans(toutyokus)
            days.append(day)
            
            
            
            if rules.monthRule[.RuleC]!.valid{
                for toutyoku in toutyokus{
                    for human in humans{
                        if human.id == toutyoku.id{
                            human.workingCountInAMonth++
                            if human.workingCountInAMonth > human.maxWorkingCountInAMonth{
                                throw Rule.RuleError.NotSarisfiedForMonthTable
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    func viewTable(){
        
        var counts:Dictionary<Int, Int> = [:]
        for human in humans{
            counts[human.id] = 0
        }
        
        for day in days{
            day.viewDay()
            counts[day.workingHuman[0].id]!++
            counts[day.workingHuman[1].id]!++
        }
        
        for human in humans{
            print("\(human.name):\(counts[human.id])")
        }
        
        
    }
    
    // 最終日の日付と曜日をもとにday日の曜日を算出するメソッド
    func getWeekDay(day:Int) -> WeekDay{
        return WeekDay(rawValue: (7+weekDayOfLastDate.rawValue - (dayOfLastDay - day)%7)%7)!
    }
    
    /// 一ヶ月の曜日ごとのhumanの回数
    func numberOfSpecificWeekDayInAMonth(humanName:String) -> [WeekDay:Int]{
        var result:[WeekDay:Int] = [:]
        
        for day in self.days{
            if day.workingHuman.contains({ (h) -> Bool in
                return humanName == h.name
            }){
                result[day.weekday] = (result[day.weekday] ?? 0) + 1
            }
        }
        return result
    }
}

class DayInfo{
    let day:Int
    let weekday:WeekDay
    var workingHuman:[Human]
    
    init(day:Int, weekday:WeekDay){
        self.day = day
        self.weekday = weekday
        self.workingHuman = []
    }
    
    
    
    func setHumans(toutyokus:[Human]){
        self.workingHuman = toutyokus
    }
    
    func viewDay(){
        print("\(day)日\(weekday): \(workingHuman[0].name) / \(workingHuman[1].name)")
    }
}