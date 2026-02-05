//
//  TempViewController.swift
//  TMW041RT
//
//  Created by RND on 2023/3/28.
//

import UIKit
import SwiftEventBus
import Dispatch
import WHToast

class TempViewController:NavigationController{
    
    public var tempView = TempView()
    
    var index:Int?
    
    var communit = CommonUtil()
    
    var scanResultsList: LinkedHashMap<String, BleModel> = LinkedHashMap()
    
    var model = BleModel()
    
    var tempUnit:String?
    
    var current:Int? = 0
    
    var tempTimer:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startDateTimeTimer()
    }
    
    override func initView() {
        
        tempView = TempView(frame: self.view.bounds)
        self.view.addSubview(tempView)
        
    }
    //开始的时候
    override func viewWillAppear(_ animated: Bool) {
        initData()
    }
    
    //结束的时候
    override func viewWillDisappear(_ animated: Bool) {
        
        self.stopTimer()
        SwiftEventBus.unregister(self)
        
    }
    
    //初始化
    override func initData() {
        //显示到界面
        initTempData()
        // 得到蓝牙列表scanResults
        SwiftEventBus.onMainThread(self, name: "scanResults"){
            result in
            self.scanResultsList = result?.object as! LinkedHashMap<String, BleModel>
            
            for model in self.scanResultsList.list {
                
                if model.deviceMAC!.contains(self.model.deviceMAC!){
                    
                    self.model = model
                    
                    self.updateTempDate(model: self.model)
                }
            }
        }
    }
    
    func startDateTimeTimer(){
        self.tempTimer = Timer.scheduledTimer(withTimeInterval:10.0, repeats: true) { timer in
            print("我进行及时啦")
            self.saveTmpDB()
        }
    }
    
    
    func stopTimer() {
        self.tempTimer?.invalidate()
        self.tempTimer = nil
    }
    
    func initTempData(){
        //名称
        let index = model.deviceName!.index(model.deviceName!.startIndex, offsetBy: 8) // 获取数字开始位置索引
        let number = model.deviceName![index...] // 获取数字
        tempView.mNameLb.text = "Data Logger" + number // 修改名称
        
        let upperString = model.deviceMAC!.uppercased()
        tempView.mMacLb.text = "S/N:\(upperString)"
        
        tempView.mCircleVw.mTmpLb.text = communit.isTempScope(temp: model.temperatureValue!,unit: tempUnit!)
        tempView.mCircleVw.mUnitLb.text = tempUnit!
        
        //为真就是外部电源
        if model.isExternalPower{
            tempView.mExternalPower?.isHidden = false
            tempView.mBatLb.isHidden = true
            tempView.mExternalPower?.image = UIImage(named: "battery")
        }else{
            //否则电池电量
            tempView.mBatLb.isHidden = false
            tempView.mExternalPower?.isHidden = true
            tempView.mBatLb.text = "Battery:\(model.batteryLevel!)%"
        }
        
        //设备温度记录开关
        if model.isTemperatureRecordOn{
            tempView.mDeviceStateSw.isOn = true
        }else{
            tempView.mDeviceStateSw.isOn = false
        }
    }
    
    //保存到数据库模型
    func saveTmpDB(){
        let temp = TempModel()
        temp.mac = model.deviceMAC
        temp.bat = model.batteryLevel
        temp.tmp = model.temperatureValue
        
        let date = Date()
        let time = Int(date.timeIntervalSince1970)
        temp.time = time
        
        //目前暂时没有接收这三个值的，就默认
        temp.max = "0"
        temp.min = "0"
        temp.unit = tempUnit
        
        if(temp.tmp != nil){
            //存储数据到数据库
            //print("存储了温度值",temp.tmp)
            print("temp存储了时间值==",temp.time)
            TempDB.shared.saveTemp(temp)
            SwiftEventBus.post("chartTemp", sender: "0")
        }
    }
    
    //更新后的广播信息数据
    func updateTempDate(model: BleModel){
        // 判断是否离线
        self.current = Int(Date().timeIntervalSince1970)
        if self.current! - model.date! >= 16 {
            tempView.signalImage?.isHidden = false
            tempView.mCircleVw.mTmpOnlineLb.isHidden = false
            tempView.mCircleVw.mTmpLb.isHidden = true
            tempView.mCircleVw?.mUnitLb.isHidden = true
        }else{
            tempView.mCircleVw.mTmpLb.text = communit.isTempScope(temp: model.temperatureValue!,unit: tempUnit!)
            tempView.signalImage?.isHidden = true
            tempView.mCircleVw.mTmpOnlineLb.isHidden = true
            tempView.mCircleVw.mTmpLb.isHidden = false
            tempView.mCircleVw?.mUnitLb.isHidden = false
        }
        
        //为真就是外部电源
        if model.isExternalPower{
            tempView.mExternalPower?.isHidden = false
            tempView.mBatLb?.isHidden = true
            tempView.mExternalPower?.image = UIImage(named: "battery")
        }else{
            //否则电池电量
            tempView.mBatLb.isHidden = false
            tempView.mExternalPower?.isHidden = true
            tempView.mBatLb.text = "Battery:\(model.batteryLevel!)%"
        }
    }
    
    //界面消失的时候
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
}
