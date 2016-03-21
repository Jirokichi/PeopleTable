//
//  DayCollectionViewItem.swift
//  PeopleTable
//
//  Created by yuya on 2016/03/19.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Cocoa

class DayCollectionViewItem: NSCollectionViewItem {

    static let StoryBoardId = "DayCollectionItem"
    
    @IBOutlet weak var humanAPopUpButton: NSPopUpButton!
    
    @IBOutlet weak var humanBPopUpButton: NSPopUpButton!
    
    @IBOutlet weak var dayLabel: NSTextField!
    
    override func loadView() {
        super.loadView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        LogUtil.log("viewDidLoad - " + dayLabel.stringValue)
    }
    
    func setData(number:String){
        dayLabel.stringValue = number
    }
    
}
