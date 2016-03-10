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
    
    // 月の担当回数をメモする。最大を越えるとエラーを投げる。
    var workingCountInAMonth:Int
    
    init(id:Int, name:String, unableWeekDays:[WeekDay], isSuper:Bool, practiceRule:(mustWeekDays:[WeekDay], max:Int), maxWorkingCountInAMonth:Int, minWorkingCountInAMonth:Int){
        self.id = id
        self.name = name
        self.unableWeekDays = unableWeekDays
        self.isSuper = isSuper
        self.practiceRule = practiceRule
        self.maxWorkingCountInAMonth = maxWorkingCountInAMonth
        self.minWorkingCountInAMonth = minWorkingCountInAMonth
        
        self.workingCountInAMonth = 0
    }
    
    /// RuleBとRuleCを満たしているかどうかのチェック
    private func satisfyCommonRule(humans:[Human], rules:Rules, weekday:WeekDay, previousDaysInfo:[DayInfo]) throws -> (){
        
        // 人ごとに決められている曜日であること
        try rules.individualRule[.RuleB]?.satisfyRule(objects: [self, weekday])
        // ３日前間担当者ではないこと
        try rules.individualRule[.RuleC]?.satisfyRule(objects: [self, previousDaysInfo])
    }
    
    static func selectTwoHumansInADay(humans:[Human], rules:Rules, weekday:WeekDay, previousDaysInfo:[DayInfo]) throws -> [Human]{
        
        
        let superHumans = humans.filter({ (human) -> Bool in
            var result = human.isSuper
//            if rules.monthRule[2].valid{
//                result = result && human.workingCountInAMonth < human.maxWorkingCountInAMonth
//            }
            return result
        })
        let lowHumans = humans.filter({ (human) -> Bool in
            var result = !human.isSuper
//            if rules.monthRule[2].valid{
//                result = result && human.workingCountInAMonth < human.maxWorkingCountInAMonth
//            }
            return result
        })
        
        
//        if superHumans.count < 2{
//            print("?")
//            throw Rule.RuleError.NotSarisfiedForMonthTable
//        }
        
        // 人数
        let countForHumanA:UInt32 = UInt32(superHumans.count)
        
        var toutyokus:[Human] = []
        var human:Human
        
        
        var okWholeFlag:Bool
        repeat{
            okWholeFlag = true
            
            // HumanAの決定
            var okIndividualFlag:Bool
            repeat{
                okIndividualFlag = true
                human = superHumans[Int(arc4random_uniform(countForHumanA))]
                do{
                    
                    try rules.individualRule[.RuleA]?.satisfyRule(objects: [toutyokus, human])
                    try human.satisfyCommonRule(humans, rules:rules, weekday: weekday, previousDaysInfo: previousDaysInfo)
                }catch let error as Rule.RuleError where error == Rule.RuleError.NotSatisfiedForIndividual{
                    okIndividualFlag = false
                }
            }while(!okIndividualFlag)
            
            toutyokus.append(human)
            
            // HumanBの決定
            repeat{
                okIndividualFlag = true
                let willSelectSuper = ( Int(arc4random_uniform(100)) > Int(rules.percentage * 100 ))
                let humansForHumanB = willSelectSuper ? superHumans : lowHumans
                let countForHumanB:UInt32 = UInt32(humansForHumanB.count)
                human = humansForHumanB[Int(arc4random_uniform(countForHumanB))]
                
                do{
                    try rules.individualRule[.Rule0]?.satisfyRule(objects: [human, toutyokus])
                    try human.satisfyCommonRule(humans, rules:rules, weekday: weekday, previousDaysInfo: previousDaysInfo)
                }catch let error as Rule.RuleError where error == Rule.RuleError.NotSatisfiedForIndividual{
                    okIndividualFlag = false
                }
            }while(!okIndividualFlag)
            
            toutyokus.append(human)
            
        }while(!okWholeFlag)
        
        return toutyokus
    }
}



