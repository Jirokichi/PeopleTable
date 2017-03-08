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
    private struct Constant{
        static let TableName = "People"
        
        static let AttributesDate = "createdDate"
    }
    
    /// protected - テーブル名を返す
    override class func _getTableName() -> String{
        return Constant.TableName
    }
    
    init(context:NSManagedObjectContext){
        super.init(tableName: Constant.TableName, context: context)
    }
    
    /// これを実装しておかないとエラーがおきる
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    
    func updateParameters(_ createdDate:Date, name:String, status:Bool, unavailableWeekDays:PTWeekDays, requiredWeekDays:PTWeekDays, limitOfRequiredWeekDays:Int, isSuper:Bool, maxWorkingCountInAMonth:Int, minWorkingCountInAMonth:Int, unavailableDays:String, requiredDays:String) -> People{
        self.createdDate = createdDate
        self.name = name
        self.status = status
        self.unavailableWeekDays = unavailableWeekDays.getJsonFromDict()
        self.requiredWeekDays = requiredWeekDays.getJsonFromDict()
        self.limitOfRequiredWeekDays = NSNumber(value: limitOfRequiredWeekDays)
        self.isSuper = isSuper
        self.maxWorkingCountInAMonth = NSNumber(value: maxWorkingCountInAMonth)
        self.minWorkingCountInAMonth = NSNumber(value: minWorkingCountInAMonth)
        self.unavailableDays = unavailableDays
        self.requiredDays = requiredDays
        
        return self
    }
    
    static func createSortDescriptor() -> NSSortDescriptor{
        let sortDescriptor = NSSortDescriptor(key: People.Constant.AttributesDate, ascending: true)
        return sortDescriptor
    }
    
    static func createDefaultPeoples(_ coreDataManagement:CoreDataManagement) -> [People]{
        var humans:[People] = []
        humans.append(People(context: coreDataManagement.managedObjectContext).updateParameters(
            Date(),
            name: "A",
            status: true,
            unavailableWeekDays: People.PTWeekDays(jsonDict: [WeekDay.sunday:true, WeekDay.monday:true]),
            requiredWeekDays: People.PTWeekDays(jsonDict: [:]),
            limitOfRequiredWeekDays: 0,
            isSuper: true,
            maxWorkingCountInAMonth: 6,
            minWorkingCountInAMonth: 4,
            unavailableDays: "1,4",
            requiredDays:"")
        )
        
        humans.append(People(context: coreDataManagement.managedObjectContext).updateParameters(
            Date(),
            name: "B",
            status: true,
            unavailableWeekDays: People.PTWeekDays(jsonDict: [WeekDay.tuesday:true, WeekDay.wednesday:true]),
            requiredWeekDays: People.PTWeekDays(jsonDict: [:]),
            limitOfRequiredWeekDays: 0,
            isSuper: true,
            maxWorkingCountInAMonth: 6,
            minWorkingCountInAMonth: 4,
            unavailableDays: "",
            requiredDays:""
            ))
        
        
        humans.append(People(context: coreDataManagement.managedObjectContext).updateParameters(
            Date(),
            name: "C",
            status: true,
            unavailableWeekDays: People.PTWeekDays(jsonDict: [WeekDay.tuesday:true , WeekDay.wednesday:true]),
            requiredWeekDays: People.PTWeekDays(jsonDict: [:]),
            limitOfRequiredWeekDays: 0,
            isSuper: true,
            maxWorkingCountInAMonth: 6,
            minWorkingCountInAMonth: 4,
            unavailableDays: "",
            requiredDays:""))
        
        humans.append(People(context: coreDataManagement.managedObjectContext).updateParameters(
            Date(),
            name: "D",
            status: true,
            unavailableWeekDays: People.PTWeekDays(jsonDict: [:]),
            requiredWeekDays: People.PTWeekDays(jsonDict: [:]),
            limitOfRequiredWeekDays: 0,
            isSuper: true,
            maxWorkingCountInAMonth: 6,
            minWorkingCountInAMonth: 4,
            unavailableDays: "",
            requiredDays:""))
        
        
        
        humans.append(People(context: coreDataManagement.managedObjectContext).updateParameters(
            Date(),
            name: "E",
            status: true,
            unavailableWeekDays: People.PTWeekDays(jsonDict: [:]),
            requiredWeekDays: People.PTWeekDays(jsonDict: [:]),
            limitOfRequiredWeekDays: 0,
            isSuper: true,
            maxWorkingCountInAMonth: 6,
            minWorkingCountInAMonth: 4,
            unavailableDays: "",
            requiredDays:""))
        
        humans.append(People(context: coreDataManagement.managedObjectContext).updateParameters(
            Date(),
            name: "F",
            status: true,
            unavailableWeekDays: People.PTWeekDays(jsonDict: [:]),
            requiredWeekDays: People.PTWeekDays(jsonDict: [:]),
            limitOfRequiredWeekDays: 0,
            isSuper: true,
            maxWorkingCountInAMonth: 6,
            minWorkingCountInAMonth: 4,
            unavailableDays: "",
            requiredDays:""))
        
        humans.append(People(context: coreDataManagement.managedObjectContext).updateParameters(
            Date(),
            name: "G",
            status: true,
            unavailableWeekDays: People.PTWeekDays(jsonDict: [:]),
            requiredWeekDays: People.PTWeekDays(jsonDict: [WeekDay.tuesday:true, WeekDay.thursday:true]),
            limitOfRequiredWeekDays: 2,
            isSuper: false,
            maxWorkingCountInAMonth: 6,
            minWorkingCountInAMonth: 4,
            unavailableDays: "",
            requiredDays:""))
        
        humans.append(People(context: coreDataManagement.managedObjectContext).updateParameters(
            Date(),
            name: "H",
            status: true,
            unavailableWeekDays: People.PTWeekDays(jsonDict: [:]),
            requiredWeekDays: People.PTWeekDays(jsonDict: [WeekDay.tuesday:true, WeekDay.thursday:true]),
            limitOfRequiredWeekDays: 2,
            isSuper: false,
            maxWorkingCountInAMonth: 6,
            minWorkingCountInAMonth: 4,
            unavailableDays: "",
            requiredDays:""))
        humans.append(People(context: coreDataManagement.managedObjectContext).updateParameters(
            Date(),
            name: "I",
            status: true,
            unavailableWeekDays: People.PTWeekDays(jsonDict: [:]),
            requiredWeekDays: People.PTWeekDays(jsonDict: [WeekDay.tuesday:true, WeekDay.thursday:true]),
            limitOfRequiredWeekDays: 2,
            isSuper: false,
            maxWorkingCountInAMonth: 6,
            minWorkingCountInAMonth: 4,
            unavailableDays: "",
            requiredDays:""))
        
        humans.append(People(context: coreDataManagement.managedObjectContext).updateParameters(
            Date(),
            name: "J",
            status: true,
            unavailableWeekDays: People.PTWeekDays(jsonDict: [:]),
            requiredWeekDays: People.PTWeekDays(jsonDict: [:]),
            limitOfRequiredWeekDays: 0,
            isSuper: false,
            maxWorkingCountInAMonth: 6,
            minWorkingCountInAMonth: 4,
            unavailableDays: "",
            requiredDays:""))
        
        humans.append(People(context: coreDataManagement.managedObjectContext).updateParameters(
            Date(),
            name: "K",
            status: true,
            unavailableWeekDays: People.PTWeekDays(jsonDict: [:]),
            requiredWeekDays: People.PTWeekDays(jsonDict: [:]),
            limitOfRequiredWeekDays: 0,
            isSuper: false,
            maxWorkingCountInAMonth: 6,
            minWorkingCountInAMonth: 4,
            unavailableDays: "",
            requiredDays:""))
        
        Records.saveContext(coreDataManagement.managedObjectContext)
        return humans
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
                case .sunday:
                    self = .Sun
                case .monday:
                    self = .Mon
                case .tuesday:
                    self = .Tue
                case .wednesday:
                    self = .Wed
                case .thursday:
                    self = .Thu
                case .friday:
                    self = .Fri
                case .saturday:
                    self = .Sat
                }
            }
            
            func getWeekDay() -> WeekDay{
                switch self{
                case .Sun:
                    return WeekDay.sunday
                case .Mon:
                    return WeekDay.monday
                case .Tue:
                    return WeekDay.tuesday
                case .Wed:
                    return WeekDay.wednesday
                case .Thu:
                    return WeekDay.thursday
                case .Fri:
                    return WeekDay.friday
                case .Sat:
                    return WeekDay.saturday
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
        
        mutating func updateJsonDict(_ weekDay:WeekDay){
            let alreadyMarked = self.jsonDict.contains(where: { (predicate:(weekDay:WeekDay, status:Bool)) -> Bool in
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
                let jsonData = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
                if let result = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue){
                    return result as String
                }
            }catch{
                LogUtil.log("Error")
            }
            return ""
        }
        
        /// DictionaryからJsonを作成する静的メソッド
        static func getDicsFromJson(_ str:String?) -> PTWeekDays?{
            if str == nil{
                return nil
            }
            // JSON -> Dict
            if let jsonData: Data = (str! as NSString).data(using: String.Encoding.utf8.rawValue){
                
                do{
                    if let jsonString = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : String]{
                        
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

    
}
