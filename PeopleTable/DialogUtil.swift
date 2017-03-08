//
//  DialogUtil.swift
//  PeopleTable
//
//  Created by yuya on 2016/03/31.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Foundation
import Cocoa

class DialogUtil{
 
    static func startDialog(_ title:String, message:String? = nil, onClickOKButton:()->()){
        // Swiftの場合
        let alert = NSAlert()
        alert.messageText = title
        if let message = message{
           alert.informativeText = message
        }
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "キャンセル")
        let result = alert.runModal()
        if (result == NSAlertFirstButtonReturn) {
            LogUtil.log("OK")
            onClickOKButton()
        }
    }
}
