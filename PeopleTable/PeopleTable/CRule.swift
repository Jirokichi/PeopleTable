//
//  Rule.swift
//  Toutyoku
//
//  Created by yuya on 2016/03/06.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
private func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
private func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



// ルールを実行するかどうかのフラグ
struct CRule{
    /// ルールの名前
    let name:String
    /// ルールを利用するかどうか
    var active:Bool
    /// ルールを満たすならtrueを返す
    let satisfyRule:(_ objects:[Any]) throws->()
    
    
    enum RuleError :Error{
        case notSatisfiedForIndividual
        case notSarisfiedForMonthTable
        case stop(msg:String)
    }
    
    
    init(name:String, valid:Bool, satisfyRule:@escaping (_ objects:[Any]) throws ->() ){
        self.name = name
        self.active = valid
        
        /// ルールが有効ではないのならば必ずsatisfyRuleはtrueを返す
        if valid{
            self.satisfyRule = satisfyRule
        }else{
            self.satisfyRule = {(_ objects:[Any]) -> () in
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
        case ruleNotDuplication
        /// superフラグのある担当者が少なくとも１日一人いるというルール
        case ruleSuperUser
        /// 特定の曜日は働けないというルール
        case ruleUnavailableWeekDays
        /// 一度働くと、指定した日数休まなければならないというルール
        case ruleInterval
        /// 特定の日付は働けないというルール
        case ruleUnavailableDays
    }
    
    // 月のルール
    enum Month{
        // １ヶ月間で、週末に働ける回数が決まっているというルール
        case ruleWeekEnd
        // 練習生は火曜日もしくは木曜日に必ず働く必要があるというルール
        case rulePractice
        // １ヶ月間で、働ける上限と下限の回数が決まっているというルール
        case ruleCountsInMonth
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
    
    mutating func createIndividualRule(_ ruleNotDuplication:Bool, RuleSuperUser:Bool, RuleUnavailableWeekDays:Bool, RuleInterval:Bool, RuleUnavailableDays:Bool){
        /// ルール0: 同一ユーザーは1日に選択できない
        individualRule[.ruleNotDuplication] = CRule(name: "RuleNotDuplication", valid: ruleNotDuplication) { (objects:[Any]) throws -> () in
            
            if objects.count != 2{
                fatalError()
            }
            guard let human = objects[0] as? Human else{fatalError()}
            guard let toutyokus = objects[1] as? [Human] else{fatalError()}
            
            for toutyoku in toutyokus{
                if human.name == toutyoku.name{
                    throw CRule.RuleError.notSatisfiedForIndividual
                }
            }
        }
        
        /// ルールA: 一人目は上位である
        individualRule[.ruleSuperUser] = CRule(name: "RuleSuperUser", valid: RuleSuperUser) { (objects:[Any]) throws -> () in
            
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
                throw CRule.RuleError.notSatisfiedForIndividual
            }
            
        }
        
        /// ルールB: 各人で決められている禁止曜日でない
        individualRule[.ruleUnavailableWeekDays] = CRule(name: "RuleUnavailableWeekDays", valid: RuleUnavailableWeekDays) { (objects:[Any]) throws -> () in
            if objects.count != 2{
                fatalError()
            }
            guard let human = objects[0] as? Human else{fatalError()}
            guard let weekday = objects[1] as? WeekDay else{fatalError()}
            
            
            // 禁止曜日だったならエラーを返す
            if human.unableWeekDays.contains(weekday){
                throw CRule.RuleError.notSatisfiedForIndividual
            }
            
        }
        
        /// ルールC: 前日及び前前日、前前前日の担当でない
        individualRule[.ruleInterval] = CRule(name: "RuleInterval", valid: RuleInterval) { (objects:[Any]) throws -> () in
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
                    throw CRule.RuleError.notSatisfiedForIndividual
                }
            }
        }
        
        /// ルールC: 禁止日でない
        individualRule[.ruleUnavailableDays] = CRule(name: "RuleUnavailableDays", valid: RuleUnavailableDays) { (objects:[Any]) throws -> () in
            if objects.count != 2{
                fatalError()
            }
            guard let human = objects[0] as? Human else{fatalError()}
            guard let day = objects[1] as? Int else{fatalError()}
            
            if (human.forbittenDays.contains(day)){
                throw CRule.RuleError.notSatisfiedForIndividual
                
            }
        }
    }
    
    mutating func createMonthRule(_ RuleWeekEnd:Bool, RulePractice:Bool, RuleCountsInMonth:Bool){
        /// ルールA: 土曜・日曜日は一回ずつ
        monthRule[.ruleWeekEnd] = CRule(name: "RuleWeekEnd", valid: RuleWeekEnd) { (objects:[Any]) throws -> () in
            
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
                    
                    if dayInfo.weekday == .saturday{
                        for workingHuman in dayInfo.workingHuman{
                            if workingHuman.name == name{
                                saturdayCount += 1
                            }
                        }
                    }else if dayInfo.weekday == .sunday{
                        for workingHuman in dayInfo.workingHuman{
                            if workingHuman.name == name{
                                sundayCount += 1
                            }
                        }
                    }
                    
                }
                
                //                print("\(name):(saturdayCount, sundayCount) = (\(saturdayCount), \(sundayCount))")
                if saturdayCount > 1 || sundayCount > 1{
//                    print("RuleA fail -------------------------------")
                    throw CRule.RuleError.notSarisfiedForMonthTable
                }
                
            }
            
        }
        /// 見習い生用ルール(特定の曜日で少なくとも一回はやらないといけず、上限もきまっている)
        monthRule[.rulePractice] = CRule(name: "RulePractice", valid: RulePractice) { (objects:[Any]) throws -> () in
            
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
                                counts[dayInfo.weekday]! += 1
                            }
                        }
                    }
                }
                
                for week in human.practiceRule.mustWeekDays{
                    print("\(name)(\(week)) = (\(counts[week])")
                    if let count = counts[week], count > human.practiceRule.max || count < 1{
                        print("RuleB fail -------------------------------")
                        throw CRule.RuleError.notSarisfiedForMonthTable
                    }
                }
            }
        }
        
        /// 月の最大と最低回数を満たしているかのチェック
        monthRule[.ruleCountsInMonth] = CRule(name: "RuleCountsInMonth", valid: RuleCountsInMonth) { (objects:[Any]) throws -> () in
            
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
                counts[day.workingHuman[0].id]! += 1
                counts[day.workingHuman[1].id]! += 1
            }
            
            for human in humans{
                print("\(human.name):\(counts[human.id])")
                if counts[human.id] < human.minWorkingCountInAMonth || counts[human.id] > human.maxWorkingCountInAMonth{
                    print("RuleC fail -------------------------------")
                    throw CRule.RuleError.notSarisfiedForMonthTable
                }
            }
        }
        
        
    }
    
}


