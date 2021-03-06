//
//  ViewController.swift
//  PeopleTable
//
//  Created by yuya on 2016/03/10.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Cocoa

class HomeViewController: NSViewController, NSCollectionViewDataSource, NSCollectionViewDelegate, NSDatePickerCellDelegate, MyDayDelegate{

    struct NotificationCenter{
        static let ID = "UpadeSettingInfo"
    }
    
    struct UserDefaultKey{
        static let Memo = "MEMO"
    }
    
    static let BackGroundColor = NSColor.white.cgColor
 
    // MARK: - 変数 >> ストーリーボードと関連付けらている
    @IBOutlet weak var headerView: DayHeaderView!
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var resultTextField: NSTextField!
    @IBOutlet var memoTextView: NSTextView!
    
    @IBOutlet weak var markedPeoplePopUpButton: NSPopUpButton!
    
    //ルールのチェックボックス
    @IBOutlet weak var checkBoxForSuper: NSButton!
    @IBOutlet weak var checkBoxForUnavailableWeekDays: NSButton!
    @IBOutlet weak var checkBoxForInterval: NSButton!
    @IBOutlet weak var checkBoxForUnavailableDays: NSButton!
    
    @IBOutlet weak var checkBoxForWeekEnd: NSButton!
    @IBOutlet weak var checkBoxForPractice: NSButton!
    @IBOutlet weak var checkBoxForCountInMonth: NSButton!

    @IBOutlet weak var startButton: NSButton!
    
    
    // MARK: - 変数 >> 対象の月情報
    private struct TargetMonthInfo{
        var targetMonth:Date = Date()
        var firstDayInAMonth:DateComponents = DateComponents()
        var lastDayInAMonth:DateComponents = DateComponents()
        
        mutating func update(_ newTargetMonth:Date){
            self.targetMonth = newTargetMonth
            self.firstDayInAMonth = DateUtil.getFirstDay(self.targetMonth)
            self.lastDayInAMonth = DateUtil.getLastDay(self.targetMonth)
        }
    }
    private var targetMonthInfo:TargetMonthInfo = TargetMonthInfo()
    
    // MARK: - 変数 >> CoreData情報
    let coreDataManagement = CoreDataManagement.Instance
    var workingPeople:[People] = []
    var rule:Rules?
    
    
    // MARK: - 変数 >> 当番表作成クラスで利用する
    var table:MonthTable? = nil
    /// 当番表作成中フラグ
    var runningTable = false;
    
    
    // MARK: - ライフサイクルの処理
    deinit{
        LogUtil.log("finish")
        Foundation.NotificationCenter.default.removeObserver(self)
        collectionView.dataSource = nil
        collectionView.delegate = nil
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        LogUtil.log("memoTextView:\(memoTextView.string)")
        // 「ud」というインスタンスをつくる。
        let ud = UserDefaults.standard
        ud.set(memoTextView.string ?? "", forKey:UserDefaultKey.Memo)}
    
    override func viewWillAppear() {
        super.viewWillAppear()
        LogUtil.log()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let ud = UserDefaults.standard
        let memoText = ud.object(forKey: UserDefaultKey.Memo) as? String
        self.memoTextView?.string = memoText ?? ""
        
        // 今月の最終日の取得
        self.updateMonthData(Date())
        
        do{
            try self.updateRules()
        }catch{
            LogUtil.log("担当者情報のフェッチに失敗しました。チェックボックスの更新も失敗しています。アプリ開発者に問い合わせてください。")
        }
        headerView.setComponent(date: self.targetMonthInfo.targetMonth, delegate: self)
        headerView.wantsLayer = true
        headerView.layer?.backgroundColor = HomeViewController.BackGroundColor
        headerView.layer?.borderWidth = 1
        headerView.layer?.borderWidth = 1
        
        
        table = self.createCurrentTableFromDB()
        
        
        Foundation.NotificationCenter.default.addObserver(self, selector: HomeViewController.UpdateSettingInfo, name: NSNotification.Name(rawValue: NotificationCenter.ID), object: nil)
    }
    
    // MARK: - 更新処理
    /// テーブルの初期化(NotificationCenterで呼び出される)
    private static let UpdateSettingInfo:Selector = #selector(HomeViewController.updateSettingInfo(_:))
    func updateSettingInfo(_ notification:Notification?){
        LogUtil.log()
        DialogUtil.startDialog("警告", message: "設定が変更されました。一度結果をリセットしてもよろしいでしょうか？") { () -> () in
            self.updateTable()
        }
    }
    
