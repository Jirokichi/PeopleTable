//
//  MyWindowController.swift
//  PeopleTable
//
//  Created by yuya on 2016/04/02.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Cocoa

class MyWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

    @IBAction func finish(sender:AnyObject){
        LogUtil.log()
    }
}
