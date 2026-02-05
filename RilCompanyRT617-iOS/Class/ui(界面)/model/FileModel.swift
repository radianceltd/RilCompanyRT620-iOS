//
//  FileModel.swift
//  RilCompanyRT617-iOS
//
//  Created by RND on 2023/6/30.
//

import UIKit
import HandyJSON

class FileModel: HandyJSON {
    
    var filename:String?
    
    var filepath:String?
    //默认是不选择
    var isSelect:Bool = false
    
    var fileCsvTextLb:String?
    
    required init() {}
}
