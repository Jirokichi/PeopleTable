//
//  Day.swift
//  PeopleTable
//
//  Created by yuya on 2016/03/16.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Cocoa

class Day: NSObject {

    let humanA:String
    let humanB:String
    let day:String
    
    init(A:String, B:String, day:String){
        self.humanA = A
        self.humanB = B
        self.day = day
    }
}
