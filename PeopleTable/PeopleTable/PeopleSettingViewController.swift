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

    let coreDataManagement = CoreDataManagement.Instance
    
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
        case RequiredDays = "RequiredDays"
        case Unknow = "Unknown"
        
        init(tableId:String?){
            self = TableId(rawValue: (tableId ?? "")) ?? .Unknow
        }
    }
    
    deinit{
        LogUtil.log("設定終了")
        NotificationCenter.default.post(name: Notification.Name(rawValue: HomeViewController.NotificationCenter.ID), object: nil)
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
    
    @IBAction func deletePeople(_ sender: AnyObject) {
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
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "キャンセル")
        let result = alert.runModal()
        if (result == NSAlertFirstButtonReturn) {
            selectedPeople.delete(CoreDataManagement.Instance.managedObjectContext)
            loadPeopleFromDB()
        }
        
    }
    
    @IBAction func addNewPeople(_ sender: AnyObject) {
        
        LogUtil.log("addNewPeople")
        humans.append(People(context: coreDataManagement.managedObjectContext).updateParameters(
            Date(),
            name: "New",
            status: false,
            unavailableWeekDays: People.PTWeekDays(jsonDict: [:]),
            requiredWeekDays: People.PTWeekDays(jsonDict: [:]),
            limitOfRequiredWeekDays: 0,
            isSuper: false,
            maxWorkingCountInAMonth: 6,
            minWorkingCountInAMonth: 4,
            unavailableDays: "",
            requiredDays:""))
        Records.saveContext(coreDataManagement.managedObjectContext)
        
        tableView.reloadData()
    }
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        LogUtil.log("\(humans.count)")
        return humans.count
    }
    

    // セルに値をセットする際に呼び出される
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {

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
                
                if let cell = tableColumn?.dataCell(forRow: row) as? NSSegmentedCell{
                    
                    // Reset
                    for i in 0...(cell.segmentCount-2){
                        cell.setSelected(false, forSegment: i)
                    }
                    cell.setSelected(true, forSegment: (cell.segmentCount-1))
                    
                    var num = 0
                    for (weekDay, status) in json{
                        if status{
                            cell.setSelected(status, forSegment: weekDay.rawValue)
                            num += 1
                        }
                    }
                    
                    cell.setLabel("\(num)", forSegment: (cell.segmentCount-1))
                    cell.setEnabled(false, forSegment: (cell.segmentCount-1))
                    return cell
                }
            }
        case .RequiredWeekDays:
            
            if let json = People.PTWeekDays.getDicsFromJson(human.requiredWeekDays)?.jsonDict{
                if let cell = tableColumn?.dataCell(forRow: row) as? NSSegmentedCell{
                    
                    // Reset
                    for i in 0...(cell.segmentCount-2){
                        cell.setSelected(false, forSegment: i)
                    }
                    cell.setSelected(true, forSegment: (cell.segmentCount-1))
                    
                    var num = 0
                    for (weekDay, status) in json{
                        if status{
                            cell.setSelected(status, forSegment: weekDay.rawValue)
                            num += 1
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
        case .RequiredDays:
            return human.requiredDays
        case .Unknow:
            return ""
        }
        return ""
    }
    
    // セルの状態が変化したときに呼び出される
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int){
        
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
                if let limit = Int(object), limit >= 0{
                    human.limitOfRequiredWeekDays = NSNumber(value: limit)
                    Records.saveContext(coreDataManagement.managedObjectContext)
                }
            }
            break
        case .MaxWorkingCountInAMonth:
            
            LogUtil.log("MaxWorkingCountInAMonth - row:\(row) - (\(object))")
            
            if let object = object as? String{
                if let limit = Int(object), limit > 0{
                    human.maxWorkingCountInAMonth = NSNumber(value: limit)
                    Records.saveContext(coreDataManagement.managedObjectContext)
                }
            }
            break
        case .MinWorkingCountInAMonth:
            
            LogUtil.log("MinWorkingCountInAMonth - row:\(row) - (\(object))")
            
            if let object = object as? String{
                if let limit = Int(object), limit >= 0{
                    human.minWorkingCountInAMonth = NSNumber(value: limit)
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
        case .RequiredDays:
            
            LogUtil.log("RequiredDays - row:\(row) - (\(object))")
            
            if let requiredDays = object as? String{
                
                if self.checkUnavailableDaysFormat(requiredDays) || requiredDays == ""{
                    human.requiredDays = requiredDays
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
    
    func checkUnavailableDaysFormat(_ unavailableDays:String) -> Bool{
        var result = true
        let str = unavailableDays as NSString
        var nums:[Int] = []
        for numStr in str.components(separatedBy: ","){
            var lNumStr = numStr
            if lNumStr.contains(" "){
                lNumStr = lNumStr.trimmingCharacters(in: CharacterSet.whitespaces)
            }
            if let num = Int(lNumStr), num > 0 && num < 32{
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
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool{
        LogUtil.log()
        return true
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        LogUtil.log("セル選択時に呼ばれるメソッド-使わない予定")
        
    }
    
}
