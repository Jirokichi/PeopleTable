//
//  ViewController.swift
//  PeopleTable
//
//  Created by yuya on 2016/03/10.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Cocoa

class HomeViewController: NSViewController, NSCollectionViewDataSource, NSCollectionViewDelegate, NSDatePickerCellDelegate{

    struct NotificationCenter{
        static let ID = "UpadeSettingInfo"
    }
    
    
    static let BackGroundColor = NSColor.whiteColor().CGColor
 
    // MARK: - 変数 >> ストーリーボードと関連付けらている
    @IBOutlet weak var headerView: DayHeaderView!
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var resultTextField: NSTextField!
    
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
        var targetMonth:NSDate = NSDate()
        var firstDayInAMonth:NSDateComponents = NSDateComponents()
        var lastDayInAMonth:NSDateComponents = NSDateComponents()
        
        mutating func update(newTargetMonth:NSDate){
            self.targetMonth = newTargetMonth
            self.firstDayInAMonth = DateUtil.getFirstDay(self.targetMonth)
            self.lastDayInAMonth = DateUtil.getLastDay(self.targetMonth)
        }
    }
    private var targetMonthInfo:TargetMonthInfo = TargetMonthInfo()
    
    // MARK: - 変数 >> CoreData情報
    let coreDataManagement = CoreDataManagement.Singleton
    var workingPeople:[People] = []
    var rule:Rules?
    
    
    // MARK: - 変数 >> 当番表作成クラスで利用する
    var table:MonthTable? = nil
    /// 当番表作成中フラグ
    var runningTable = false;
    
    
    // MARK: - ライフサイクルの処理
    deinit{
        LogUtil.log("finish")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        LogUtil.log()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        LogUtil.log()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
        // 今月の最終日の取得
        self.updateMonthData(NSDate())
        
        do{
            try self.updateRules()
        }catch{
            LogUtil.log("担当者情報のフェッチに失敗しました。チェックボックスの更新も失敗しています。アプリ開発者に問い合わせてください。")
        }
        headerView.setData(self.targetMonthInfo.targetMonth, delegate: self)
        headerView.wantsLayer = true
        headerView.layer?.backgroundColor = HomeViewController.BackGroundColor
        headerView.layer?.borderWidth = 1
        headerView.layer?.borderWidth = 1
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: HomeViewController.UpdateSettingInfo, name: NotificationCenter.ID, object: nil)
    }
    
    // MARK: - 更新処理
    /// テーブルの初期化(NotificationCenterで呼び出される)
    private static let UpdateSettingInfo:Selector = "updateSettingInfo:"
    func updateSettingInfo(notification:NSNotification?){
        LogUtil.log()
        DialogUtil.startDialog("警告", message: "設定が変更されました。一度結果をリセットしてもよろしいでしょうか？") { () -> () in
            self.updateTable(nil)
        }
    }
    
    // テーブルの更新
    private func updateTable(table:MonthTable?){
        // テーブルの更新と人設定
        LogUtil.log()
        self.table = table
        do{
            try self.upatePeoples()
            self.collectionView.reloadData()
        }catch{
            LogUtil.log("Error")
        }
    }
    
    /// 日付情報の更新 - テーブルは初期化されます
    private func updateMonthData(day:NSDate){
        self.targetMonthInfo.update(day)
        self.updateTable(nil)
    }
    
    /// CoreDataから人を取得（一人もいなければデフォルトを作成）してきて、現在の情報(各人の月の稼働日数や曜日ごとの稼働日数)を出力する
    func upatePeoples() throws{
        workingPeople.removeAll()
        workingPeople =  try People.fetchAllRecords(coreDataManagement.managedObjectContext, sortDescriptor: People.createSortDescriptor())
        
        if workingPeople.count < 1{
            workingPeople = People.createDefaultPeoples(coreDataManagement)
        }
        
        var result:String = "----------------------------------"
        result = result + "\n" + "名前(合計): 月/火/水/木/金/土/日"
        for people in workingPeople{
            var peopleInfo = people.name
            if let table = self.table{
                let weekDaysInfo:[WeekDay:Int] = table.numberOfSpecificWeekDayInAMonth(people.name)
                
                let mon = weekDaysInfo[WeekDay.Monday] ?? 0
                let tue = weekDaysInfo[WeekDay.Tuesday] ?? 0
                let wed = weekDaysInfo[WeekDay.Wednesday] ?? 0
                let thur = weekDaysInfo[WeekDay.Thursday] ?? 0
                let fri = weekDaysInfo[WeekDay.Friday] ?? 0
                let sat = weekDaysInfo[WeekDay.Saturday] ?? 0
                let sun = weekDaysInfo[WeekDay.Sunday] ?? 0
                let sum = mon + tue + wed + thur + fri + sat + sun
                peopleInfo = peopleInfo + "(\(sum)): \(mon)/\(tue)/\(wed)/\(thur)/\(fri)/\(sat)/\(sun)"
                
            }
            
            result = result + "\n" + peopleInfo
        }
        result = result + "\n" + "----------------------------------"
        
        
        LogUtil.log(result + "\n")
        self.resultTextField?.stringValue = result
    }
    
    
    /// データベースのルールに従ってチェックボックスをアップデートする
    func updateRules() throws{
        
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
    func collectionView(collectionView: NSCollectionView,
        numberOfItemsInSection section: Int) -> Int{
            return 42
    }
    
    func collectionView(collectionView: NSCollectionView, itemForRepresentedObjectAtIndexPath indexPath: NSIndexPath) -> NSCollectionViewItem {
        
        let collectionViewItem = self.collectionView.makeItemWithIdentifier(DayCollectionViewItem.StoryBoardId, forIndexPath: indexPath)
        
        if let dayItem = collectionViewItem as? DayCollectionViewItem{
            dayItem.view.wantsLayer = true // ビューの中のレイアーの設定をするためにはこのフラグを立てる必要がある（iOSでは不要）
            dayItem.view.layer?.backgroundColor = HomeViewController.BackGroundColor
            dayItem.view.layer?.borderWidth = 1
            
            
            let weekDayOfADay = WeekDay(rawValue: self.targetMonthInfo.firstDayInAMonth.weekday-1)!
            
            
            let day = indexPath.item - (weekDayOfADay.rawValue - 1)
            if day > 0 && day <= self.targetMonthInfo.lastDayInAMonth.day{
                if let table = table{
                    let humanAName = table.days[day-1].workingHuman[0].name
                    let humanBName = table.days[day-1].workingHuman[1].name
                    dayItem.setData(day, workingPeople:workingPeople, humanAName: humanAName, humanBName:humanBName )
                }else{
                    dayItem.setData(day, workingPeople:workingPeople)
                }
            }else{
                dayItem.setData(-1, workingPeople: [])
            }
            
            return dayItem
        }else{
            
            LogUtil.log("error is not retrieved - \(indexPath):\(collectionViewItem.representedObject)" )
            return collectionViewItem;
        }
    }
    
    // MARK: - NSDatePickerCellDelegate
    func datePickerCell(aDatePickerCell: NSDatePickerCell,
        validateProposedDateValue proposedDateValue: AutoreleasingUnsafeMutablePointer<NSDate?>,
        timeInterval proposedTimeInterval: UnsafeMutablePointer<NSTimeInterval>){
            if let date = proposedDateValue.memory{
                self.updateMonthData(date)
                collectionView.reloadData()
            }
    }
    
    
    
    
    // MARK: - ボタン押下時の処理
    // MARK: 各チェックボックス変更時の処理
    // ルールのチェックボックス押下時のアクション
    @IBAction func changeSuper(sender: NSButtonCell) {
        if runningTable{
            sender.state = (sender.state == NSOnState ? NSOffState : NSOnState)
            return
        }
        
        if let rule = rule{
            rule.superUser = !(rule.superUser)
            Records.saveContext(coreDataManagement.managedObjectContext)
        }
    }
    @IBAction func changeUnavailableWeekDays(sender: NSButton) {
        if runningTable{
            sender.state = (sender.state == NSOnState ? NSOffState : NSOnState)
            return
        }
        if let rule = rule{
            rule.unavailableWeekDays = !(rule.unavailableWeekDays)
            Records.saveContext(coreDataManagement.managedObjectContext)
        }
    }
    @IBAction func checkInterval(sender: NSButton) {
        if runningTable{
            sender.state = (sender.state == NSOnState ? NSOffState : NSOnState)
            return
        }
        if let rule = rule{
            rule.interval = !(rule.interval)
            Records.saveContext(coreDataManagement.managedObjectContext)
        }
    }
    @IBAction func checkUnavailableDays(sender: NSButton) {
        if runningTable{
            sender.state = (sender.state == NSOnState ? NSOffState : NSOnState)
            return
        }
        if let rule = rule{
            rule.unavailableDays = !(rule.unavailableDays)
            Records.saveContext(coreDataManagement.managedObjectContext)
        }
    }
    @IBAction func chageWeekEnd(sender: NSButton) {
        if runningTable{
            sender.state = (sender.state == NSOnState ? NSOffState : NSOnState)
            return
        }
        if let rule = rule{
            rule.weekEnd = !(rule.weekEnd)
            Records.saveContext(coreDataManagement.managedObjectContext)
        }
    }
    @IBAction func changePractice(sender: NSButton) {
        if runningTable{
            sender.state = (sender.state == NSOnState ? NSOffState : NSOnState)
            return
        }
        if let rule = rule{
            rule.practice = !(rule.practice)
            Records.saveContext(coreDataManagement.managedObjectContext)
        }
    }
    @IBAction func changeCountInMonth(sender: NSButton) {
        if runningTable{
            sender.state = (sender.state == NSOnState ? NSOffState : NSOnState)
            return
        }
        if let rule = rule{
            rule.countInMonth = !(rule.countInMonth)
            Records.saveContext(coreDataManagement.managedObjectContext)
        }
    }
    
    
    // MARK: 開始ボタンの押下時の処理
    @IBAction func clickOnStartButton(sender: AnyObject) {
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
            
            var humans:[Human] = []
            var id = 0
            for people:People in workingPeople{
                if people.status == false{
                    continue
                }
                let weekdaysInfo:People.PTWeekDays = People.PTWeekDays.getDicsFromJson(people.unavailableWeekDays)!
                let mustWeekDays:People.PTWeekDays = People.PTWeekDays.getDicsFromJson(people.requiredWeekDays)!
                
                
                
                var forbittenDays:[Int] = []
                let str = people.unavailableDays as NSString
                for numStr in str.componentsSeparatedByString(","){
                    var lNumStr = numStr
                    if lNumStr.containsString(" "){
                        lNumStr = lNumStr.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                    }
                    if let num = Int(lNumStr) where num > 0 && num < 32{
                        forbittenDays.append(num)
                    }
                }
                
                
                
                let human = Human(id: id, name: people.name, unableWeekDays: weekdaysInfo.getWeekDays(), isSuper: people.isSuper, practiceRule: (mustWeekDays: mustWeekDays.getWeekDays(), max: people.limitOfRequiredWeekDays as Int), maxWorkingCountInAMonth: people.maxWorkingCountInAMonth as Int, minWorkingCountInAMonth: people.minWorkingCountInAMonth as Int, forbittenDays: forbittenDays)
                humans.append(human)
                id = id + 1
            }
            
            LogUtil.log(humans)
            var rules = CRules(percentage: 0.75)
            rules.createIndividualRule(true,
                RuleSuperUser: rule.superUser,
                RuleUnavailableWeekDays: rule.unavailableWeekDays,
                RuleInterval: rule.interval,
                RuleUnavailableDays: rule.unavailableWeekDays
            )
            rules.createMonthRule(rule.weekEnd,
                RulePractice: rule.practice,
                RuleCountsInMonth: rule.countInMonth)
            
            let controller = HumanController(humans: humans)
            
            print("ユーザー数:\(controller.humans.count)")
            
            self.runningTable = true
            startButton.title = "実行中..."
            let grobalQueue = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
            dispatch_async(grobalQueue, {
                self.table = try? controller.startCreatingRandomTable(self.targetMonthInfo.targetMonth, rules:rules, running:&self.runningTable)
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.runningTable = false
                    self.startButton.title = "開始"
                    do{
                        try self.upatePeoples()
                    }catch{
                        LogUtil.log("Error")
                    }
                    self.collectionView.reloadData()
                })
            })
            
            
            
        }catch{
            LogUtil.log("Error")
        }
    }

    

}

