//
//  ViewController.swift
//  PeopleTable
//
//  Created by yuya on 2016/03/10.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Cocoa

class HomeViewController: NSViewController, NSCollectionViewDataSource{

    var hoge = Day(A: "A", B: "B", day: "1")
    var hogeArray:NSMutableArray?
    
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var gridLayout: NSCollectionViewGridLayout!

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        collectionView.registerClass(DayCollectionViewItem.self, forItemWithIdentifier: DayCollectionViewItem.StoryBoardId)
//        if let itemPrototype = self.storyboard?.instantiateControllerWithIdentifier(DayCollectionViewItem.StoryBoardId)
//            as? DayCollectionViewItem{
//                
//                LogUtil.log("\(itemPrototype)")
//                self.collectionView.itemPrototype = itemPrototype
//        }else{
//            LogUtil.log("error")
//        }
//        hogeArray = NSMutableArray(array:[hoge, hoge, hoge])
//        collectionView.content = hogeArray! as [AnyObject]
        
        collectionView.dataSource = self
    }
    
    func collectionView(collectionView: NSCollectionView,
        numberOfItemsInSection section: Int) -> Int{
            LogUtil.log("\(section)")
            return 35
    }
    
    func collectionView(collectionView: NSCollectionView, itemForRepresentedObjectAtIndexPath indexPath: NSIndexPath) -> NSCollectionViewItem {
        
        let collectionViewItem = self.collectionView.makeItemWithIdentifier(DayCollectionViewItem.StoryBoardId, forIndexPath: indexPath)
        
        if let dayItem = collectionViewItem as? DayCollectionViewItem{
            LogUtil.log("\(indexPath) - \(dayItem)" )
            dayItem.view.wantsLayer = true
            dayItem.view.layer?.backgroundColor = NSColor.whiteColor().CGColor
            dayItem.setData("\(indexPath.item)")
            return dayItem
        }else{
            
            LogUtil.log("error is not retrieved - \(indexPath):\(collectionViewItem.representedObject)" )
            return collectionViewItem;
        }
    }
    
    @IBAction func clickOnStartButton(sender: AnyObject) {
        
        LogUtil.log()
        
        
        hogeArray?.removeLastObject()
        collectionView.content = hogeArray! as [AnyObject]
        collectionView.reloadData()
    }
    
    

}

