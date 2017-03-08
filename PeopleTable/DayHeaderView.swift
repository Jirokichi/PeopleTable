//
//  DayHeaderView.swift
//  PeopleTable
//
//  Created by yuya on 2016/03/23.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Cocoa

class DayHeaderView: NSView{

    @IBOutlet weak var datePicker: NSDatePicker!
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        LogUtil.log()
        // Drawing code here.
    }
    
    func setComponent(date:Date, delegate:NSDatePickerCellDelegate){
        datePicker.dateValue = date
        datePicker.delegate = delegate
    }
    
    deinit{
        LogUtil.log()
    }
}
