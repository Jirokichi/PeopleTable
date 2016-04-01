//
//  Rules+CoreDataProperties.swift
//  PeopleTable
//
//  Created by yuya on 2016/03/31.
//  Copyright © 2016年 yuya. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Rules {

    @NSManaged var superUser: Bool
    @NSManaged var unavailableWeekDays: Bool
    @NSManaged var interval: Bool
    @NSManaged var unavailableDays: Bool
    @NSManaged var weekEnd: Bool
    @NSManaged var practice: Bool
    @NSManaged var countInMonth: Bool

}
