//
//  PeopleTests.swift
//  PeopleTable
//
//  Created by yuya on 2016/03/12.
//  Copyright © 2016年 yuya. All rights reserved.
//

import XCTest
@testable import PeopleTable

class PeopleTests: XCTestCase {

    let coreData = CoreDataManagement.Singleton
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        
        try! People.deleteAllRecords(coreData.managedObjectContext)
        
        
        let originalPeoples = [People(context: coreData.managedObjectContext), People(context: coreData.managedObjectContext)]
        originalPeoples[0].createdDate = NSDate()
        originalPeoples[0].name = "木田裕也"
        originalPeoples[0].status = true
        
        originalPeoples[1].createdDate = NSDate()
        originalPeoples[1].name = "木田じろきち"
        originalPeoples[1].status = false
        
        Records.saveContext(coreData.managedObjectContext)
        
        let peoples:[People] = try! People.fetchAllRecords(coreData.managedObjectContext)
        LogUtil.log("Fetch:\(peoples.count)")
        XCTAssertEqual(peoples.count, 2)
        
        for originalPeople in originalPeoples{
            XCTAssert(peoples.contains { (people) -> Bool in
                
                var result = true
                result = (people.createdDate == originalPeople.createdDate)
                result = (people.name == originalPeople.name)
                result = (people.status == originalPeople.status)
                
                return result
                })
            
        }
    }
    
    func testDeletion(){
        try! People.deleteAllRecords(coreData.managedObjectContext)
    }
}
