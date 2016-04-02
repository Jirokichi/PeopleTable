//
//  AppDelegate.swift
//  PeopleTable
//
//  Created by yuya on 2016/03/10.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        LogUtil.log()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        LogUtil.log()
    }


    func applicationShouldTerminate(sender: NSApplication) -> NSApplicationTerminateReply {
        LogUtil.log()
        // If we got here, it is time to quit.
        return .TerminateNow
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true;
    }


}

