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
    
    func setData(number:Int, multiPeople:[People]){
        
        self.humanAPopUpButton.removeAllItems()
        self.humanBPopUpButton.removeAllItems()
        
        var displayedValuesForPopUpButton:[String] = []
        for people in multiPeople where people.status == true{
            if let name = people.name{
                displayedValuesForPopUpButton.append("\(name)")
            }
        }
        
        
        self.humanAPopUpButton.addItemWithTitle("-")
        self.humanBPopUpButton.addItemWithTitle("-")
        displayedValuesForPopUpButton.forEach { (item) -> () in
            self.humanAPopUpButton.addItemWithTitle(item)
            self.humanBPopUpButton.addItemWithTitle(item)
        }
        
        
        
        
        
        if number == -1{
            humanAPopUpButton.hidden = true
            humanBPopUpButton.hidden = true
            dayLabel.hidden = true
        }else{
            dayLabel.stringValue = String(number)
            humanAPopUpButton.hidden = false
            humanBPopUpButton.hidden = false
            dayLabel.hidden = false
        }
        
        
    }
    
    func popupSelected(item:NSMenuItem) {
        LogUtil.log()
        self.humanAPopUpButton.title = item.title
    }
    
}
