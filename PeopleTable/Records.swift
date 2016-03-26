//
//  Record.swift
//  PeopleTable
//
//  Created by yuya on 2016/03/12.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Foundation
import CoreData

class Records: NSManagedObject{
    
    init(tableName:String, context:NSManagedObjectContext){
        
        if let entity = NSEntityDescription.entityForName(tableName, inManagedObjectContext: context){
            super.init(entity: entity, insertIntoManagedObjectContext: context)
        }else{
            fatalError("entity is Nothing for \(tableName) and context")
        }
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    static func fetchAllRecords<T: NSManagedObject>(context:NSManagedObjectContext, sortDescriptor:NSSortDescriptor? = nil) throws -> [T]{
        var records:[T] = []
        
        let entityDiscription = NSEntityDescription.entityForName(self._getTableName(), inManagedObjectContext: context)
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entityDiscription
        
        if let sortDescriptor = sortDescriptor{
            fetchRequest.sortDescriptors = [sortDescriptor]
        }
        
        if let results = try context.executeFetchRequest(fetchRequest) as? [T] {
            records = results
        }
        
        return records
    }
    
    /// すべてのレコードを削除する
    static func deleteAllRecords(context:NSManagedObjectContext) throws{
        let entityDiscription = NSEntityDescription.entityForName(_getTableName(), inManagedObjectContext: context)
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entityDiscription
        if let results = try context.executeFetchRequest(fetchRequest) as? [Records] {
            for result in results{
                context.deleteObject(result)
            }
            Records.saveContext(context)
        }
    }
    
    // 削除
    func delete(context:NSManagedObjectContext){
        context.deleteObject(self)
        Records.saveContext(context)
    }
    
    
    /// サブクラスで実装される
    class func _getTableName() -> String{
        fatalError("This method should be overrided")
    }
    
    
    
    // コンテキストの変更点を保存するための関数
    static func saveContext (context:NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}