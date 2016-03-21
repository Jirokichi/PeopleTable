//
//  LogUtil.swift
//  PeopleTable
//
//  Created by yuya on 2016/03/10.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Foundation


class LogUtil{
    static func log(object: Any? = "Any?", classFile: String = __FILE__, functionName: String = __FUNCTION__, lineNumber: Int = __LINE__) {
        
        // 日時フォーマット
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        // 日時・クラス名・メソッド名を出力
        
        if let fileName = NSURL(string: String(classFile))?.lastPathComponent {
            print("[\(dateFormatter.stringFromDate(NSDate()))]:\(object ?? "nil") in \(functionName) in \(fileName)(\(lineNumber) line)")
        } else {
            print("[\(dateFormatter.stringFromDate(NSDate()))]:\(object ?? "nil") in \(functionName) in \(classFile)(\(lineNumber) line)")
        }
        //            print("[\(dateFormatter.stringFromDate(NSDate()))]:\(lineNumber) - \(functionName):\(object)")
    }
    
    static func shortString(string:String) -> String{
        var str = string
        var i = 0
        for index in str.rangeOfString(str)!{
            if i > 5{
                str.removeAtIndex(index.predecessor())
            }
            i++
        }
        return str
    }
    
}