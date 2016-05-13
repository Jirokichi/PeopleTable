
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
    
    static func selectTwoHumansInADay(humans:[Human], rules:CRules, checkingDay:Int, weekday:WeekDay, previousDaysInfo:[DayInfo]) throws -> [Human]{
        
        
        var requiredHumans:[Human] = []
        for human in humans{
            if human.requiredDays.contains(checkingDay){
                requiredHumans.append(human)
            }
        }
        
        let superHumans:[Human]
        let lowHumans:[Human]
        
        if requiredHumans.count <= 0{
            superHumans = try Human.getSpecificHumans(humans, rules:rules, isSuper:true, checkingDay:checkingDay, weekday:weekday, previousDaysInfo:previousDaysInfo)
            lowHumans = try Human.getSpecificHumans(humans, rules:rules, isSuper:false, checkingDay:checkingDay, weekday:weekday, previousDaysInfo:previousDaysInfo)
        }else if requiredHumans.count == 2{
            if requiredHumans[0].isSuper{
                superHumans = [requiredHumans[0]]
                lowHumans = [requiredHumans[1]]
            }else{
                superHumans = [requiredHumans[1]]
                lowHumans = [requiredHumans[0]]
            }
        }else if requiredHumans.count == 1{
            if requiredHumans[0].isSuper{
                superHumans = [requiredHumans[0]]
                lowHumans = try Human.getSpecificHumans(humans, rules:rules, isSuper:false, checkingDay:checkingDay, weekday:weekday, previousDaysInfo:previousDaysInfo)
            }else{
                lowHumans = [requiredHumans[0]]
                superHumans = try Human.getSpecificHumans(humans, rules:rules, isSuper:true, checkingDay:checkingDay, weekday:weekday, previousDaysInfo:previousDaysInfo)
            }
        }else{
            superHumans = []
            lowHumans = []
            LogUtil.log("fatalError")
            throw CRule.RuleError.Stop(msg: "必須日(\(checkingDay)日)に矛盾")
        }
        
        
        
        var toutyokus:[Human] = []
        var human:Human
        
        
        var okWholeFlag:Bool
        repeat{
            okWholeFlag = true
            toutyokus.removeAll()
            // HumanAの決定
            human = Human.getRandomValue(superHumans)
            toutyokus.append(human)
            
            do{
                if superHumans.count >= 2{
                    let willSelectSuper = ( Int(arc4random_uniform(100)) > Int(rules.percentage * 100 ))
                    if willSelectSuper{
                        human = Human.getRandomValue(superHumans)
                        try rules.individualRule[.Rule0]?.satisfyRule(objects: [human, toutyokus])
                    }else{
                        human = Human.getRandomValue(lowHumans)
                    }
                }else{
                    human = Human.getRandomValue(lowHumans)
                }
                toutyokus.append(human)
            }catch let error as CRule.RuleError{
                switch error{
                case .NotSatisfiedForIndividual:
                    okWholeFlag = false
                default:
                    throw error
                }
                okWholeFlag = false
            }
            
        }while(!okWholeFlag)
        
        return toutyokus
    }
    
    private static func getSpecificHumans(humans:[Human], rules:CRules, isSuper:Bool, checkingDay:Int, weekday:WeekDay, previousDaysInfo:[DayInfo]) throws -> [Human]{
        let specificHumans = humans.filter({ (human) -> Bool in
            
            // @Todo: Fix
            if human.requiredDays.contains(checkingDay){
                
            }
            
            
            
            if let rule = rules.individualRule[.RuleSuperUser]{
                if rule.active{
                    if (human.isSuper != isSuper){
                        return false
                    }
                }
            }
            
            if let rule = rules.individualRule[.RuleUnavailableWeekDays]{
                if rule.active{
                    if (human.unableWeekDays.contains(weekday)){
                        return false
                    }
                }
            }
            
            if let rule = rules.individualRule[.RuleInterval]{
                if rule.active{
                    for day in previousDaysInfo{
                        for workedHuman in day.workingHuman{
                            if human.id == workedHuman.id{
                                return false
                            }
                        }
                    }
                }
            }
            
            if let rule = rules.individualRule[.RuleUnavailableDays]{
                if rule.active{
                    if (human.forbittenDays.contains(checkingDay)){
                        return false
                    }
                }
            }
            
            if let rule = rules.monthRule[.RuleCountsInMonth]{
                if rule.active{
                    if (human.workingCountInAMonth == human.maxWorkingCountInAMonth){
                        return false
                    }
                }
            }
            
            if let rule = rules.monthRule[.RulePractice]{
                if rule.active{
                    if human.practiceRule.max > 0{
                        if human.practiceRule.mustWeekDays.contains(weekday){
                            if human.practiceRule.max == (human.workingCountOnEachWeek[weekday] ?? 0){
                                return false
                            }
                        }
                    }
                }
            }
            
            if let rule = rules.monthRule[.RuleWeekEnd]{
                if rule.active{
                    if (weekday == WeekDay.Saturday || weekday == WeekDay.Sunday){
                        if (human.workingCountOnEachWeek[weekday] ?? 0) == 1{
                            return false
                        }
                    }
                }
            }
            
            return true
        })
        if specificHumans.count < 1{
            throw CRule.RuleError.NotSarisfiedForMonthTable
        }
        return specificHumans
    }
    
    private static func getRandomValue<T>(array:[T]) -> T{
        return array[Int(arc4random_uniform(UInt32(array.count)))]
    }
}