    // テーブルの更新
    private func updateTable(){
        // テーブルの更新と人設定
        LogUtil.log()
        do{
            try self.upatePeoples()
            self.table = self.createCurrentTableFromDB()
            self.collectionView.reloadData()
        }catch{
            LogUtil.log("Error")
        }
    }
    
    /// 日付情報の更新 - テーブルは初期化されます
    private func updateMonthData(_ day:Date){
        self.targetMonthInfo.update(day)
        self.updateTable()
    }
    
    /// CoreDataから人を取得（一人もいなければデフォルトを作成）してきて、現在の情報(各人の月の稼働日数や曜日ごとの稼働日数)を出力する
    func upatePeoples() throws{
        workingPeople.removeAll()
        workingPeople =  try People.fetchAllRecords(coreDataManagement.managedObjectContext, sortDescriptor: People.createSortDescriptor())
        
        if workingPeople.count < 1{
            workingPeople = People.createDefaultPeoples(coreDataManagement)
        }
        
        self.markedPeoplePopUpButton?.removeAllItems()
        for people in workingPeople where people.status == true{
            self.markedPeoplePopUpButton?.addItem(withTitle: people.name)
        }
        
        
        
        self.updateResultText()
    }
    
    private func updateResultText(){
        var result:String = "----------------------------------"
        result = result + "\n" + "名前(合計): 月/火/水/木/金/土/日"
        if let table = self.table{
            for people in workingPeople{
                var peopleInfo = people.name
                let weekDaysInfo:[WeekDay:Int] = table.numberOfSpecificWeekDayInAMonth(people.name)
                
                let mon = weekDaysInfo[WeekDay.monday] ?? 0
                let tue = weekDaysInfo[WeekDay.tuesday] ?? 0
                let wed = weekDaysInfo[WeekDay.wednesday] ?? 0
                let thur = weekDaysInfo[WeekDay.thursday] ?? 0
                let fri = weekDaysInfo[WeekDay.friday] ?? 0
                let sat = weekDaysInfo[WeekDay.saturday] ?? 0
                let sun = weekDaysInfo[WeekDay.sunday] ?? 0
                let sum = mon + tue + wed + thur + fri + sat + sun
                peopleInfo = peopleInfo + "(\(sum)): \(mon)/\(tue)/\(wed)/\(thur)/\(fri)/\(sat)/\(sun)"
                
                
                result = result + "\n" + peopleInfo
            }
            result = result + "\n" + "----------------------------------"
            // 注目当番の人と同じ日に働いている人のデータ
            if let humanName = self.markedPeoplePopUpButton?.selectedItem?.title{
                
                result = result + "\n" + "注目当番の人と同じ日に働いている人のリスト"
                var list:[String] = []
                for dayInfo in table.days{
                    if dayInfo.workingHuman.count == 2 && dayInfo.workingHuman.contains(where: { (h) -> Bool in
                        return humanName == h.name
                    }){
                        let name = (dayInfo.workingHuman[0].name == humanName) ? dayInfo.workingHuman[1].name : dayInfo.workingHuman[0].name
                        list.append(name)
                    }
                }
                
                for name in list{
                    result = result + "\n" + name
                }
                
                result = result + "\n" + "----------------------------------"
            }
            
        }
        
        LogUtil.log(result + "\n")
        self.resultTextField?.stringValue = result
    }
    
    
    /// データベースのルールに従ってチェックボックスをアップデートする
    private func updateRules() throws{
        
        let rules:[Rules] = try Rules.fetchAllRecords(coreDataManagement.managedObjectContext)
        if rules.count == 1{
            rule = rules[0]
        }else{
            try Rules.deleteAllRecords(coreDataManagement.managedObjectContext)
            rule = Rules(context: coreDataManagement.managedObjectContext).updateParameters(
                true, unavailableWeekDays: true, interval: true, unavailableDays: true, weekEnd: true, practice: true, countInMonth: true)
            Records.saveContext(coreDataManagement.managedObjectContext)
        }
        
        if let rule = rule{
            self.checkBoxForSuper.state = (rule.superUser ? NSOnState : NSOffState)
            self.checkBoxForUnavailableWeekDays.state = (rule.unavailableWeekDays ? NSOnState : NSOffState)
            self.checkBoxForInterval.state = (rule.interval ? NSOnState : NSOffState)
            self.checkBoxForUnavailableDays.state = (rule.unavailableDays ? NSOnState : NSOffState)
            self.checkBoxForWeekEnd.state = (rule.weekEnd ? NSOnState : NSOffState)
            self.checkBoxForPractice.state = (rule.practice ? NSOnState : NSOffState)
            self.checkBoxForCountInMonth.state = (rule.countInMonth ? NSOnState : NSOffState)
        }
    }
    
