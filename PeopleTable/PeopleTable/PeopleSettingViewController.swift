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
        case PeopleCheckBox = "PeopleCheckBox"
        case Unknow
        
        init(tableId:String?){
            self = TableId(rawValue: (tableId ?? "")) ?? Unknow
        }
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
                
                humans.append(People(context: coreDataManagement.managedObjectContext).updateParameters(NSDate(), name: "A", status: false))
                humans.append(People(context: coreDataManagement.managedObjectContext).updateParameters(NSDate(), name: "B", status: false))
                
                Records.saveContext(coreDataManagement.managedObjectContext)
                
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
        humans.append(People(context: coreDataManagement.managedObjectContext).updateParameters(NSDate(), name: "New", status: false))
        Records.saveContext(coreDataManagement.managedObjectContext)
        
        tableView.reloadData()
    }
    
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        LogUtil.log("\(humans.count)")
        return humans.count
    }
    

    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        switch TableId(tableId: tableColumn?.identifier){
        case .PeopleId:
            return "\(row + 1)"
        case .PeopleName:
            return humans[row].name
        case .PeopleCheckBox:
            return humans[row].status
        case .Unknow:
            return ""
        }
    }
    
    func tableView(tableView: NSTableView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, row: Int){
        
        switch TableId(tableId: tableColumn?.identifier){
        case .PeopleName:
            LogUtil.log("PeopleName - row:\(row) - (\(object))")
            if let name = object as? String{
                humans[row].name = name
                Records.saveContext(coreDataManagement.managedObjectContext)
            }
            break
        case .PeopleCheckBox:
            LogUtil.log("PeopleCheckBox - row:\(row) - (\(object))")
            if let status = object as? Bool{
                humans[row].status = status
                Records.saveContext(coreDataManagement.managedObjectContext)
            }
            break
            
        default:
            break
        }
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
        
//        // Swiftの場合
//        let alert = NSAlert()
//        alert.messageText = "削除してもよろしいですか？"
//        //        alert.informativeText = "名前を入力してください"
//        alert.addButtonWithTitle("OK")
//        alert.addButtonWithTitle("キャンセル")
//        let result = alert.runModal()
//        if (result == NSAlertFirstButtonReturn) {
//            LogUtil.log("OK")
//            
//            let clikcedIndex = self.tableView?.clickedRow
//            LogUtil.log(clikcedIndex)
//            LogUtil.log(self.tableView?.selectedRow)
//            
//        }
        
        
    }
    
}
