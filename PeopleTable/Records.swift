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
        
        if let entity = NSEntityDescription.entity(forEntityName: tableName, in: context){
            super.init(entity: entity, insertInto: context)
        }else{
            fatalError("entity is Nothing for \(tableName) and context")
        }
    }
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    static func fetchAllRecords<T: NSManagedObject>(_ context:NSManagedObjectContext, sortDescriptor:NSSortDescriptor? = nil) throws -> [T]{
        var records:[T] = []
        
        let entityDiscription = NSEntityDescription.entity(forEntityName: self._getTableName(), in: context)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = entityDiscription
        
        if let sortDescriptor = sortDescriptor{
            fetchRequest.sortDescriptors = [sortDescriptor]
        }
        
        if let results = try context.fetch(fetchRequest) as? [T] {
            records = results
        }
        
        return records
    }
    
    /// すべてのレコードを削除する
    static func deleteAllRecords(_ context:NSManagedObjectContext) throws{
        let entityDiscription = NSEntityDescription.entity(forEntityName: _getTableName(), in: context)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = entityDiscription
        if let results = try context.fetch(fetchRequest) as? [Records] {
            for result in results{
                context.delete(result)
            }
            Records.saveContext(context)
        }
    }
    
    // 削除
    func delete(_ context:NSManagedObjectContext){
        context.delete(self)
        Records.saveContext(context)
    }
    
    
    /// サブクラスで実装される
    class func _getTableName() -> String{
        fatalError("This method should be overrided")
    }
    
    
    
    // コンテキストの変更点を保存するための関数
    static func saveContext (_ context:NSManagedObjectContext) {
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
