//
//  Rule.swift
//  Toutyoku
//
//  Created by yuya on 2016/03/06.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Foundation

// ルールを実行するかどうかのフラグ
struct Rule{
    /// ルールの名前
    let name:String
    /// ルールを利用するかどうか
    private let valid:Bool
    /// ルールを満たすならtrueを返す
    let satisfyRule:(objects:[Any])->Bool
    
    
    init(name:String, valid:Bool, satisfyRule:(objects:[Any])->Bool){
        self.name = name
        self.valid = valid
        
        /// ルールが有効ではないのならば必ずsatisfyRuleはtrueを返す
        if valid{
            self.satisfyRule = satisfyRule
        }else{
            self.satisfyRule = {(objects:[Any]) -> Bool in
                return true
            }
        }
    }
    
    // 個人のルール
    struct Individual{
        /// ルールA: 上位である
        static let RuleA:Rule = Rule(name: "RuleA", valid: true) { (objects:[Any]) -> Bool in
            
            if objects.count != 1{
                fatalError()
            }
            guard let object = objects[0] as? Human else{fatalError()}
            
            return object.isSuper
            
        }
        
        /// ルールB: 各人で決められている禁止曜日でない
        static let RuleB:Rule = Rule(name: "RuleB", valid: true) { (objects:[Any]) -> Bool in
            if objects.count != 2{
                fatalError()
            }
            guard let human = objects[0] as? Human else{fatalError()}
            guard let weekday = objects[1] as? WeekDay else{fatalError()}
            return !human.unableWeekDays.contains(weekday)
        }
        
        /// ルールC: 前日の担当でない
        static let RuleC:Rule = Rule(name: "RuleC", valid: true) { (objects:[Any]) -> Bool in
            if objects.count != 2{
                fatalError()
            }
            guard let human = objects[0] as? Human else{fatalError()}
            guard let yesterdayInfo = objects[1] as? DayInfo else{fatalError()}
            
            let humanA = yesterdayInfo.workingHuman[0]
            let humanB = yesterdayInfo.workingHuman[1]
            return (human.name != humanA.name && human.name != humanB.name)
        }
    }
    
    struct MonthRule{
        /// ルールA: 土曜・日曜日は一回ずつ
        static let RuleA:Rule = Rule(name: "RuleA", valid: true) { (objects:[Any]) -> Bool in
            
            if objects.count != 2{
                fatalError()
            }
            
            guard let table = objects[0] as? MonthTable else{fatalError()}
            guard let humans = objects[1] as? [Human] else{fatalError()}
            
            var valid:Bool = true
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
                    return false
                }
                
            }
            
            
            
            return valid
            
        }
        /// 見習い生用ルール:
        static let RuleB:Rule = Rule(name: "RuleB", valid: true) { (objects:[Any]) -> Bool in
            
            if objects.count != 2{
                fatalError()
            }
            
            guard let table = objects[0] as? MonthTable else{fatalError()}
            guard let humans = objects[1] as? [Human] else{fatalError()}
            
            var valid:Bool = true
            for human in humans{
                let name = human.name
                
                // 必須曜日がない場合
                if human.practiceRule.mustWeekDays.count <= 0{
                    continue
                }
                
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
                        return false
                    }
                }
            }
            
            return valid
        }
    }
    
}