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

    
    var targetYearMonth:NSDate = NSDate()
    var firstDayInAsMonth:NSDateComponents = NSDateComponents()
    var lastDayInAMonth:NSDateComponents = NSDateComponents()
    
    var multiPeople:[People] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                dayItem.setData(day, multiPeople:multiPeople)
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
    
    @IBAction func clickOnStartButton(sender: AnyObject) {
        LogUtil.log()
        
        
//        let humans = [
//            Human(id:0, name: "A", unableWeekDays: [.Sunday, .Monday], isSuper:true, practiceRule: (mustWeekDays: [], max: 0), maxWorkingCountInAMonth:6, minWorkingCountInAMonth:4, forbittenDays:[]),
//            Human(id:1, name: "B", unableWeekDays: [.Tuesday, .Thursday], isSuper:true, practiceRule: (mustWeekDays: [], max: 0), maxWorkingCountInAMonth:6, minWorkingCountInAMonth:4, forbittenDays:[]),
//            Human(id:2, name: "C", unableWeekDays: [.Tuesday, .Wednesday], isSuper:true, practiceRule: (mustWeekDays: [], max: 0), maxWorkingCountInAMonth:6, minWorkingCountInAMonth:4, forbittenDays:[]),
//            Human(id:3, name: "D", unableWeekDays: [], isSuper:true, practiceRule: (mustWeekDays: [], max: 0), maxWorkingCountInAMonth:6, minWorkingCountInAMonth:4, forbittenDays:[]),
//            Human(id:4, name: "E", unableWeekDays: [], isSuper:true, practiceRule: (mustWeekDays: [], max: 0), maxWorkingCountInAMonth:6, minWorkingCountInAMonth:4, forbittenDays:[]),
//            Human(id:5, name: "F", unableWeekDays: [], isSuper:true, practiceRule: (mustWeekDays: [], max: 0), maxWorkingCountInAMonth:6, minWorkingCountInAMonth:4, forbittenDays:[]),
//            Human(id:6, name: "G", unableWeekDays: [], isSuper:false, practiceRule: (mustWeekDays: [.Tuesday, .Thursday], max: 2), maxWorkingCountInAMonth:6, minWorkingCountInAMonth:4, forbittenDays:[]),
//            Human(id:7, name: "H", unableWeekDays: [], isSuper:false, practiceRule: (mustWeekDays: [.Tuesday, .Thursday], max: 2), maxWorkingCountInAMonth:6, minWorkingCountInAMonth:4, forbittenDays:[]),
//            Human(id:8, name: "I", unableWeekDays: [], isSuper:false, practiceRule: (mustWeekDays: [.Tuesday, .Thursday], max: 2), maxWorkingCountInAMonth:6, minWorkingCountInAMonth:4, forbittenDays:[]),
//            Human(id:9, name: "J", unableWeekDays: [], isSuper:false, practiceRule: (mustWeekDays: [], max: 0), maxWorkingCountInAMonth:6, minWorkingCountInAMonth:4, forbittenDays:[]),
//            Human(id:10, name: "K", unableWeekDays: [], isSuper: false, practiceRule: (mustWeekDays: [], max: 0), maxWorkingCountInAMonth:6, minWorkingCountInAMonth:4, forbittenDays:[])
//        ]

        
//        let humans:[Human] = []
//        var id = 0;
//        for people in multiPeople{
//            let human = Human(id:0, name: people.name, unableWeekDays: [.Sunday, .Monday], isSuper:true, practiceRule: (mustWeekDays: [], max: 0), maxWorkingCountInAMonth:6, minWorkingCountInAMonth:4, forbittenDays:[])
//            
//            
//            
//        }
//        
//        var rules = Rules(percentage: 0.75)
//        rules.createIndividualRule(true, ruleA: true, ruleB: true, ruleC: true, ruleD: true)
//        rules.createMonthRule(true, ruleB: false, ruleC: false)
//        
//        let controller = HumanController(humans: humans)
//        
//        print("ユーザー数:\(controller.humans.count)")
//        controller.startCreatingRandomTable(NSDate(), rules:rules)

        
        collectionView.reloadData()
    }
    
    

}

