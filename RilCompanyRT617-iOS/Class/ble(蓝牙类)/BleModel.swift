//
//  BleModel.swift
//  TMW041RT
//
//  Created by RND on 2023/3/24.
//

import UIKit
import CoreBluetooth
import HandyJSON

class BleModel:NSObject{
    
    var mSelect = false
    
    //var id:Int?
    
    var deviceName:String?
    
    var deviceMAC:String?
    
    var deviceRssi: NSNumber?
    
    var date:Int?
    
    var deviceIsOnline:Bool?
    
    var mPeripheral: CBPeripheral?
    
    public var advertisementData: [String : Any]?
    
    var batteryLevel: String?
    
    var isExternalPower = false
    
    var hasTemperatureRecord = false
    
    var isTemperatureRecordOn = false
    
    var sdCardWorkingStatus = 0
    
    var sdCardStatus = 0
    
    //var devst: String?
    var temperatureValue : String?
    
    var readTempCharater:CBCharacteristic?
    
    var readUnitCharater:CBCharacteristic?
    
    var sendTimeDataCharater:CBCharacteristic?
    
    //发送ota数据
    var mSendotacharater: CBCharacteristic?
    
    // 设备采样时间间隔
    var intervalTime: String?
    
    // 设备温度记录间隔
    var intervalRecord: String?
    
    var centerManager : CBCentralManager?
    
    //
    var fileReq: [UInt8] = []
    
}
