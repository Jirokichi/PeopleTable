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
    
    
    func updateParameters(createdDate:NSDate, name:String, status:Bool) -> People{
        self.createdDate = createdDate
        self.name = name
        self.status = status
        
        return self
    }
    
    static func createSortDescriptor() -> NSSortDescriptor{
        let sortDescriptor = NSSortDescriptor(key: People.Constant.AttributesDate, ascending: true)
        return sortDescriptor
    }
    
    
}
