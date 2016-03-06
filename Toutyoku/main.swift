//
//  main.swift
//  Toutyoku
//
//  Created by yuya on 2016/02/29.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Foundation

print("シフト決めを開始...")



let controller = HumanController()

print("ユーザー数:\(controller.humans.count)")
controller.startCreatingRandomTable()
