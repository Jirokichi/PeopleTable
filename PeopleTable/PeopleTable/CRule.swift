//
//  Rule.swift
//  Toutyoku
//
//  Created by yuya on 2016/03/06.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Foundation


// ルールを実行するかどうかのフラグ
struct CRule{
    /// ルールの名前
    let name:String
    /// ルールを利用するかどうか
    var active:Bool
    /// ルールを満たすならtrueを返す
    let satisfyRule:(objects:[Any]) throws->()
    
    
    enum RuleError :ErrorType{
        case NotSatisfiedForIndividual
        case NotSarisfiedForMonthTable
        case Stop(msg:String)
    }
    
    
    init(name:String, valid:Bool, satisfyRule:(objects:[Any]) throws ->() ){
        self.name = name
        self.active = valid
        
        /// ルールが有効ではないのならば必ずsatisfyRuleはtrueを返す
        if valid{
            self.satisfyRule = satisfyRule
        }else{
            self.satisfyRule = {(objects:[Any]) -> () in
                return true
            }
        }
    }
    
    func view(){
        print(" - \(name):\t \(active)")
    }
}

struct CRules{
    
    /// 個人のルール。なお、すでに日にちで担当者が決まっている場合はこれらのルールは無視される。
    enum Individual{
        case RuleNotDuplication
        /// superフラグのある担当者が少なくとも１日一人いるというルール
        case RuleSuperUser
        /// 特定の曜日は働けないというルール
        case RuleUnavailableWeekDays
        /// 一度働くと、指定した日数休まなければならないというルール
        case RuleInterval
        /// 特定の日付は働けないというルール
        case RuleUnavailableDays
    }
    
    // 月のルール
    enum Month{
        // １ヶ月間で、週末に働ける回数が決まっているというルール
        case RuleWeekEnd
        // 練習生は火曜日もしくは木曜日に必ず働く必要があるというルール
        case RulePractice
        // １ヶ月間で、働ける上限と下限の回数が決まっているというルール
        case RuleCountsInMonth
    }
    
    var individualRule:Dictionary<Individual, CRule>
    var monthRule:Dictionary<Month, CRule>
    // 二人目で下位の人が出る確率（片方は必ず上位なので、乱数で発生しやすくしておかないと偏りがでてしまう）
    let percentage:Double
    
    
    init(percentage:Double = 0.75){
        self.percentage = percentage
        individualRule = [:]
        monthRule = [:]
    }
    
    func view(){
        
        print("percentage:\(percentage)")
        print("[indeividualRules]")
        for key in individualRule.keys{
            individualRule[key]?.view()
        }
        
        print("[monthRules]")
        for key in monthRule.keys{
            monthRule[key]?.view()
        }
    }
    
    mutating func createIndividualRule(ruleNotDuplication:Bool, RuleSuperUser:Bool, RuleUnavailableWeekDays:Bool, RuleInterval:Bool, RuleUnavailableDays:Bool){
        /// ルール0: 同一ユーザーは1日に選択できない
        individualRule[.RuleNotDuplication] = CRule(name: "RuleNotDuplication", valid: ruleNotDuplication) { (objects:[Any]) throws -> () in
            
            if objects.count != 2{
                fatalError()
            }
            guard let human = objects[0] as? Human else{fatalError()}
            guard let toutyokus = objects[1] as? [Human] else{fatalError()}
            
            for toutyoku in toutyokus{
                if human.name == toutyoku.name{
                    throw CRule.RuleError.NotSatisfiedForIndividual
                }
            }
        }
        
        /// ルールA: 一人目は上位である
        individualRule[.RuleSuperUser] = CRule(name: "RuleSuperUser", valid: RuleSuperUser) { (objects:[Any]) throws -> () in
            
            if objects.count != 2{
                fatalError()
            }
            guard let toutyokus = objects[0] as? [Human] else{fatalError()}
            if toutyokus.count > 0{
                return
            }
            
            guard let object = objects[1] as? Human else{fatalError()}
            
            
            // もしSuperでないならば、エラーを返す
            if !object.isSuper{
                throw CRule.RuleError.NotSatisfiedForIndividual
            }
            
        }
        
        /// ルールB: 各人で決められている禁止曜日でない
        individualRule[.RuleUnavailableWeekDays] = CRule(name: "RuleUnavailableWeekDays", valid: RuleUnavailableWeekDays) { (objects:[Any]) throws -> () in
            if objects.count != 2{
                fatalError()
            }
            guard let human = objects[0] as? Human else{fatalError()}
            guard let weekday = objects[1] as? WeekDay else{fatalError()}
            
            
            // 禁止曜日だったならエラーを返す
            if human.unableWeekDays.contains(weekday){
                throw CRule.RuleError.NotSatisfiedForIndividual
            }
            
        }
        
        /// ルールC: 前日及び前前日、前前前日の担当でない
        individualRule[.RuleInterval] = CRule(name: "RuleInterval", valid: RuleInterval) { (objects:[Any]) throws -> () in
            if objects.count != 2{
                fatalError()
            }
            guard let human = objects[0] as? Human else{fatalError()}
            guard let daysInfo = objects[1] as? [DayInfo] else{fatalError()}
            
            
            for day in daysInfo{
                let humanA = day.workingHuman[0]
                let humanB = day.workingHuman[1]
                if (human.name == humanA.name || human.name == humanB.name){
                    // 直近で働いていたらエラーを返す
                    throw CRule.RuleError.NotSatisfiedForIndividual
                }
            }
        }
        
        /// ルールC: 禁止日でない
        individualRule[.RuleUnavailableDays] = CRule(name: "RuleUnavailableDays", valid: RuleUnavailableDays) { (objects:[Any]) throws -> () in
            if objects.count != 2{
                fatalError()
            }
            guard let human = objects[0] as? Human else{fatalError()}
            guard let day = objects[1] as? Int else{fatalError()}
            
            if (human.forbittenDays.contains(day)){
                throw CRule.RuleError.NotSatisfiedForIndividual
                
            }
        }
    }
    
