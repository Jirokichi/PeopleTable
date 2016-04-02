//
//  PeopleSettingViewController.swift
//  PeopleTable
//
//  Created by yuya on 2016/03/10.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Cocoa

class PeopleSettingViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSMenuDelegate {

    @IBOutlet weak var tableView: PeopleTableView!

    let coreDataManagement = CoreDataManagement.Singleton
    
    enum TableId:String{
        case PeopleId = "PeopleId"
        case PeopleName = "PeopleName"
        case SuperCheckBox = "SuperCheckBox"
        case PeopleCheckBox = "PeopleCheckBox"
        case PeopleUnavableWeekDays = "PeopleUnavableWeekDays"
        case RequiredWeekDays = "RequiredWeekDays"
        case LimitOfRequiredWeekDays = "LimitOfRequiredWeekDays"
        case MaxWorkingCountInAMonth = "MaxWorkingCountInAMonth"
        case MinWorkingCountInAMonth = "MinWorkingCountInAMonth"
        case UnavailableDays = "UnavailableDays"
        case Unknow
        
        init(tableId:String?){
            self = TableId(rawValue: (tableId ?? "")) ?? Unknow
        }
    }
    
    deinit{
        LogUtil.log("設定終了")
        NSNotificationCenter.defaultCenter().postNotificationName(HomeViewController.NotificationCenter.ID, object: nil)
    }
    
    
    struct SegmentedControlId{
        static let Sum = 7
    }
    
    var humans:[People] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LogUtil.log("test")

