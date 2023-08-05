//
//  rateInfo.swift
//  RMT
//
//  Created by vt9 on 2023/8/5.
//

import Foundation

struct rateInfo {
    let ToCurrencyCode: String //轉換後幣別
    let Rate: Double //匯率
}

enum btnType: Int {
    case f_tw = 0
    case f_jp = 1
    case f_kr = 2
    case f_ta = 3
    case f_us = 4
    case f_cn = 5
    case t_tw = 10
    case t_jp = 11
    case t_kr = 12
    case t_ta = 13
    case t_us = 14
    case t_cn = 15
}


