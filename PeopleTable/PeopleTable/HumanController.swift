//
//  HumanControll.swift
//  Toutyoku
//
//  Created by yuya on 2016/03/01.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Foundation


// テーブルの作成を実行する
class HumanController{
    
    let workingHuman:[Human]
    let cRules:CRules
    
    /// 担当者の情報(名前と担当不可曜日)を作成
    init(workingHuman:[Human], cRules:CRules){
        self.workingHuman = workingHuman
        self.cRules = cRules
        
        var ids:[Int] = []
        for human in workingHuman{
            ids.append(human.id)
        }
        let orderedSet = NSOrderedSet(array: ids)
        if let uniqueValues = orderedSet.array as? [Int]{
            if uniqueValues.count == ids.count{
                return
            }
        }
        fatalError()
    }
    
    func startCreatingRandomTable(calendar:NSDate, inout running:Bool) throws -> MonthTable{
        
        print("Start: \(NSDate())")
        self.cRules.view()
        
        var inValid:Bool
        let table:MonthTable = self.createInitializedMonthTable(calendar)
        repeat{
            inValid = false
            do{
                if !running{
                    throw CRule.RuleError.Stop(msg: "キャンセルされました")
                }
                try table.createTableAutomatically()
                // 月テーブルの評価
                try self.cRules.monthRule[.RuleWeekEnd]?.satisfyRule(objects: [table, workingHuman])
                try self.cRules.monthRule[.RulePractice]?.satisfyRule(objects: [table, workingHuman])
                try self.cRules.monthRule[.RuleCountsInMonth]?.satisfyRule(objects: [table.days, workingHuman])
                
                
            }catch let error as CRule.RuleError{
                switch error{
                case .NotSarisfiedForMonthTable:
                    inValid = true
                default:
                    throw error
                }
            }
        }while inValid
        
        // 結果の確認
        table.viewTable()
        
        print("Finish: \(NSDate())")
        
        return table
    }
    
    func selectTwoHumansInADay(checking checking:(day:Int, weekday:WeekDay), previousDaysInfo:[DayInfo]) throws -> [Human]{
        
        
        var requiredHumans:[Human] = []
        for human in workingHuman{
            if human.requiredDays.contains(checking.day){
                requiredHumans.append(human)
            }
        }
        
        let superHumans:[Human]
        let lowHumans:[Human]
        
        if requiredHumans.count <= 0{
            superHumans = try self.getSpecificHumans(isSuper:true, checking:checking, previousDaysInfo:previousDaysInfo)
            lowHumans = try self.getSpecificHumans(isSuper:false, checking:checking, previousDaysInfo:previousDaysInfo)
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
                lowHumans = try self.getSpecificHumans(isSuper:false, checking:checking, previousDaysInfo:previousDaysInfo)
            }else{
                lowHumans = [requiredHumans[0]]
                superHumans = try self.getSpecificHumans(isSuper:true, checking:checking, previousDaysInfo:previousDaysInfo)
            }
        }else{
            superHumans = []
            lowHumans = []
            LogUtil.log("fatalError")
            throw CRule.RuleError.Stop(msg: "必須日(\(checking.day)日)に矛盾")
        }
        
        
        
        var toutyokus:[Human] = []
        var human:Human
        
        
        var okWholeFlag:Bool
        repeat{
            okWholeFlag = true
            toutyokus.removeAll()
            // HumanAの決定
            human = FormulaUtil.getRandomValue(superHumans)
            toutyokus.append(human)
            
            do{
                if superHumans.count >= 2{
                    let willSelectSuper = ( Int(arc4random_uniform(100)) > Int(self.cRules.percentage * 100 ))
                    if willSelectSuper{
                        human = FormulaUtil.getRandomValue(superHumans)
                        try self.cRules.individualRule[.Rule0]?.satisfyRule(objects: [human, toutyokus])
                    }else{
                        human = FormulaUtil.getRandomValue(lowHumans)
                    }
                }else{
                    human = FormulaUtil.getRandomValue(lowHumans)
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
    
    
    
    private func getSpecificHumans(isSuper isSuper:Bool, checking:(day:Int, weekday:WeekDay), previousDaysInfo:[DayInfo]) throws -> [Human]{
        let specificHumans = workingHuman.filter({ (human) -> Bool in
            
            
            if let rule = self.cRules.individualRule[.RuleSuperUser]{
                if rule.active{
                    if (human.isSuper != isSuper){
                        return false
                    }
                }
            }
            
            if let rule = self.cRules.individualRule[.RuleUnavailableWeekDays]{
                if rule.active{
                    if (human.unableWeekDays.contains(checking.weekday)){
                        return false
                    }
                }
            }
            
            if let rule = self.cRules.individualRule[.RuleInterval]{
                if rule.active{
                    for day in previousDaysInfo{
                        for workedHuman in day.workingHuman{
                            if human.id == workedHuman.id{
                                return false
                            }
                        }
                    }
                    
                    if  human.requiredDays.contains({(day:Int) -> Bool in
                        if day == checking.day + 1 ||  day == checking.day + 2{
                            return true
                        }else{
                            return false
                        }}){
                            
                            return false
                            
                    }
                    
                }
            }
            
            if let rule = self.cRules.individualRule[.RuleUnavailableDays]{
                if rule.active{
                    if (human.forbittenDays.contains(checking.day)){
                        return false
                    }
                }
            }
            
            if let rule = self.cRules.monthRule[.RuleCountsInMonth]{
                if rule.active{
                    if (human.workingCountInAMonth == human.maxWorkingCountInAMonth){
                        return false
                    }
                }
            }
            
            if let rule = self.cRules.monthRule[.RulePractice]{
                if rule.active{
                    if human.practiceRule.max > 0{
                        if human.practiceRule.mustWeekDays.contains(checking.weekday){
                            if human.practiceRule.max == (human.workingCountOnEachWeek[checking.weekday] ?? 0){
                                return false
                            }
                        }
                    }
                }
            }
            
            if let rule = self.cRules.monthRule[.RuleWeekEnd]{
                if rule.active{
                    if (checking.weekday == WeekDay.Saturday || checking.weekday == WeekDay.Sunday){
                        if (human.workingCountOnEachWeek[checking.weekday] ?? 0) == 1{
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
    
    func createInitializedMonthTable(calendar:NSDate) -> MonthTable{
        // 最終日付の取得
        let lastDayInThisMonth:NSDateComponents = DateUtil.getLastDay(calendar)
        
        // 最終日の取得
        let theNumberOfADay:Int = lastDayInThisMonth.day
        // 最終日の曜日
        let weekDayOfADay = WeekDay(rawValue: lastDayInThisMonth.weekday-1)!
        
        let table:MonthTable = MonthTable(dayOfLastDay: theNumberOfADay, weekDayOfLastDay:weekDayOfADay, humans:self.workingHuman, rules:self.cRules, contoller: self)

        return table
    }
    
    
    
    

    
    
}