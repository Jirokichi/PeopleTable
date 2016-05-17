//
//  FormulaUtil.swift
//  PeopleTable
//
//  Created by yuya on 2016/05/16.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Foundation

struct FormulaUtil{
    static func getRandomValue<T>(array:[T]) -> T{
        return array[Int(arc4random_uniform(UInt32(array.count)))]
    }
}