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
    private func satisfyCommonRule(humans:[Human], weekday:WeekDay, yesterdayInfo:DayInfo?) -> Bool{
        var okIndividualFlag:Bool
        // 人ごとに決められている曜日であること
        okIndividualFlag = Rule.Individual.RuleB.satisfyRule(objects: [self, weekday])
        if okIndividualFlag{
            // 昨日の担当者ではないこと
            if let yesterdayInfo = yesterdayInfo{
                okIndividualFlag = Rule.Individual.RuleC.satisfyRule(objects: [self, yesterdayInfo])
            }
        }
        return okIndividualFlag
    }
    
    static func selectTwoHumansInADay(humans:[Human], weekday:WeekDay, yesterdayInfo:DayInfo?) -> (Human, Human){
        // 人数
        let count:UInt32 = UInt32(humans.count)
        
        var humanA:Human
        var humanB:Human
        
        var okWholeFlag:Bool
        
        repeat{
            okWholeFlag = true
            
            // HumanAの決定
            var okIndividualFlag:Bool
            repeat{
                humanA = humans[Int(arc4random_uniform(count))]
                // 条件⑴必ず片方はSuperであること
                okIndividualFlag = Rule.Individual.RuleA.satisfyRule(objects: [humanA])
                if okIndividualFlag{
                    okIndividualFlag = humanA.satisfyCommonRule(humans, weekday: weekday, yesterdayInfo: yesterdayInfo)
                }
            }while(!okIndividualFlag)
            
            
            // HumanBの決定
            humanB = humans[Int(arc4random_uniform(count))]
            repeat{
                humanB = humans[Int(arc4random_uniform(count))]
                // 暗黙のルール
                okIndividualFlag = (humanB.name != humanA.name)
                if okIndividualFlag{
                    okIndividualFlag = humanB.satisfyCommonRule(humans, weekday: weekday, yesterdayInfo: yesterdayInfo)
                }
            }while(!okIndividualFlag)
            
            
        }while(!okWholeFlag)
        
        return (humanA, humanB)
    }
}



