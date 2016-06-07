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
    
    
    /// 月の最終日の情報をもとに月の担当者を含めたカレンダーを作成する
    /// ここでは、最低条件のみ反映して担当者を決定する
    init(dayOfLastDay:Int, weekDayOfLastDay:WeekDay, humans:[Human]){
        self.days = []
        self.weekDayOfLastDate = weekDayOfLastDay
        self.dayOfLastDay = dayOfLastDay
        self.humans = humans
    
        for (var i = 0; i < self.dayOfLastDay; i++){
            let dayInfo = DayInfo(day: i+1, weekday: self.getWeekDay(i+1))
            
            var toutyoku:[Human] = []
            for human in self.humans{
                if human.requiredDays.contains(dayInfo.day){
                    toutyoku.append(human)
                }
            }
            dayInfo.setHumans(toutyoku)
            self.days.append(dayInfo)
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
    
    func getHumanOfNoX(numX:Int) -> Human?{
        if workingHuman.count > numX{
            return workingHuman[numX]
        }else{
            return nil
        }
    }
    
    func setHumans(toutyokus:[Human]){
        self.workingHuman = toutyokus
    }
    
    func viewDay(){
        print("\(day)日\(weekday): \(workingHuman[0].name) / \(workingHuman[1].name)")
    }
}