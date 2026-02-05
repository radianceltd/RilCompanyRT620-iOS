//
//  TempModel.swift
//  RilCompanyRT617-iOS
//
//  Created by RND on 2023/7/3.
//

import HandyJSON
import CoreBluetooth

class TempModel: HandyJSON {
    
    //温度解析这一块
    var tmp: String?
    var mac: String?
    var max: String?
    var min: String?
    var unit: String?
    var bat: String?
    var time = 0

    required init() {}
}