    mutating func createMonthRule(RuleWeekEnd:Bool, RulePractice:Bool, RuleCountsInMonth:Bool){
        /// ルールA: 土曜・日曜日は一回ずつ
        monthRule[.RuleWeekEnd] = CRule(name: "RuleWeekEnd", valid: RuleWeekEnd) { (objects:[Any]) throws -> () in
            
            if objects.count != 2{
                fatalError()
            }
            
            guard let table = objects[0] as? MonthTable else{fatalError()}
            guard let humans = objects[1] as? [Human] else{fatalError()}
            
            for human in humans{
                let name = human.name
                
                var saturdayCount = 0
                var sundayCount = 0
                
                for dayInfo in table.days{
                    
                    if dayInfo.weekday == .Saturday{
                        for workingHuman in dayInfo.workingHuman{
                            if workingHuman.name == name{
                                saturdayCount++
                            }
                        }
                    }else if dayInfo.weekday == .Sunday{
                        for workingHuman in dayInfo.workingHuman{
                            if workingHuman.name == name{
                                sundayCount++
                            }
                        }
                    }
                    
                }
                
                //                print("\(name):(saturdayCount, sundayCount) = (\(saturdayCount), \(sundayCount))")
                if saturdayCount > 1 || sundayCount > 1{
//                    print("RuleA fail -------------------------------")
                    throw CRule.RuleError.NotSarisfiedForMonthTable
                }
                
            }
            
        }
        /// 見習い生用ルール(特定の曜日で少なくとも一回はやらないといけず、上限もきまっている)
        monthRule[.RulePractice] = CRule(name: "RulePractice", valid: RulePractice) { (objects:[Any]) throws -> () in
            
            if objects.count != 2{
                fatalError()
            }
            
            guard let table = objects[0] as? MonthTable else{fatalError()}
            guard let humans = objects[1] as? [Human] else{fatalError()}
            
            for human in humans{
                let name = human.name
                
                
                var counts:Dictionary<WeekDay, Int> = [:]
                for week in human.practiceRule.mustWeekDays{
                    counts[week] = 0
                }
                
                for dayInfo in table.days{
                    if counts[dayInfo.weekday] != nil{
                        for workingHuman in dayInfo.workingHuman{
                            if workingHuman.name == name{
                                counts[dayInfo.weekday]!++
                            }
                        }
                    }
                }
                
                for week in human.practiceRule.mustWeekDays{
                    print("\(name)(\(week)) = (\(counts[week])")
                    if let count = counts[week] where count > human.practiceRule.max || count < 1{
                        print("RuleB fail -------------------------------")
                        throw CRule.RuleError.NotSarisfiedForMonthTable
                    }
                }
            }
        }
        
        /// 月の最大と最低回数を満たしているかのチェック
        monthRule[.RuleCountsInMonth] = CRule(name: "RuleCountsInMonth", valid: RuleCountsInMonth) { (objects:[Any]) throws -> () in
            
            if objects.count != 2{
                fatalError()
            }
            
            guard let days = objects[0] as? [DayInfo] else{fatalError()}
            guard let humans = objects[1] as? [Human] else{fatalError()}
            
            
            var counts:Dictionary<Int, Int> = [:]
            for human in humans{
                counts[human.id] = 0
            }
            
            for day in days{
                counts[day.workingHuman[0].id]!++
                counts[day.workingHuman[1].id]!++
            }
            
            for human in humans{
                print("\(human.name):\(counts[human.id])")
                if counts[human.id] < human.minWorkingCountInAMonth || counts[human.id] > human.maxWorkingCountInAMonth{
                    print("RuleC fail -------------------------------")
                    throw CRule.RuleError.NotSarisfiedForMonthTable
                }
            }
        }
        
        
    }
    
}


