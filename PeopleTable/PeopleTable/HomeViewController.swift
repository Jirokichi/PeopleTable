//
//  ViewController.swift
//  PeopleTable
//
//  Created by yuya on 2016/03/10.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Cocoa

class HomeViewController: NSViewController, NSCollectionViewDataSource, NSCollectionViewDelegate, NSDatePickerCellDelegate{

    static let BackGroundColor = NSColor.whiteColor().CGColor
    
    @IBOutlet weak var headerView: DayHeaderView!
    
    @IBOutlet weak var collectionView: NSCollectionView!

    @IBOutlet weak var resultTextField: NSTextField!
    
    var targetYearMonth:NSDate = NSDate()
    var firstDayInAsMonth:NSDateComponents = NSDateComponents()
    var lastDayInAMonth:NSDateComponents = NSDateComponents()
    
    var multiPeople:[People] = []
    
    let coreDataManagement = CoreDataManagement.Singleton
    var manePeople:[People] = []
    
    var table:MonthTable? = nil
    var running = false;
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do{
            try self.upatePeoples()
        }catch{
            LogUtil.log("Error")
        }
        
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
        // 今月の最終日の取得
        self.updateMonthData(NSDate())
        
        do{
            self.multiPeople = try People.fetchAllRecords(CoreDataManagement.Singleton.managedObjectContext, sortDescriptor: People.createSortDescriptor())
        }catch{
            LogUtil.log("人情報のフェッチに失敗")
        }
        headerView.setData(self.targetYearMonth, delegate: self)
        headerView.wantsLayer = true
        headerView.layer?.backgroundColor = HomeViewController.BackGroundColor
        headerView.layer?.borderWidth = 1
        headerView.layer?.borderWidth = 1
    }
    
    private func updateMonthData(day:NSDate){
        targetYearMonth = day
        firstDayInAsMonth = DateUtil.getFirstDay(day)
        lastDayInAMonth = DateUtil.getLastDay(day)
    }
    
    
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
            
            
            let weekDayOfADay = WeekDay(rawValue: firstDayInAsMonth.weekday-1)!
            
            
            let day = indexPath.item - (weekDayOfADay.rawValue - 1)
            if day > 0 && day <= lastDayInAMonth.day{
                if let table = table{
                    let humanAName = table.days[day-1].workingHuman[0].name
                    let humanBName = table.days[day-1].workingHuman[1].name
                    dayItem.setData(day, multiPeople:multiPeople, humanAName: humanAName, humanBName:humanBName )
                }else{
                    dayItem.setData(day, multiPeople:multiPeople)
                }
            }else{
                dayItem.setData(-1, multiPeople: [])
            }
            
            return dayItem
        }else{
            
            LogUtil.log("error is not retrieved - \(indexPath):\(collectionViewItem.representedObject)" )
            return collectionViewItem;
        }
    }
    
    
    func datePickerCell(aDatePickerCell: NSDatePickerCell,
        validateProposedDateValue proposedDateValue: AutoreleasingUnsafeMutablePointer<NSDate?>,
        timeInterval proposedTimeInterval: UnsafeMutablePointer<NSTimeInterval>){
            if let date = proposedDateValue.memory{
                self.updateMonthData(date)
                collectionView.reloadData()
            }
    }
    func upatePeoples() throws{
        manePeople.removeAll()
        manePeople =  try People.fetchAllRecords(coreDataManagement.managedObjectContext, sortDescriptor: People.createSortDescriptor())
        
        if manePeople.count < 1{
            manePeople = People.createDefaultPeoples(coreDataManagement)
        }
     
        var result:String = "----------------------------------"
        result = result + "\n" + "名前(合計): 月/火/水/木/金/土/日"
        for people in manePeople{
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
        
        
        LogUtil.log(result)
        self.resultTextField?.stringValue = result
    }
    
    
    @IBAction func clickOnStartButton(sender: AnyObject) {
        LogUtil.log()
        
        if running{
            DialogUtil.startDialog("実行中です。キャンセルする場合はOKボタンを押下してください", onClickOKButton: { () -> () in
                
            })
           
            
            
            return
        }
        
        do{
            try self.upatePeoples()
            
            var humans:[Human] = []
            var id = 0
            
//            
            for people:People in manePeople{
                if people.status == false{
                    continue
                }
                let weekdaysInfo:People.PTWeekDays = People.PTWeekDays.getDicsFromJson(people.unavailableWeekDays)!
                let mustWeekDays:People.PTWeekDays = People.PTWeekDays.getDicsFromJson(people.requiredWeekDays)!
                
                let human = Human(id: id, name: people.name, unableWeekDays: weekdaysInfo.getWeekDays(), isSuper: people.isSuper, practiceRule: (mustWeekDays: mustWeekDays.getWeekDays(), max: people.limitOfRequiredWeekDays as Int), maxWorkingCountInAMonth: people.maxWorkingCountInAMonth as Int, minWorkingCountInAMonth: people.minWorkingCountInAMonth as Int, forbittenDays: [])
                humans.append(human)
                id = id + 1
            }
            
            LogUtil.log(humans)
            var rules = Rules(percentage: 0.75)
            rules.createIndividualRule(true, ruleA: true, ruleB: true, ruleC: false, ruleD: true)
            rules.createMonthRule(true, ruleB: false, ruleC: false)
            
            let controller = HumanController(humans: humans)
            
            print("ユーザー数:\(controller.humans.count)")
            
            running = true
            let grobalQueue = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
            dispatch_async(grobalQueue, {
                self.table = controller.startCreatingRandomTable(self.targetYearMonth, rules:rules)
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.running = false
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

