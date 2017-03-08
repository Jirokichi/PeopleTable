//
//  DayCollectionViewItem.swift
//  PeopleTable
//
//  Created by yuya on 2016/03/19.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Cocoa


protocol MyDayDelegate : NSObjectProtocol{
    func checkButton(_ day:Int, name:String, status:Bool, needSave:Bool)
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
    
    func setData(_ number:Int, workingPeople:[People], human:(A:String?, B:String?)? = nil, status:(A:Bool, B:Bool) = (false, false), dayDelegate:MyDayDelegate? = nil){
        
        self.dayDelegate = dayDelegate
        
        self.humanAPopUpButton.removeAllItems()
        self.humanBPopUpButton.removeAllItems()
        
        var displayedValuesForPopUpButton:[String] = []
        for people in workingPeople where people.status == true{
            displayedValuesForPopUpButton.append("\(people.name)")
        }
        
        self.humanAPopUpButton.addItem(withTitle: DayCollectionViewItem.NotSelectedStatus)
        self.humanBPopUpButton.addItem(withTitle: DayCollectionViewItem.NotSelectedStatus)
        displayedValuesForPopUpButton.forEach { (item) -> () in
            self.humanAPopUpButton.addItem(withTitle: item)
            self.humanBPopUpButton.addItem(withTitle: item)
        }
        
        if let humanAName = human?.A{
            self.humanAPopUpButton.selectItem(withTitle: humanAName)
            selectedHumanA = humanAName
        }
        if let humanBName = human?.B{
            self.humanBPopUpButton.selectItem(withTitle: humanBName)
            selectedHumanB = humanBName
        }
        
        if number == -1{
            humanAPopUpButton.isHidden = true
            humanBPopUpButton.isHidden = true
            dayLabel.isHidden = true
            humanAPopUpCheckBox.isHidden = true
            humanBPopUpCheckBox.isHidden = true
        }else{
            day = number
            dayLabel.stringValue = String(number)
            humanAPopUpButton.isHidden = false
            humanBPopUpButton.isHidden = false
            dayLabel.isHidden = false
            humanAPopUpCheckBox.isHidden = false
            humanBPopUpCheckBox.isHidden = false
            
            humanAPopUpCheckBox.state = status.A ? 1 : 0
            humanBPopUpCheckBox.state = status.B ? 1 : 0
        }
        
        
        humanAPopUpButton.selectedItem?.view?.layer?.backgroundColor = NSColor.yellow.cgColor
    }
    
    func popupSelected(_ item:NSMenuItem) {
        LogUtil.log()
        self.humanAPopUpButton.title = item.title
    }
    
    // *****************************************
    // MARK: - ポップアップメニューのアクション
    // *****************************************
    @IBAction func changedPopUpButtonA(_ sender: NSPopUpButton) {
        
        LogUtil.log("\(selectedHumanA) -> (\(sender.selectedItem?.title))")
        
        if let name = sender.selectedItem?.title{
            
            let status = humanAPopUpCheckBox.state == 1 ? true : false
            if self.handlePopUpButtonProcess(selectedHumanA, currentName: name, requiredStatus: status){
                selectedHumanA = name
            }
        }
    }
    
    @IBAction func changePopUoButtonB(_ sender: NSPopUpButton) {
        LogUtil.log("\(selectedHumanB) -> (\(sender.selectedItem?.title))")
        
        if let name = sender.selectedItem?.title{
            
            let status = humanBPopUpCheckBox.state == 1 ? true : false
            if self.handlePopUpButtonProcess(selectedHumanB, currentName: name, requiredStatus: status){
                selectedHumanB = name
            }
        }
        
    }
    
    private func handlePopUpButtonProcess(_ previousName:String, currentName:String, requiredStatus:Bool) -> Bool{
        
        // 削除
        self.dayDelegate?.checkButton(self.day, name: previousName, status: false, needSave: requiredStatus)
        
        // 追加
        self.dayDelegate?.checkButton(self.day, name: currentName, status: true, needSave: requiredStatus)
        
        
        // ポップアップボタンの変更
        return true
    }
    
    // *****************************************
    // MARK: - チェックボックスのアクション
    // *****************************************
    
    /// Aのためのチェックボックスのアクション
    @IBAction func checkHumanA(_ sender: NSButton) {
        self.handleCheckBoxProcess(humanAPopUpButton, button: sender)
    }
    
    
    /// Bのためのチェックボックスのアクション
    @IBAction func checkHumanB(_ sender: NSButton) {
        
        self.handleCheckBoxProcess(humanBPopUpButton, button: sender)
        
    }
    
    private func handleCheckBoxProcess(_ checkedPopUpButton:NSPopUpButton, button:NSButton){
        if let name = checkedPopUpButton.selectedItem?.title, name != DayCollectionViewItem.NotSelectedStatus{
            let status = button.state == 1 ? true : false
            self.dayDelegate?.checkButton(self.day, name: name, status: status, needSave: true)
        }else{
            button.state = 0
        }
    }
    
    
    
}
