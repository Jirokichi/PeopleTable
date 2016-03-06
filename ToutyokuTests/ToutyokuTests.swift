//
//  ToutyokuTests.swift
//  ToutyokuTests
//
//  Created by yuya on 2016/03/01.
//  Copyright © 2016年 yuya. All rights reserved.
//

import XCTest
@testable import Toutyoku
class ToutyokuTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPerformanceHumanController() {
        self.measureBlock {
            let controller = HumanController()
            
            print("ユーザー数:\(controller.humans.count)")
            controller.startCreatingRandomTable()
        }
    }
    
}
