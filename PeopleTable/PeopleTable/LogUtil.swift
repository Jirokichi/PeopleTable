//
//  LogUtil.swift
//  PeopleTable
//
//  Created by yuya on 2016/03/10.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Foundation


class LogUtil{
    static func log(_ object: Any? = "Any?", classFile: String = #file, functionName: String = #function, lineNumber: Int = #line) {
        
        // 日時フォーマット
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        // 日時・クラス名・メソッド名を出力
        
        if let fileName = URL(string: String(classFile))?.lastPathComponent {
            print("[\(dateFormatter.string(from: Date()))]:\(object ?? "nil") in \(functionName) in \(fileName)(\(lineNumber) line)")
        } else {
            print("[\(dateFormatter.string(from: Date()))]:\(object ?? "nil") in \(functionName) in \(classFile)(\(lineNumber) line)")
        }
        //            print("[\(dateFormatter.stringFromDate(NSDate()))]:\(lineNumber) - \(functionName):\(object)")
    }
    
}
