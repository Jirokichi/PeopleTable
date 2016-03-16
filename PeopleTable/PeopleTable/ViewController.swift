//
//  ViewController.swift
//  PeopleTable
//
//  Created by yuya on 2016/03/10.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    let daysInfo = [["A", "B", "C", "D", "E", "F", "G"],["A", "B", "C", "D", "E", "F", "G"],["A", "B", "C", "D", "E", "F", "G"],["A", "B", "C", "D", "E", "F", "G"],["A", "B", "C", "D", "E", "F", "G"]]
    @IBOutlet weak var monthTableView: NSTableView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        LogUtil.log("\(daysInfo.count)")
        return daysInfo.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return daysInfo[row][0]
    }
    
    
    

}