        loadPeopleFromDB()
    }
    
    
    private func loadPeopleFromDB(){
        do{
            humans.removeAll()
            humans =  try People.fetchAllRecords(coreDataManagement.managedObjectContext, sortDescriptor: People.createSortDescriptor())
            
            if humans.count < 1{
                humans = People.createDefaultPeoples(coreDataManagement)
            }
            tableView.reloadData()
        }catch{
            
        }
    }
    
    @IBAction func deletePeople(sender: AnyObject) {
        let index = self.tableView.clickedRow
        let selectedPeople:People
        if index < self.humans.count && index > 0{
            selectedPeople = self.humans[index]
        }else{
            return
        }
        
        let alert = NSAlert()
        alert.messageText = "削除してもよろしいですか？"
        alert.informativeText = "名前を入力してください"
        alert.addButtonWithTitle("OK")
        alert.addButtonWithTitle("キャンセル")
        let result = alert.runModal()
        if (result == NSAlertFirstButtonReturn) {
            selectedPeople.delete(CoreDataManagement.Singleton.managedObjectContext)
            loadPeopleFromDB()
        }
        
    }
    
    @IBAction func addNewPeople(sender: AnyObject) {
        
        LogUtil.log("addNewPeople")
        humans.append(People(context: coreDataManagement.managedObjectContext).updateParameters(
            NSDate(),
            name: "New",
            status: false,
            unavailableWeekDays: People.PTWeekDays(jsonDict: [:]),
            requiredWeekDays: People.PTWeekDays(jsonDict: [:]),
            limitOfRequiredWeekDays: 0,
            isSuper: false,
            maxWorkingCountInAMonth: 6,
            minWorkingCountInAMonth: 4,
            unavailableDays: ""))
        Records.saveContext(coreDataManagement.managedObjectContext)
        
        tableView.reloadData()
    }
    
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        LogUtil.log("\(humans.count)")
        return humans.count
    }
    

    // セルに値をセットする際に呼び出される
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        
        let human = humans[row]
        switch TableId(tableId: tableColumn?.identifier){
        case .PeopleId:
            return "\(row + 1)"
        case .PeopleName:
            return human.name
        case .SuperCheckBox:
            return human.isSuper
        case .PeopleCheckBox:
            return human.status
        case .PeopleUnavableWeekDays:
            
            if let json = People.PTWeekDays.getDicsFromJson(human.unavailableWeekDays)?.jsonDict{
                if let cell = tableColumn?.dataCell as? NSSegmentedCell{
                    
                    // Reset
                    for i in 0...(cell.segmentCount-2){
                        cell.setSelected(false, forSegment: i)
                    }
                    cell.setSelected(true, forSegment: (cell.segmentCount-1))
                    
                    var num = 0
                    for (weekDay, status) in json{
                        if status{
                            cell.setSelected(status, forSegment: weekDay.rawValue)
                            num++
                        }
                    }
                    
                    cell.setLabel("\(num)", forSegment: (cell.segmentCount-1))
                    cell.setEnabled(false, forSegment: (cell.segmentCount-1))
                    return cell
                }
            }
        case .RequiredWeekDays:
            
            if let json = People.PTWeekDays.getDicsFromJson(human.requiredWeekDays)?.jsonDict{
                if let cell = tableColumn?.dataCell as? NSSegmentedCell{
                    
                    // Reset
                    for i in 0...(cell.segmentCount-2){
                        cell.setSelected(false, forSegment: i)
                    }
                    cell.setSelected(true, forSegment: (cell.segmentCount-1))
                    
                    var num = 0
                    for (weekDay, status) in json{
                        if status{
                            cell.setSelected(status, forSegment: weekDay.rawValue)
                            num++
                        }
                    }
                    
                    cell.setLabel("\(num)", forSegment: (cell.segmentCount-1))
                    cell.setEnabled(false, forSegment: (cell.segmentCount-1))
                    return cell
                }
            }
        case .LimitOfRequiredWeekDays:
            return human.limitOfRequiredWeekDays
        case .MaxWorkingCountInAMonth:
            return human.maxWorkingCountInAMonth
        case .MinWorkingCountInAMonth:
            return human.minWorkingCountInAMonth
        case .UnavailableDays:
            return human.unavailableDays
        case .Unknow:
            return ""
        }
        return ""
    }
    
    // セルの状態が変化したときに呼び出される
    func tableView(tableView: NSTableView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, row: Int){
        
        let human = humans[row]
        switch TableId(tableId: tableColumn?.identifier){
        case .PeopleName:
            LogUtil.log("PeopleName - row:\(row) - (\(object))")
            if let name = object as? String{
                human.name = name
                Records.saveContext(coreDataManagement.managedObjectContext)
            }
            break
            
        case .SuperCheckBox:
            LogUtil.log("SuperCheckBox - row:\(row) - (\(object))")
            if let isSuper = object as? Bool{
                human.isSuper = isSuper
                Records.saveContext(coreDataManagement.managedObjectContext)
            }
        case .PeopleCheckBox:
            LogUtil.log("PeopleCheckBox - row:\(row) - (\(object))")
            if let status = object as? Bool{
                human.status = status
                Records.saveContext(coreDataManagement.managedObjectContext)
            }
            break
            
        case .PeopleUnavableWeekDays:
            LogUtil.log("PeopleUnavableWeekDays - row:\(row) - (\(object))")
            if let selectedSement = object as? Int{
                // まとめ用のボタンの変更なら無視する
                if selectedSement == SegmentedControlId.Sum{
                    return
                }
                
                let jsonWeekDaysStatus = human.unavailableWeekDays
                /// jsonでは処理ができないためUnavailableWeekDays@Structに変換する
                var dicWeekDaysStatus = People.PTWeekDays.getDicsFromJson(jsonWeekDaysStatus)
                
                // ステータスが変換される曜日を取得
                if let weekDay = WeekDay(rawValue: selectedSement){
                    
                    // 反転(true/false)が必要な曜日のためにdicWeekDaysStatusを更新する
                    dicWeekDaysStatus?.updateJsonDict(weekDay)
                    
                    if let unailableWeekDays = dicWeekDaysStatus?.getJsonFromDict(){
                        human.unavailableWeekDays = unailableWeekDays
                        Records.saveContext(coreDataManagement.managedObjectContext)
                    }
                    
                }
                
            }
        case .RequiredWeekDays:
            LogUtil.log("RequiredWeekDays - row:\(row) - (\(object))")
            if let selectedSement = object as? Int{
                // まとめ用のボタンの変更なら無視する
                if selectedSement == SegmentedControlId.Sum{
                    return
                }
                
                let jsonWeekDaysStatus = human.requiredWeekDays
                /// jsonでは処理ができないためRequiredWeekDays@Structに変換する
                var dicWeekDaysStatus = People.PTWeekDays.getDicsFromJson(jsonWeekDaysStatus)
                
                // ステータスが変換される曜日を取得
                if let weekDay = WeekDay(rawValue: selectedSement){
                    
                    // 反転(true/false)が必要な曜日のためにdicWeekDaysStatusを更新する
                    dicWeekDaysStatus?.updateJsonDict(weekDay)
                    
                    human.requiredWeekDays = dicWeekDaysStatus?.getJsonFromDict() ?? ""
                    Records.saveContext(coreDataManagement.managedObjectContext)
                    
                }
                
            }
            
        case .LimitOfRequiredWeekDays:
            
            LogUtil.log("LimitOfRequiredWeekDays - row:\(row) - (\(object))")
            
            if let object = object as? String{
                if let limit = Int(object) where limit >= 0{
                    human.limitOfRequiredWeekDays = limit
                    Records.saveContext(coreDataManagement.managedObjectContext)
                }
            }
            break
        case .MaxWorkingCountInAMonth:
            
            LogUtil.log("MaxWorkingCountInAMonth - row:\(row) - (\(object))")
            
            if let object = object as? String{
                if let limit = Int(object) where limit > 0{
                    human.maxWorkingCountInAMonth = limit
                    Records.saveContext(coreDataManagement.managedObjectContext)
                }
            }
            break
        case .MinWorkingCountInAMonth:
            
            LogUtil.log("MinWorkingCountInAMonth - row:\(row) - (\(object))")
            
            if let object = object as? String{
                if let limit = Int(object) where limit >= 0{
                    human.minWorkingCountInAMonth = limit
                    Records.saveContext(coreDataManagement.managedObjectContext)
                }
            }
            break
            
        case .UnavailableDays:
            
            LogUtil.log("UnavailableDays - row:\(row) - (\(object))")
            
            if let unavailableDays = object as? String{
                
                if self.checkUnavailableDaysFormat(unavailableDays) || unavailableDays == ""{
                    human.unavailableDays = unavailableDays
                    Records.saveContext(coreDataManagement.managedObjectContext)
                }else
                {
                    DialogUtil.startDialog("フォーマットエラー", message: "数字は1-31のみです。また、半角の「,」(カンマ)で区切る必要があります。手抜きましたすみません。", onClickOKButton: { () -> () in
                        
                    })
                }
                
            }
            
            default:
            break
        }
    }
    
    func checkUnavailableDaysFormat(unavailableDays:String) -> Bool{
        var result = true
        let str = unavailableDays as NSString
        var nums:[Int] = []
        for numStr in str.componentsSeparatedByString(","){
            var lNumStr = numStr
            if lNumStr.containsString(" "){
                lNumStr = lNumStr.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            }
            if let num = Int(lNumStr) where num > 0 && num < 32{
                nums.append(num)
            }else{
                result = false
            }
        }
        
        return result
    }
    
//    func tableView(tableView: NSTableView, rowActionsForRow row: Int, edge: NSTableRowActionEdge) -> [NSTableViewRowAction]{
//        
//    }
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool{
        LogUtil.log()
        return true
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        LogUtil.log("セル選択時に呼ばれるメソッド-使わない予定")
        
    }
    
}
