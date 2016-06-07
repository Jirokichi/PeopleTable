//
//  HumanControll.swift
//  Toutyoku
//
//  Created by yuya on 2016/03/01.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Foundation


/// 当番表を作成するためのクラス
class HumanController{
    
    /// 当番表に登場する担当者
    let workingHuman:[Human]
    /// ルール
    let cRules:CRules
    

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
    
    /// ルールや担当者に基づいて当番表を作成する
    /// - parameter calendar : 当番表を作成する年月の情報。日はなんでもいい。
    /// - parameter inout running : 実行中かどうかを管理するためのフラグ。参照変数。
    /// - throws : 現在の条件で作成できない場合、CRule.RuleError.NotSarisfiedForMonthTableのエラーが投げられる
    /// - returns : 作成された当番表。
    func startCreatingRandomTable(calendar:NSDate, inout running:Bool) throws -> MonthTable{
        
        print("Start: \(NSDate())")
        self.cRules.view()
        
        var inValid:Bool
        var table:MonthTable = self.createInitializedMonthTable(calendar)
        
        try self.checkPrecondition(table)
        
        repeat{
            inValid = false
            do{
                if !running{
                    throw CRule.RuleError.Stop(msg: "キャンセルされました")
                }
                try self.createTableOnce(&table)
                
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
    
    private func checkPrecondition(table:MonthTable) throws{
        
        let isWeekEndRule:Bool
        if let rule = self.cRules.monthRule[.RuleWeekEnd] where rule.active{
            isWeekEndRule = true
        }else{
            isWeekEndRule = false
        }
        
        for dayInfo in table.days{
            var requiredHumans:[Human] = []
            for human in self.workingHuman{
                if human.requiredDays.contains(dayInfo.day){
                    requiredHumans.append(human)
                }
            }
            
            // 必須日の前条件チェック
            if requiredHumans.count > 2{
                var msg = ""
                msg += "\(dayInfo)日に二人以上が必須になっています("
                for human in requiredHumans{
                    msg = msg + human.name + ", "
                }
                msg = msg + ")"
                throw CRule.RuleError.Stop(msg: msg)
            }
        }
        
        for human in self.workingHuman{
            
            
            if let rule = self.cRules.monthRule[.RuleCountsInMonth] where rule.active{
                if (human.requiredDays.count > human.maxWorkingCountInAMonth){
                    let msg = "\(human.name)の１ヶ月の出勤日が上限の\(human.maxWorkingCountInAMonth)を超えています。"
                    throw CRule.RuleError.Stop(msg: msg)
                }
            }
            
            
            if let rule = self.cRules.monthRule[.RuleWeekEnd] where rule.active{
                var saturdayCount:Int = 0
                var sundayCount:Int = 0
                
                for day in human.requiredDays{
                    if table.days.contains({ (dayInfo) -> Bool in
                        if dayInfo.day == day && dayInfo.weekday == .Saturday{
                            return true
                        }else{
                            return false
                        }
                    }){
                        saturdayCount = saturdayCount + 1
                    }
                    
                    if table.days.contains({ (dayInfo) -> Bool in
                        if dayInfo.day == day && dayInfo.weekday == .Sunday{
                            return true
                        }else{
                            return false
                        }
                    }){
                        sundayCount = sundayCount + 1
                    }
                }
                
                if sundayCount > 1 || saturdayCount > 1{
                    let msg = "\(human.name)は土日どちらかで二回以上出勤しています。"
                    throw CRule.RuleError.Stop(msg: msg)
                }
                
            }
            
        }
        
        
        
    }
    
    ///　テーブルを作成する。個人ルールで作成できない場合は、CRuleのエラーが返ってくる。
    private func createTableOnce(inout table: MonthTable) throws{
        
        table.finishFlag = false
        table.days.removeAll()
        for human in self.workingHuman{
            human.workingCountInAMonth = 0
            human.workingCountOnEachWeek.removeAll()
        }
        
        for (var i = 0; i < table.dayOfLastDay; i++){
            let day = DayInfo(day: i+1, weekday: table.getWeekDay(i+1))
            let toutyokus:[Human]
            if i == 0{
                toutyokus = try self.selectTwoHumansInADay(checking:(i+1, day.weekday), previousDaysInfo: [])
            }else if i == 1{
                toutyokus = try self.selectTwoHumansInADay(checking:(i+1, day.weekday), previousDaysInfo: [table.days[i-1]])
            }else{
                toutyokus = try self.selectTwoHumansInADay(checking:(i+1, day.weekday), previousDaysInfo: [table.days[i-1], table.days[i-2]])
            }
            day.setHumans(toutyokus)
            table.days.append(day)
            
            
            
            
            for toutyoku in toutyokus{
                for human in self.workingHuman{
                    if human.id == toutyoku.id{
                        human.workingCountInAMonth = human.workingCountInAMonth + 1
                        human.workingCountOnEachWeek[day.weekday] = (human.workingCountOnEachWeek[day.weekday] ?? 0) + 1
                    }
                }
            }
        }
        table.finishFlag = true
    }
    
    
    /// **１日の担当者**をworkingHumanからcRuleルールに従って決定する。
    /// - parameter checking(Int, WeekDay)  : 作成する日の情報
    /// - parameter previousDaysInfo        : 反映する過去の情報
    /// - throws : 現在の条件で作成できない場合、CRule.RuleError.NotSarisfiedForMonthTableのエラーが投げられる
    func selectTwoHumansInADay(checking checking:(day:Int, weekday:WeekDay), previousDaysInfo:[DayInfo]) throws -> [Human]{
        
        /// この日に決まっている担当者を取得
        var requiredHumans:[Human] = []
        for human in workingHuman{
            if human.requiredDays.contains(checking.day){
                requiredHumans.append(human)
            }
        }
        
        if requiredHumans.count > 2{
            var msg = ""
            msg += "\(checking.day)日に二人以上が必須になっています("
            for human in requiredHumans{
                msg = msg + human.name + ", "
            }
            
            msg = msg + ")"
            throw CRule.RuleError.Stop(msg: msg)
        }
        
        let superHumans:[Human]
        let lowHumans:[Human]
        
        var lowHumanHasAlreadyBeenDecided = false
        if requiredHumans.count <= 0{
            // 担当者が一人も決まっていない場合
            superHumans = try self.getSpecificHumans(isSuper:true, checkingDayInfo:checking, previousDaysInfo:previousDaysInfo)
            lowHumans = try self.getSpecificHumans(isSuper:false, checkingDayInfo:checking, previousDaysInfo:previousDaysInfo)
        }else if requiredHumans.count == 2{
            // 担当者が2人とも決まっている場合
            if requiredHumans[0].isSuper{
                superHumans = [requiredHumans[0]]
                lowHumans = [requiredHumans[1]]
            }else{
                superHumans = [requiredHumans[1]]
                lowHumans = [requiredHumans[0]]
            }
        }else if requiredHumans.count == 1{
            // 担当者が1人決まっている場合
            if requiredHumans[0].isSuper{
                // 決まっている担当者がSuperの場合
                superHumans = [requiredHumans[0]]
                lowHumans = try self.getSpecificHumans(isSuper:false, checkingDayInfo:checking, previousDaysInfo:previousDaysInfo)
            }else{
                // 決まっている担当者がSuperでない場合
                lowHumanHasAlreadyBeenDecided = true
                lowHumans = [requiredHumans[0]]
                superHumans = try self.getSpecificHumans(isSuper:true, checkingDayInfo:checking, previousDaysInfo:previousDaysInfo)
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
                    let willSelectSuper:Bool
                    if lowHumanHasAlreadyBeenDecided{
                        willSelectSuper = false
                    }else{
                        willSelectSuper = ( Int(arc4random_uniform(100)) > Int(self.cRules.percentage * 100 ))
                    }
                    if willSelectSuper{
                        human = FormulaUtil.getRandomValue(superHumans)
                        try self.cRules.individualRule[.RuleNotDuplication]?.satisfyRule(objects: [human, toutyokus])
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
        
        
        /// IDが若い者が上になるように強制的にしている
        toutyokus = toutyokus.sort({ (A, B) -> Bool in
            if A.id < B.id{
                return true
            }else{
                return false
            }
        })
        
        return toutyokus
    }
    
    
    /// 注目日で、選択対象の担当者のリストを取得
    /// - parameter isSuper                         : Super位の人限定かどうか
    /// - parameter checkingDayInfo(Int, WeekDay)   : 作成する日の情報
    /// - parameter previousDaysInfo                : 反映する過去の情報
    /// - throws : 現在の条件で作成できない場合、CRule.RuleError.NotSarisfiedForMonthTableのエラーが投げられる
    private func getSpecificHumans(isSuper isSuper:Bool, checkingDayInfo:(day:Int, weekday:WeekDay), previousDaysInfo:[DayInfo]) throws -> [Human]{
        let specificHumans = workingHuman.filter({ (human) -> Bool in
            
            
            if let rule = self.cRules.individualRule[.RuleSuperUser] where rule.active{
                if (human.isSuper != isSuper){
                    return false
                }
            }
            
            if let rule = self.cRules.individualRule[.RuleUnavailableWeekDays] where rule.active{
                if (human.unableWeekDays.contains(checkingDayInfo.weekday)){
                    return false
                }
            }
            
            if let rule = self.cRules.individualRule[.RuleInterval] where rule.active{
                for day in previousDaysInfo{
                    for workedHuman in day.workingHuman{
                        if human.id == workedHuman.id{
                            return false
                        }
                    }
                }
                
                if  human.requiredDays.contains({(day:Int) -> Bool in
                    if day == checkingDayInfo.day + 1 ||  day == checkingDayInfo.day + 2{
                        return true
                    }else{
                        return false
                    }}){
                        
                        return false
                        
                }
            }
            
            if let rule = self.cRules.individualRule[.RuleUnavailableDays] where rule.active{
                if (human.forbittenDays.contains(checkingDayInfo.day)){
                    return false
                }
            }
            
            if let rule = self.cRules.monthRule[.RuleCountsInMonth] where rule.active{
                if (human.workingCountInAMonth == human.maxWorkingCountInAMonth){
                    return false
                }
            }
            
            if let rule = self.cRules.monthRule[.RulePractice] where rule.active && human.practiceRule.max > 0{
                if human.practiceRule.mustWeekDays.contains(checkingDayInfo.weekday){
                    if human.practiceRule.max == (human.workingCountOnEachWeek[checkingDayInfo.weekday] ?? 0){
                        return false
                    }
                }
            }
            
            if let rule = self.cRules.monthRule[.RuleWeekEnd] where rule.active{
                if (checkingDayInfo.weekday == WeekDay.Saturday || checkingDayInfo.weekday == WeekDay.Sunday){
                    if (human.workingCountOnEachWeek[checkingDayInfo.weekday] ?? 0) == 1{
                        return false
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
    
    /// 空の当番表を作成する
    /// parameter calendar: 対象の年月を指定するためのもの
    /// returns : 空の当番表
    func createInitializedMonthTable(calendar:NSDate) -> MonthTable{
        // 最終日付の取得
        let lastDayInThisMonth:NSDateComponents = DateUtil.getLastDay(calendar)
        
        // 最終日の取得
        let theNumberOfADay:Int = lastDayInThisMonth.day
        // 最終日の曜日
        let weekDayOfADay = WeekDay(rawValue: lastDayInThisMonth.weekday-1)!
        
        let table:MonthTable = MonthTable(dayOfLastDay: theNumberOfADay, weekDayOfLastDay:weekDayOfADay, humans:self.workingHuman)

        return table
    }
    
}