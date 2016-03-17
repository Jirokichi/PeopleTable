//
//  ViewController.swift
//  PeopleTable
//
//  Created by yuya on 2016/03/10.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Cocoa

class ViewController: NSViewController{

    var hoge = Day()
    var hogeArray:NSMutableArray?
    
    @IBOutlet weak var collectionView: NSCollectionView!

    @IBOutlet var arrayController: NSArrayController!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let itemPrototype = self.storyboard?.instantiateControllerWithIdentifier("collectionViewItem")
            as? NSCollectionViewItem
        self.collectionView.itemPrototype = itemPrototype
        
        hogeArray = NSMutableArray(array:[hoge, hoge, hoge])
        collectionView.content = hogeArray! as [AnyObject]
    }
    

}

