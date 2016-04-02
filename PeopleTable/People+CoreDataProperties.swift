//
//  People+CoreDataProperties.swift
//  PeopleTable
//
//  Created by yuya on 2016/03/13.
//  Copyright © 2016年 yuya. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension People {

    @NSManaged var createdDate: NSDate
    @NSManaged var name: String
    @NSManaged var unavailableWeekDays: String
    @NSManaged var requiredWeekDays: String
    @NSManaged var unavailableDays: String
    @NSManaged var forbittenDays:String
    @NSManaged var limitOfRequiredWeekDays:NSNumber
    @NSManaged var maxWorkingCountInAMonth:NSNumber
    @NSManaged var minWorkingCountInAMonth:NSNumber
    @NSManaged var status: Bool
    @NSManaged var isSuper: Bool

}
