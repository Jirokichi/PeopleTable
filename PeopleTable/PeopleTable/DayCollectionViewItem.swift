//
//  DayCollectionViewItem.swift
//  PeopleTable
//
//  Created by yuya on 2016/03/19.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Cocoa


protocol MyDayDelegate : NSObjectProtocol{
    func checkButton(day:Int, name:String, status:Bool)
}

class DayCollectionViewItem: NSCollectionViewItem {

    static let NotSelectedStatus = "-"
    static let XibName = "DayCollectionItem"
    
    @IBOutlet weak var humanAPopUpButton: NSPopUpButton!
    @IBOutlet weak var humanAPopUpCheckBox: NSButton!
    
    @IBOutlet weak var humanBPopUpButton: NSPopUpButton!
    @IBOutlet weak var humanBPopUpCheckBox: NSButton!
    
    @IBOutlet weak var dayLabel: NSTextField!
    
    private var selectedHumanA = DayCollectionViewItem.NotSelectedStatus
    private var selectedHumanB = DayCollectionViewItem.NotSelectedStatus
    
    private var day = -1
    
    weak var dayDelegate:MyDayDelegate?
    deinit{
        LogUtil.log("\(day)")
        dayDelegate = nil
    }
    
    override func loadView() {
        super.loadView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setData(number:Int, workingPeople:[People], human:(A:String?, B:String?)? = nil, status:(A:Bool, B:Bool) = (false, false), dayDelegate:MyDayDelegate? = nil){
        
        self.dayDelegate = dayDelegate
        
        self.humanAPopUpButton.removeAllItems()
        self.humanBPopUpButton.removeAllItems()
        
        var displayedValuesForPopUpButton:[String] = []
        for people in workingPeople where people.status == true{
            displayedValuesForPopUpButton.append("\(people.name)")
        }
        
        self.humanAPopUpButton.addItemWithTitle(DayCollectionViewItem.NotSelectedStatus)
        self.humanBPopUpButton.addItemWithTitle(DayCollectionViewItem.NotSelectedStatus)
        displayedValuesForPopUpButton.forEach { (item) -> () in
            self.humanAPopUpButton.addItemWithTitle(item)
            self.humanBPopUpButton.addItemWithTitle(item)
        }
        
        if let humanAName = human?.A{
            self.humanAPopUpButton.selectItemWithTitle(humanAName)
            selectedHumanA = humanAName
        }
        if let humanBName = human?.B{
            self.humanBPopUpButton.selectItemWithTitle(humanBName)
            selectedHumanB = humanBName
        }
        
        if number == -1{
            humanAPopUpButton.hidden = true
            humanBPopUpButton.hidden = true
            dayLabel.hidden = true
            humanAPopUpCheckBox.hidden = true
            humanBPopUpCheckBox.hidden = true
        }else{
            day = number
            dayLabel.stringValue = String(number)
            humanAPopUpButton.hidden = false
            humanBPopUpButton.hidden = false
            dayLabel.hidden = false
            humanAPopUpCheckBox.hidden = false
            humanBPopUpCheckBox.hidden = false
            
            humanAPopUpCheckBox.state = status.A ? 1 : 0
            humanBPopUpCheckBox.state = status.B ? 1 : 0
        }
        
        
    }
    
    func popupSelected(item:NSMenuItem) {
        LogUtil.log()
        self.humanAPopUpButton.title = item.title
    }
    
    // *****************************************
    // MARK: - ポップアップメニューのアクション
    // *****************************************
    @IBAction func changedPopUpButtonA(sender: NSPopUpButton) {
        
        LogUtil.log("\(selectedHumanA) -> (\(sender.selectedItem?.title))")
        
        if let name = sender.selectedItem?.title{
            
            let status = humanAPopUpCheckBox.state == 1 ? true : false
            if self.handlePopUpButtonProcess(selectedHumanA, currentName: name, requiredStatus: status){
                selectedHumanA = name
            }
        }
    }
    
    @IBAction func changePopUoButtonB(sender: NSPopUpButton) {
        LogUtil.log("\(selectedHumanB) -> (\(sender.selectedItem?.title))")
        
        if let name = sender.selectedItem?.title{
            
            let status = humanBPopUpCheckBox.state == 1 ? true : false
            if self.handlePopUpButtonProcess(selectedHumanB, currentName: name, requiredStatus: status){
                selectedHumanB = name
            }
        }
        
    }
    
    private func handlePopUpButtonProcess(previousName:String, currentName:String, requiredStatus:Bool) -> Bool{
        
        
        
        if requiredStatus{
            // 固定日のため、DBを更新する必要がある
            
            // 削除
            self.dayDelegate?.checkButton(self.day, name: previousName, status: false)
            
            // 追加
            self.dayDelegate?.checkButton(self.day, name: currentName, status: true)
        }
        
        // ポップアップボタンの変更
        return true
    }
    
    // *****************************************
    // MARK: - チェックボックスのアクション
    // *****************************************
    
    /// Aのためのチェックボックスのアクション
    @IBAction func checkHumanA(sender: NSButton) {
        self.handleCheckBoxProcess(humanAPopUpButton, button: sender)
    }
    
    
    /// Bのためのチェックボックスのアクション
    @IBAction func checkHumanB(sender: NSButton) {
        
        self.handleCheckBoxProcess(humanBPopUpButton, button: sender)
        
    }
    
    private func handleCheckBoxProcess(checkedPopUpButton:NSPopUpButton, button:NSButton){
        if let name = checkedPopUpButton.selectedItem?.title where name != DayCollectionViewItem.NotSelectedStatus{
            let status = button.state == 1 ? true : false
            self.dayDelegate?.checkButton(self.day, name: name, status: status)
        }else{
            button.state = 0
        }
    }
    
    
    
}
