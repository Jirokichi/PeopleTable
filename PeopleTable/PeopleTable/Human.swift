
//
//  Human.swift
//  Toutyoku
//
//  Created by yuya on 2016/02/29.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Foundation


class Human{
    
    let id:Int /// 一意に決まる番号(最初から順番に)
    let name:String
    let unableWeekDays:[WeekDay]
    let isSuper:Bool
    let practiceRule:(mustWeekDays:[WeekDay], max:Int)
    let maxWorkingCountInAMonth:Int
    let minWorkingCountInAMonth:Int
    let forbittenDays:[Int]
    let requiredDays:[Int]
    
    // 月の担当回数をメモする。最大を越えるとエラーを投げる。
    var workingCountInAMonth:Int
    var workingCountOnEachWeek:[WeekDay:Int] = [:]
    
    
    
    
    init(id:Int, name:String, unableWeekDays:[WeekDay], isSuper:Bool, practiceRule:(mustWeekDays:[WeekDay], max:Int), maxWorkingCountInAMonth:Int, minWorkingCountInAMonth:Int, forbittenDays:[Int], requiredDays:[Int]){
        self.id = id
        self.name = name
        self.unableWeekDays = unableWeekDays
        self.isSuper = isSuper
        self.practiceRule = practiceRule
        self.maxWorkingCountInAMonth = maxWorkingCountInAMonth
        self.minWorkingCountInAMonth = minWorkingCountInAMonth
        self.forbittenDays = forbittenDays
        self.requiredDays = requiredDays
        
        self.workingCountInAMonth = 0
        
        
    }
    
    
    
    
}



