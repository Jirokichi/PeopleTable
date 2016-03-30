//
//  People.swift
//  PeopleTable
//
//  Created by yuya on 2016/03/12.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Foundation
import CoreData


class People: Records {
    struct Constant{
        private static let TableName = "People"
        
        private static let AttributesDate = "createdDate"
    }
    
    
    /// unavailabeWeekDaysがJsonのためそれ用の処理を担当するstruct。
    struct PTWeekDays{
        private enum JsonKey:String{
            case Sun = "Sun"
            case Mon = "Mon"
            case Tue = "Tue"
            case Wed = "Wed"
            case Thu = "Thu"
            case Fri = "Fri"
            case Sat = "Sat"
            
            
            init(weekday:WeekDay){
                switch weekday{
                case .Sunday:
                    self = .Sun
                case .Monday:
                    self = .Mon
                case .Tuesday:
                    self = .Tue
                case .Wednesday:
                    self = .Wed
                case .Thursday:
                    self = .Thu
                case .Friday:
                    self = .Fri
                case .Saturday:
                    self = .Sat
                }
            }
            
            func getWeekDay() -> WeekDay{
                switch self{
                case .Sun:
                    return WeekDay.Sunday
                case .Mon:
                    return WeekDay.Monday
                case .Tue:
                    return WeekDay.Tuesday
                case .Wed:
                    return WeekDay.Wednesday
                case .Thu:
                    return WeekDay.Thursday
                case .Fri:
                    return WeekDay.Friday
                case .Sat:
                    return WeekDay.Saturday
                }
            }
        }
        
        var jsonDict:[WeekDay:Bool]
        
        init(jsonDict:[WeekDay:Bool]){
            self.jsonDict = jsonDict
        }
        
        func getWeekDays() -> [WeekDay]{
            var weekDays:[WeekDay] = []
            
            for (weekDay, status) in jsonDict{
                if status{
                    weekDays.append(weekDay)
                }
            }
            return weekDays
        }
        
        mutating func updateJsonDict(weekDay:WeekDay){
            let alreadyMarked = self.jsonDict.contains({ (predicate:(weekDay:WeekDay, status:Bool)) -> Bool in
                if predicate.weekDay == weekDay{
                    return true
                }else{
                    return false
                }
            })
            
            if alreadyMarked{
                // マークを消す
                self.jsonDict[weekDay] = !self.jsonDict[weekDay]!
                
                
            }else{
                // マークをつける
                self.jsonDict[weekDay] = true
            }
        }
        
        /// DictionaryからJsonを作成するメソッド
        func getJsonFromDict() -> String{
            
            var jsonDict:[String:String] = [:]
            for (weekDay, status) in self.jsonDict{
                jsonDict[JsonKey(weekday: weekDay).rawValue] = "\(status)"
            }
            
            // Dict -> JSON
            do{
                let jsonData = try NSJSONSerialization.dataWithJSONObject(jsonDict, options: [])
                if let result = NSString(data: jsonData, encoding: NSUTF8StringEncoding){
                    return result as String
                }
            }catch{
                LogUtil.log("Error")
            }
            return ""
        }
        
        /// DictionaryからJsonを作成する静的メソッド
        static func getDicsFromJson(str:String?) -> PTWeekDays?{
            if str == nil{
                return nil
            }
            // JSON -> Dict
            if let jsonData: NSData = (str! as NSString).dataUsingEncoding(NSUTF8StringEncoding){
                
                do{
                    if let jsonString = try NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as? [String : String]{
                        
                        var dict:[WeekDay:Bool] = [:]
                        for (weekDay, status) in jsonString{
                            if let jsonkey = JsonKey(rawValue: weekDay){
                                dict[jsonkey.getWeekDay()] = ((status == "\(true)") ? true : false)
                            }
                        }
                        return PTWeekDays(jsonDict: dict)
                    }
                }catch{
                    
                }
            }
            return nil
        }
    }
    
    /// protected - テーブル名を返す
    override class func _getTableName() -> String{
        return Constant.TableName
    }
    
    init(context:NSManagedObjectContext){
        super.init(tableName: Constant.TableName, context: context)
    }
    
    /// これを実装しておかないとエラーがおきる
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    
    func updateParameters(createdDate:NSDate, name:String, status:Bool, unavailableWeekDays:PTWeekDays, requiredWeekDays:PTWeekDays, limitOfRequiredWeekDays:Int, isSuper:Bool, maxWorkingCountInAMonth:Int, minWorkingCountInAMonth:Int) -> People{
        self.createdDate = createdDate
        self.name = name
        self.status = status
        self.unavailableWeekDays = unavailableWeekDays.getJsonFromDict()
        self.requiredWeekDays = requiredWeekDays.getJsonFromDict()
        self.limitOfRequiredWeekDays = limitOfRequiredWeekDays
        self.isSuper = isSuper
        self.maxWorkingCountInAMonth = maxWorkingCountInAMonth
        self.minWorkingCountInAMonth = minWorkingCountInAMonth
        
        return self
    }
    
    static func createSortDescriptor() -> NSSortDescriptor{
        let sortDescriptor = NSSortDescriptor(key: People.Constant.AttributesDate, ascending: true)
        return sortDescriptor
    }
    
