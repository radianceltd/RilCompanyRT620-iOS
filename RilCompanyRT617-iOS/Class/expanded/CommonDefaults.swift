//
//  CommonDefaults.swift
//  RilCompanyRT617-iOS
//
//  Created by RND on 2023/8/25.
//

import UIKit

class CommonDefaults: NSObject {
    
    var userDefaults:UserDefaults!
    
    static let shared = CommonDefaults()
    
    override init() {
        super.init()
        userDefaults = UserDefaults.standard
    }
    
    func saveValue(_ value: String?, forKey key: String?) {
        if value != nil && key != nil {
            userDefaults.setValue(value, forKey: key ?? "")
            userDefaults.synchronize()
        }
    }
    
    func getValue(_ key: String?) -> String? {
        if key != nil && !(key?.isEqual("") ?? false) {
            let value = userDefaults.string(forKey: key ?? "")
            return value
        }
        return ""
    }
    
    //存储MAC
   func saveMac(_ mac: String?) {
        if mac != nil && !(mac == "") {
            userDefaults.setValue(mac, forKey: "deviceMac")
        } else {
            userDefaults.setValue("", forKey: "deviceMac")
        }
    }
    
    //得到MAC
    func getMac() -> String? {
        let mac = userDefaults.string(forKey: "deviceMac")
        if mac != nil && !(mac == "") {
            return mac
        } else {
            return nil
        }
    }
    
    //存储符号值
    func saveUpdateUnit(_ unit: String?, macData mac: String?) {
        if mac != nil {
            let updateUnit = mac! + ("updateUnit")
            userDefaults.setValue(unit, forKey: updateUnit)
        }
    }
    
    //得到符号值
    func getDataUnit(_ mac: String?) -> String? {
        let unit = mac! + ("updateUnit")
        let nuitcode = userDefaults.string(forKey: unit)
        if nuitcode != nil {
            return nuitcode
        } else {
            return nuitcode
        }
    }
}


