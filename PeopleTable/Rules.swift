//
//  Rules.swift
//  PeopleTable
//
//  Created by yuya on 2016/03/31.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Foundation
import CoreData


class Rules: Records {
    struct Constant{
        private static let TableName = "Rules"
        
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
    

    func updateParameters(superUser:Bool, unavailableWeekDays:Bool, interval:Bool, unavailableDays:Bool, weekEnd:Bool, practice:Bool, countInMonth:Bool) -> Rules{
        self.superUser = superUser
        self.unavailableWeekDays = unavailableWeekDays
        self.interval = interval
        self.unavailableDays = unavailableDays
        self.weekEnd = weekEnd
        self.practice = practice
        self.countInMonth = countInMonth
        
        return self
    }
}