    // MARK: - NSCollectionViewDataSource
    func collectionView(_ collectionView: NSCollectionView,
        numberOfItemsInSection section: Int) -> Int{
            return 42
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let collectionViewItem = self.collectionView.makeItem(withIdentifier: DayCollectionViewItem.XibName, for: indexPath)
        
        guard let dayItem = collectionViewItem as? DayCollectionViewItem else{
            LogUtil.log("error is not retrieved - \(indexPath):\(collectionViewItem.representedObject)" )
            return collectionViewItem;
        }
        
        
        dayItem.view.wantsLayer = true // ビューの中のレイアーの設定をするためにはこのフラグを立てる必要がある（iOSでは不要）
        dayItem.view.layer?.backgroundColor = HomeViewController.BackGroundColor
        dayItem.view.layer?.borderWidth = 1
        
        // 一日の曜日を取得
        let weekDayOfFirstDay = WeekDay(rawValue: self.targetMonthInfo.firstDayInAMonth.weekday!-1)!
        
        // 日付を取得
        let day = indexPath.item - (weekDayOfFirstDay.rawValue - 1)
        if day > 0 && day <= self.targetMonthInfo.lastDayInAMonth.day!{
            
            
            
            
            //強制参加の人を取得
            let tmpHumans:[People] = self.getForcefullySelectedPeople(day, workingPeople: self.workingPeople)
            
            let A:(name:String?, required:Bool)
            let B:(name:String?, required:Bool)
            if let table = self.table, table.days[day-1].workingHuman.count > 0{
                let humanA = table.days[day-1].getHumanOfNoX(0)
                let humanB = table.days[day-1].getHumanOfNoX(1)
                
                
                A = (name:humanA?.name, required:tmpHumans.contains(where: { (people:People) -> Bool in
                    return people.name == humanA?.name
                }))
                B = (name:humanB?.name, required:tmpHumans.contains(where: { (people:People) -> Bool in
                    return people.name == humanB?.name
                }))
            }else{
                A = (name:nil, required:false)
                B = (name:nil, required:false)
            }
            dayItem.setData(
                day,
                workingPeople:workingPeople,
                human:(A.name, B.name),
                status: (A.required, B.required),
                dayDelegate: self )
            
            
        }else{
            dayItem.setData(-1, workingPeople: [])
        }
        
        return dayItem
        
    }
    
    // MARK: - NSDatePickerCellDelegate
    private func datePickerCell(_ aDatePickerCell: NSDatePickerCell,
        validateProposedDateValue proposedDateValue: AutoreleasingUnsafeMutablePointer<Date>,
        timeInterval proposedTimeInterval: UnsafeMutablePointer<TimeInterval>?){
            let date = proposedDateValue.pointee
            self.updateMonthData(date)
            collectionView.reloadData()
        
    }
    
    
    
    
    // MARK: - ボタン押下時の処理
    // MARK: 各チェックボックス変更時の処理
    // ルールのチェックボックス押下時のアクション
    @IBAction func changeSuper(_ sender: NSButtonCell) {
        if runningTable{
            sender.state = (sender.state == NSOnState ? NSOffState : NSOnState)
            return
        }
        
        if let rule = rule{
            rule.superUser = !(rule.superUser)
            Records.saveContext(coreDataManagement.managedObjectContext)
        }
    }
    @IBAction func changeUnavailableWeekDays(_ sender: NSButton) {
        if runningTable{
            sender.state = (sender.state == NSOnState ? NSOffState : NSOnState)
            return
        }
        if let rule = rule{
            rule.unavailableWeekDays = !(rule.unavailableWeekDays)
            Records.saveContext(coreDataManagement.managedObjectContext)
        }
    }
    @IBAction func checkInterval(_ sender: NSButton) {
        if runningTable{
            sender.state = (sender.state == NSOnState ? NSOffState : NSOnState)
            return
        }
        if let rule = rule{
            rule.interval = !(rule.interval)
            Records.saveContext(coreDataManagement.managedObjectContext)
        }
    }
    @IBAction func checkUnavailableDays(_ sender: NSButton) {
        if runningTable{
            sender.state = (sender.state == NSOnState ? NSOffState : NSOnState)
            return
        }
        if let rule = rule{
            rule.unavailableDays = !(rule.unavailableDays)
            Records.saveContext(coreDataManagement.managedObjectContext)
        }
    }
    @IBAction func chageWeekEnd(_ sender: NSButton) {
        if runningTable{
            sender.state = (sender.state == NSOnState ? NSOffState : NSOnState)
            return
        }
        if let rule = rule{
            rule.weekEnd = !(rule.weekEnd)
            Records.saveContext(coreDataManagement.managedObjectContext)
        }
    }
    @IBAction func changePractice(_ sender: NSButton) {
        if runningTable{
            sender.state = (sender.state == NSOnState ? NSOffState : NSOnState)
            return
        }
        if let rule = rule{
            rule.practice = !(rule.practice)
            Records.saveContext(coreDataManagement.managedObjectContext)
        }
    }
    @IBAction func changeCountInMonth(_ sender: NSButton) {
        if runningTable{
            sender.state = (sender.state == NSOnState ? NSOffState : NSOnState)
            return
        }
        if let rule = rule{
            rule.countInMonth = !(rule.countInMonth)
            Records.saveContext(coreDataManagement.managedObjectContext)
        }
    }
    
