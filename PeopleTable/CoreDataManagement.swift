
//
//  CoreDataManagement.swift
//  PeopleTable
//
//  Created by yuya on 2016/03/12.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Foundation
import Cocoa

/// /Users/yuya/Library/Application Support/jp.ky.PeopleTable
/// rm CocoaAppCD.storedata 
class CoreDataManagement{
    private static let XcdataModelName = "PeopleTable"
    private static let PackageName = "jp.ky.PeopleTable"
    static let Instance = CoreDataManagement()
    private init(){}
    
    
    
    lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupportURL = urls[urls.count - 1]
        return appSupportURL.appendingPathComponent(CoreDataManagement.PackageName)
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: CoreDataManagement.XcdataModelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let fileManager = FileManager.default
        var failError: NSError? = nil
        var shouldFail = false
        var failureReason = "There was an error creating or loading the application's saved data."
        
        // Make sure the application files directory is there
        do {
            let properties = try (self.applicationDocumentsDirectory as NSURL).resourceValues(forKeys: [URLResourceKey.isDirectoryKey])
            if !(properties[URLResourceKey.isDirectoryKey]! as AnyObject).boolValue {
                failureReason = "Expected a folder to store application data, found a file \(self.applicationDocumentsDirectory.path)."
                shouldFail = true
            }
        } catch  {
            let nserror = error as NSError
            if nserror.code == NSFileReadNoSuchFileError {
                do {
                    try fileManager.createDirectory(atPath: self.applicationDocumentsDirectory.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    failError = nserror
                }
            } else {
                failError = nserror
            }
        }
        
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = nil
        if failError == nil {
            coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            let url = self.applicationDocumentsDirectory.appendingPathComponent("CocoaAppCD.storedata")
            do {
                // optionsを追加
                let options = [NSMigratePersistentStoresAutomaticallyOption: true,NSInferMappingModelAutomaticallyOption: true]
                try coordinator!.addPersistentStore(ofType: NSXMLStoreType, configurationName: nil, at: url, options: options)
            } catch {
                failError = error as NSError
            }
        }
        
        if shouldFail || (failError != nil) {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            if failError != nil {
                dict[NSUnderlyingErrorKey] = failError
            }
            let error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSApplication.shared().presentError(error)
            abort()
        } else {
            return coordinator!
        }
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
}
