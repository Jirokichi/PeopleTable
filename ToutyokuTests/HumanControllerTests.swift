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
            let controller = HumanController()
            
            print("ユーザー数:\(controller.humans.count)")
            controller.startCreatingRandomTable()
        }
    }

}