    // MARK: 結果テキスト更新ボタン押下時の処理
    @IBAction func updateResultText(_ sender: NSButtonCell) {
        LogUtil.log("")
        self.updateResultText()
    }
    
    // MARK: 開始ボタンの押下時の処理
    @IBAction func clickOnStartButton(_ sender: AnyObject) {
        LogUtil.log()
        
        
        guard let rule = rule else {return}
        if runningTable{
            DialogUtil.startDialog("実行中です。キャンセルする場合はOKボタンを押下してください", onClickOKButton: { () -> () in
                self.runningTable = false
            })
            return
        }
        
        do{
            // 設定ページが閉じられる前に変更されている可能性があるため担当者の情報を更新する。
            try self.upatePeoples()
            
            
            
            let humans:[Human] = HomeViewController.convertPeopleToHuman(self.workingPeople)
            let cRules = HomeViewController.convertRuleToCRule(rule)
            let controller = HumanController(workingHuman: humans, cRules: cRules)
            
            LogUtil.log(humans)
            print("ユーザー数:\(controller.workingHuman.count)")
            
            self.runningTable = true
            startButton.title = "実行中..."
            let grobalQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive)
            grobalQueue.async(execute: {
                
                var errorMessage:String? = nil
                do{
                    self.table = try controller.startCreatingRandomTable(self.targetMonthInfo.targetMonth, running:&self.runningTable)
                }catch let error as CRule.RuleError{
                    switch error{
                    case .stop(let msg):
                        errorMessage = msg
                    default:
                        errorMessage = "予期せぬエラー:\(error)"
                    }
                }catch{
                    errorMessage = "予期せぬエラー:\(error)"
                }
                DispatchQueue.main.async(execute: {
                    self.runningTable = false
                    self.startButton.title = "開始"
                    do{
                        try self.upatePeoples()
                    }catch{
                        LogUtil.log("Error")
                    }
                    
                    if let errorMessage = errorMessage{
                        
                        if errorMessage != "キャンセルされました"{
                        
                            DialogUtil.startDialog(errorMessage, onClickOKButton: { () -> () in
                                self.runningTable = false
                            })
                        }else{
                            self.runningTable = false
                        }
                    }
                    
                    self.collectionView.reloadData()
                })
            })
            
            
            
        }catch{
            LogUtil.log("Error")
        }
    }

    // - MARK:  - MyDayDelegate
    /// 各日付のチェックボックス押下時
    func checkButton(_ day:Int, name:String, status:Bool, needSave:Bool){
        LogUtil.log("\(day): \(name) -> \(status)")
        guard case let multiPeople = workingPeople.filter({ (tmp:People) -> Bool in
            if tmp.name == name{
                return true
            }else{
                return false
            }
        }), multiPeople.count == 1 else{
            return
        }
        
        let people = multiPeople[0]
        
        // Tableの更新
        guard case let humans = HomeViewController.convertPeopleToHuman([people]), humans.count == 1 else{
            DialogUtil.startDialog("予期せぬエラー", onClickOKButton: { () -> () in })
            return
        }
        if status{
            // 追加
            self.table?.days[day-1].workingHuman.append(humans[0])
        }else{
            // 削除
            if let index = self.table?.days[day-1].workingHuman.index(where: { (tmpHuman) -> Bool in
                if humans[0].name == tmpHuman.name{
                    return true
                }else{
                return false
                }
            }){
                 self.table?.days[day-1].workingHuman.remove(at: index)
            }
        }
        
        
        
        guard needSave == true else{return}
        
        // DBのrequireDaysの更新
        let requireDays = people.requiredDays
        var requireDaysInt = HomeViewController.getDaysIntFromString(requireDays)
        if status{
            requireDaysInt.append(day)
            requireDaysInt = requireDaysInt.sorted()
        }else{
            
            guard let num = requireDaysInt.index(of: day) else{
                DialogUtil.startDialog("予期せぬエラー", onClickOKButton: { () -> () in })
                return
            }
            requireDaysInt.remove(at: num)
            
        }
        people.requiredDays = self.getDaysStringFromInt(requireDaysInt)
        Records.saveContext(coreDataManagement.managedObjectContext)
        
    }
    
    // - MARK: 
    /// DBのデータから当番表を作成する
    private func createCurrentTableFromDB() -> MonthTable?{
        
        guard let rule = rule else {return nil}
        
        let humans:[Human] = HomeViewController.convertPeopleToHuman(self.workingPeople)
        LogUtil.log(humans)
        let cRules = HomeViewController.convertRuleToCRule(rule)
        
        let controller = HumanController(workingHuman: humans, cRules: cRules)
        let table = controller.createInitializedMonthTable(self.targetMonthInfo.targetMonth)
        
        return table
    }
    
    
    

    
    /// 文字列で複数の日付を表現している（カンマ区切り）ものから、Int配列を取得する
    static private func getDaysIntFromString(_ days:String) -> [Int]{
        var daysInt:[Int] = []
        let str1 = days as NSString
        for numStr in str1.components(separatedBy: ","){
            var lNumStr = numStr
            if lNumStr.contains(" "){
                lNumStr = lNumStr.trimmingCharacters(in: CharacterSet.whitespaces)
            }
            if let num = Int(lNumStr), num > 0 && num < 32{
                daysInt.append(num)
            }
        }
        return daysInt
    }
    
    private func getDaysStringFromInt(_ days:[Int]) -> String{
        
        if days.count < 1{
            return ""
        }else if days.count == 1{
            return "\(days[0])"
        }
        var str = "\(days[0])"
        for i in 1...days.count-1{
            str = str + ", \(days[i])"
        }
        return str
    }
    
    /// dayに必ず参加する人を抽出
    private func getForcefullySelectedPeople(_ day:Int, workingPeople:[People]) -> [People]{
        var tmpHumans:[People] = []
        for people in workingPeople{
            let requiredDays:[Int] = HomeViewController.getDaysIntFromString(people.requiredDays)
            if requiredDays.contains(day){
                tmpHumans.append(people)
            }
        }
        return tmpHumans
    }
    
    
    private static func convertPeopleToHuman(_ workingPeople:[People]) -> [Human]{
        var humans:[Human] = []
        var id = 0
        for people:People in workingPeople{
            if people.status == false{
                continue
            }
            let weekdaysInfo:People.PTWeekDays = People.PTWeekDays.getDicsFromJson(people.unavailableWeekDays)!
            let mustWeekDays:People.PTWeekDays = People.PTWeekDays.getDicsFromJson(people.requiredWeekDays)!
            
            
            
            let forbittenDays:[Int] = self.getDaysIntFromString(people.unavailableDays)
            
            let requiredDays:[Int] = self.getDaysIntFromString(people.requiredDays)
            
            
            let human = Human(id: id, name: people.name, unableWeekDays: weekdaysInfo.getWeekDays(), isSuper: people.isSuper, practiceRule: (mustWeekDays: mustWeekDays.getWeekDays(), max: people.limitOfRequiredWeekDays as Int), maxWorkingCountInAMonth: people.maxWorkingCountInAMonth as Int, minWorkingCountInAMonth: people.minWorkingCountInAMonth as Int, forbittenDays: forbittenDays, requiredDays:requiredDays)
            humans.append(human)
            id = id + 1
        }
        return humans
    }
    
    private static func convertRuleToCRule(_ rules:Rules) -> CRules{
        var cRules = CRules(percentage: 0.75)
        cRules.createIndividualRule(true,
            RuleSuperUser: rules.superUser,
            RuleUnavailableWeekDays: rules.unavailableWeekDays,
            RuleInterval: rules.interval,
            RuleUnavailableDays: rules.unavailableWeekDays
        )
        cRules.createMonthRule(rules.weekEnd,
            RulePractice: rules.practice,
            RuleCountsInMonth: rules.countInMonth)
        return cRules
    }
}