    static func createDefaultPeoples(coreDataManagement:CoreDataManagement) -> [People]{
        var humans:[People] = []
        humans.append(People(context: coreDataManagement.managedObjectContext).updateParameters(
            NSDate(),
            name: "A",
            status: true,
            unavailableWeekDays: People.PTWeekDays(jsonDict: [WeekDay.Sunday:true, WeekDay.Monday:true]),
            requiredWeekDays: People.PTWeekDays(jsonDict: [:]),
            limitOfRequiredWeekDays: 0,
            isSuper: true,
            maxWorkingCountInAMonth: 6,
            minWorkingCountInAMonth: 4)
        )
        
        humans.append(People(context: coreDataManagement.managedObjectContext).updateParameters(
            NSDate(),
            name: "B",
            status: true,
            unavailableWeekDays: People.PTWeekDays(jsonDict: [WeekDay.Tuesday:true, WeekDay.Wednesday:true]),
            requiredWeekDays: People.PTWeekDays(jsonDict: [:]),
            limitOfRequiredWeekDays: 0,
            isSuper: true,
            maxWorkingCountInAMonth: 6,
            minWorkingCountInAMonth: 4
            ))
        
        
        humans.append(People(context: coreDataManagement.managedObjectContext).updateParameters(
            NSDate(),
            name: "C",
            status: true,
            unavailableWeekDays: People.PTWeekDays(jsonDict: [WeekDay.Tuesday:true , WeekDay.Wednesday:true]),
            requiredWeekDays: People.PTWeekDays(jsonDict: [:]),
            limitOfRequiredWeekDays: 0,
            isSuper: true,
            maxWorkingCountInAMonth: 6,
            minWorkingCountInAMonth: 4))
        
        humans.append(People(context: coreDataManagement.managedObjectContext).updateParameters(
            NSDate(),
            name: "D",
            status: true,
            unavailableWeekDays: People.PTWeekDays(jsonDict: [:]),
            requiredWeekDays: People.PTWeekDays(jsonDict: [:]),
            limitOfRequiredWeekDays: 0,
            isSuper: true,
            maxWorkingCountInAMonth: 6,
            minWorkingCountInAMonth: 4))
        
        
        
        humans.append(People(context: coreDataManagement.managedObjectContext).updateParameters(
            NSDate(),
            name: "E",
            status: true,
            unavailableWeekDays: People.PTWeekDays(jsonDict: [:]),
            requiredWeekDays: People.PTWeekDays(jsonDict: [:]),
            limitOfRequiredWeekDays: 0,
            isSuper: true,
            maxWorkingCountInAMonth: 6,
            minWorkingCountInAMonth: 4))
        
        humans.append(People(context: coreDataManagement.managedObjectContext).updateParameters(
            NSDate(),
            name: "F",
            status: true,
            unavailableWeekDays: People.PTWeekDays(jsonDict: [:]),
            requiredWeekDays: People.PTWeekDays(jsonDict: [:]),
            limitOfRequiredWeekDays: 0,
            isSuper: true,
            maxWorkingCountInAMonth: 6,
            minWorkingCountInAMonth: 4))
        
        humans.append(People(context: coreDataManagement.managedObjectContext).updateParameters(
            NSDate(),
            name: "G",
            status: true,
            unavailableWeekDays: People.PTWeekDays(jsonDict: [:]),
            requiredWeekDays: People.PTWeekDays(jsonDict: [WeekDay.Tuesday:true, WeekDay.Thursday:true]),
            limitOfRequiredWeekDays: 2,
            isSuper: false,
            maxWorkingCountInAMonth: 6,
            minWorkingCountInAMonth: 4))
        
        humans.append(People(context: coreDataManagement.managedObjectContext).updateParameters(
            NSDate(),
            name: "H",
            status: true,
            unavailableWeekDays: People.PTWeekDays(jsonDict: [:]),
            requiredWeekDays: People.PTWeekDays(jsonDict: [WeekDay.Tuesday:true, WeekDay.Thursday:true]),
            limitOfRequiredWeekDays: 2,
            isSuper: false,
            maxWorkingCountInAMonth: 6,
            minWorkingCountInAMonth: 4))
        humans.append(People(context: coreDataManagement.managedObjectContext).updateParameters(
            NSDate(),
            name: "I",
            status: true,
            unavailableWeekDays: People.PTWeekDays(jsonDict: [:]),
            requiredWeekDays: People.PTWeekDays(jsonDict: [WeekDay.Tuesday:true, WeekDay.Thursday:true]),
            limitOfRequiredWeekDays: 2,
            isSuper: false,
            maxWorkingCountInAMonth: 6,
            minWorkingCountInAMonth: 4))
        
        humans.append(People(context: coreDataManagement.managedObjectContext).updateParameters(
            NSDate(),
            name: "J",
            status: true,
            unavailableWeekDays: People.PTWeekDays(jsonDict: [:]),
            requiredWeekDays: People.PTWeekDays(jsonDict: [:]),
            limitOfRequiredWeekDays: 0,
            isSuper: false,
            maxWorkingCountInAMonth: 6,
            minWorkingCountInAMonth: 4))
        
        humans.append(People(context: coreDataManagement.managedObjectContext).updateParameters(
            NSDate(),
            name: "K",
            status: true,
            unavailableWeekDays: People.PTWeekDays(jsonDict: [:]),
            requiredWeekDays: People.PTWeekDays(jsonDict: [:]),
            limitOfRequiredWeekDays: 0,
            isSuper: false,
            maxWorkingCountInAMonth: 6,
            minWorkingCountInAMonth: 4))
        
        Records.saveContext(coreDataManagement.managedObjectContext)
        return humans
    }
    
    
}
