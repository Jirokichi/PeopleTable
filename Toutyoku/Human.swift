//
//  Human.swift
//  Toutyoku
//
//  Created by yuya on 2016/02/29.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Foundation


enum Name{
    case A
    case B
    case C
    case D
    case E
    case F
    case G
    case H
    case I
    case J
    case K
}

class Human{
    
    let name:Name
    let unableWeekDays:[WeekDay]
    let isSuper:Bool
    let practiceRule:(mustWeekDays:[WeekDay], max:Int)
    init(name:Name, unableWeekDays:[WeekDay], isSuper:Bool, practiceRule:(mustWeekDays:[WeekDay], max:Int)){
        self.name = name
        self.unableWeekDays = unableWeekDays
        self.isSuper = isSuper
        self.practiceRule = practiceRule
    }
    
    /// RuleBとRuleCを満たしているかどうかのチェック
    private func satisfyCommonRule(humans:[Human], weekday:WeekDay, previousDaysInfo:[DayInfo]) -> Bool{
        var okIndividualFlag:Bool
        // 人ごとに決められている曜日であること
        okIndividualFlag = Rule.Individual.RuleB.satisfyRule(objects: [self, weekday])
        if okIndividualFlag{
            // ３日前間担当者ではないこと
            okIndividualFlag = Rule.Individual.RuleC.satisfyRule(objects: [self, previousDaysInfo])
            
        }
        return okIndividualFlag
    }
    
    static func selectTwoHumansInADay(humans:[Human], weekday:WeekDay, previousDaysInfo:[DayInfo]) -> (Human, Human){
        
        
        let superHumans = humans.filter({ (human) -> Bool in
            return human.isSuper
        })
        let lowHumans = humans.filter({ (human) -> Bool in
            return !human.isSuper
        })
        
        // 人数
        let countForHumanA:UInt32 = UInt32(superHumans.count)
        
        var humanA:Human
        var humanB:Human
        
        
        // HumanBの決定
        
        
        
        
        var okWholeFlag:Bool
        repeat{
            okWholeFlag = true
            
            // HumanAの決定
            var okIndividualFlag:Bool
            repeat{
                humanA = superHumans[Int(arc4random_uniform(countForHumanA))]
                // 条件⑴必ず片方はSuperであること
                okIndividualFlag = Rule.Individual.RuleA.satisfyRule(objects: [humanA])
                if okIndividualFlag{
                    okIndividualFlag = humanA.satisfyCommonRule(humans, weekday: weekday, previousDaysInfo: previousDaysInfo)
                }
            }while(!okIndividualFlag)
            
            
            // HumanBの決定
            repeat{
                let willSelectSuper = ( Int(arc4random_uniform(100)) > Int(Rule.Individual.Percentage * 100 ))
                let humansForHumanB = willSelectSuper ? superHumans : lowHumans
                let countForHumanB:UInt32 = UInt32(humansForHumanB.count)
                humanB = humansForHumanB[Int(arc4random_uniform(countForHumanB))]
                // 暗黙のルール(もちろんAとBは同じ人になってはいけない)
                okIndividualFlag = (humanB.name != humanA.name)
                if okIndividualFlag{
                    okIndividualFlag = humanB.satisfyCommonRule(humans, weekday: weekday, previousDaysInfo: previousDaysInfo)
                }
            }while(!okIndividualFlag)
            
            
        }while(!okWholeFlag)
        
        return (humanA, humanB)
    }
}



