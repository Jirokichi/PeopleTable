//
//  MonthTableTests.swift
//  Toutyoku
//
//  Created by yuya on 2016/03/03.
//  Copyright © 2016年 yuya. All rights reserved.
//

import XCTest

class HumanControllerTests: XCTestCase {


    func testPerformanceHumanController() {
        self.measureBlock {
            let humans = [
                Human(id:0, name: "A", unableWeekDays: [.Sunday, .Monday], isSuper:true, practiceRule: (mustWeekDays: [], max: 0), maxWorkingCountInAMonth:6, minWorkingCountInAMonth:4),
                Human(id:1, name: "B", unableWeekDays: [.Tuesday, .Thursday], isSuper:true, practiceRule: (mustWeekDays: [], max: 0), maxWorkingCountInAMonth:6, minWorkingCountInAMonth:4),
                Human(id:2, name: "C", unableWeekDays: [.Tuesday, .Wednesday], isSuper:true, practiceRule: (mustWeekDays: [], max: 0), maxWorkingCountInAMonth:6, minWorkingCountInAMonth:4),
                Human(id:3, name: "D", unableWeekDays: [], isSuper:true, practiceRule: (mustWeekDays: [], max: 0), maxWorkingCountInAMonth:6, minWorkingCountInAMonth:4),
                Human(id:4, name: "E", unableWeekDays: [], isSuper:true, practiceRule: (mustWeekDays: [], max: 0), maxWorkingCountInAMonth:6, minWorkingCountInAMonth:4),
                Human(id:5, name: "F", unableWeekDays: [], isSuper:true, practiceRule: (mustWeekDays: [], max: 0), maxWorkingCountInAMonth:6, minWorkingCountInAMonth:4),
                Human(id:6, name: "G", unableWeekDays: [], isSuper:false, practiceRule: (mustWeekDays: [.Tuesday, .Thursday], max: 2), maxWorkingCountInAMonth:6, minWorkingCountInAMonth:4),
                Human(id:7, name: "H", unableWeekDays: [], isSuper:false, practiceRule: (mustWeekDays: [.Tuesday, .Thursday], max: 2), maxWorkingCountInAMonth:6, minWorkingCountInAMonth:4),
                Human(id:8, name: "I", unableWeekDays: [], isSuper:false, practiceRule: (mustWeekDays: [.Tuesday, .Thursday], max: 2), maxWorkingCountInAMonth:6, minWorkingCountInAMonth:4),
                Human(id:9, name: "J", unableWeekDays: [], isSuper:false, practiceRule: (mustWeekDays: [], max: 0), maxWorkingCountInAMonth:6, minWorkingCountInAMonth:4),
                Human(id:10, name: "K", unableWeekDays: [], isSuper: false, practiceRule: (mustWeekDays: [], max: 0), maxWorkingCountInAMonth:6, minWorkingCountInAMonth:4)
            ]
            
            let controller = HumanController(humans: humans)
            
            print("ユーザー数:\(controller.humans.count)")
            controller.startCreatingRandomTable(NSDate())
        }
    }

}
