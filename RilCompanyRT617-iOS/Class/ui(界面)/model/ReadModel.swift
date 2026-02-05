//
//  ReadModel.swift
//  RilCompanyRT617-iOS
//
//  Created by RND on 2023/8/3.
//

import UIKit
import HandyJSON

class ReadModel: HandyJSON {

    var fileName: String?
    var fileSize: Int = 0
    var type: Int = 0
    var legth: Int = 0
    var req: [UInt8] = []
    var list = [Read]()

    required init() {}
    
}

class Read: HandyJSON{
    var fileReq: [UInt8] = []
    var fileName: String?
    var fileSize: UInt64 = 0
    var fileSeq: UInt32 = 0
    var indexs:Int?
    var fileData: String?
    var fileTime: String?
    var fileTemp1: String?
    var fileTemp2: String?
    
    required init() {}
}
