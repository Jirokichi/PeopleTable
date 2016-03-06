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
    
    /// 月の最終日の情報をもとに月の担当者を含めたカレンダーを作成する
    /// ここでは、最低条件のみ反映して担当者を決定する
    init(dayOfLastDay:Int, weekDayOfLastDay:WeekDay, humans:[Human]){
        self.days = []
        self.weekDayOfLastDate = weekDayOfLastDay
        self.dayOfLastDay = dayOfLastDay
        
        for (var i = 0; i < dayOfLastDay; i++){
            let day = DayInfo(day: i+1, weekday: getWeekDay(i+1))
            let toutyokus:(Human, Human)
            if i == 0{
                toutyokus = Human.selectTwoHumansInADay(humans, weekday: day.weekday, yesterdayInfo: nil)
            }else{
                toutyokus = Human.selectTwoHumansInADay(humans, weekday: day.weekday, yesterdayInfo: days[i-1])
            }
            day.setHumans(toutyokus.0, humanB: toutyokus.1)
            days.append(day)
        }
    }
    
    func viewTable(){
        for day in days{
            day.viewDay()
        }
    }
    
    // 最終日の日付と曜日をもとにday日の曜日を算出するメソッド
    func getWeekDay(day:Int) -> WeekDay{
        return WeekDay(rawValue: (7+weekDayOfLastDate.rawValue - (dayOfLastDay - day)%7)%7)!
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

class DayInfo{
    let day:Int
    let weekday:WeekDay
    var workingHuman:[Human]
    
    init(day:Int, weekday:WeekDay){
        self.day = day
        self.weekday = weekday
        self.workingHuman = []
    }
    
    
    
    func setHumans(humanA:Human, humanB:Human){
        self.workingHuman.append(humanA)
        self.workingHuman.append(humanB)
    }
    
    func viewDay(){
        print("\(day)日\(weekday): \(workingHuman[0].name) / \(workingHuman[1].name)")
    }
}