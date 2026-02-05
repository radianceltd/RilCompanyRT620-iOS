//
//  SetingContrller.swift
//  TMW041RT
//
//  Created by RND on 2023/5/17.
//

import UIKit
import SwiftEventBus
import WHToast
import MBProgressHUD

class SetingContrller: NavigationController,SettingViewProtocol,SettingCellDelegate,UpdateViewProtocol,UITableViewDelegate, UITableViewDataSource,UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    let MEVIEWCONTROLLERDATAVIEW = "MEVIEWCONTROLLERDATAVIEW"
    
    var settingView = SettingView() // 实例化SettingView
    
    var settingCell = SettingCell()
    
    var settingModel = SetingModel()
    
    var allExpanded = AllExpanded()
    
    private var hud:MBProgressHUD?
    
    var currentIndexPath:IndexPath?
    
    var mUptView:UpdateTimeView?
    
    var mSdtView:SettingDateTimeView?
    
    var mPopView:PopupAlartTip?
    
    var mSetBleInstructView:SetBleInstructView?
    
    var scanResultsList: LinkedHashMap<String, BleModel> = LinkedHashMap()
    
    var mSettingModel = SetingModel()
    
    var minute:String?
    var record:String?
    var timeIndex:Int?
    
    var lastFiveDigitsString:String?
    
    var isLongPressPop:Int?
    
    var isRecordSwitch:Bool?
    var sdCardWorkingStatus:Int?
    var sdCardStatus:Int?
    
    var tempSampling:String?
    var isTempListData:Int?
    
    var mac:String?
    var model:BleModel?
    
    private var mNames:Array<String>?
    private var mConImage:Array<String>?
    
    var settingPresenter = SettingPresenter()
    
    // 定义字典来存储映射关系
    //let indexMap: [Int: Int] = [0: 0x00, 1: 0x01, 2: 0x02, 3: 0x03, 4: 0x04, 5: 0x05]
    
    // 采样
    var sampleList = [TimeModel]()
    
    var communit = CommonUtil()
    
    // 记录
    var recordList = [TimeModel]()
    
    //判断开关
    var isOnAndOff:String?
    
    //判断符号
    var isTempCF:String?
    var hideHudTimer: Timer?
    //判断日期
    var isCurrentDate:String?
    
    //定时器，判断设备如果离线26秒，就进行断开
    var timer:Timer?
    var dataTimer:Timer?
    //定时器，判断界面进来10秒内是否有连接成功
    var cycyleTimer : Timer?
    
    var isOta:Bool?
    var isTempRecordDate:Bool?
    
    var yearData:String?
    var monthData:String?
    var dayData:String?
    var minuteData:String?
    var secondData:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        aboutNavigationLeft(isBack: true)
        
        //导航栏中间的标题
        aboutNavigationCenter(title: "Setting")
        
        setupSubviews()
        
        // 创建一个定时器 扫描（）
        startConnectTimer()
        
        //创建加载框
        showHud()
        
    }
    
    //失去界面的回调生命周期
    override func viewWillDisappear(_ animated: Bool) {
        
        self.stopTimer()
        isOta = false
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        removeCycleTimer()
        CFRunLoopStop(CFRunLoopGetCurrent())
    }
    
    //视图将要显示
    override func viewWillAppear(_ animated: Bool) {
        isOta = true
    }
    
    //视图已经显示
    override func viewDidAppear(_ animated: Bool) {
        //定时器时间日期每5秒进行刷新获取设备数据
        self.startDateTimeTimer()
        //        print("我是hasTemperatureRecord开关按钮啦啦啦：======",model?.hasTemperatureRecord as Any)
        //        print("我是开关按钮啦啦啦isTemperatureRecordOn：======",model?.isTemperatureRecordOn as Any)
    }
    
    //
    override func initData() {
        
        self.isTempRecordDate = true
        
        self.timer = Timer.scheduledTimer(withTimeInterval:3.0, repeats: false) { timer in
            self.sendBleParamete(ains: 0x09, alen: 0,stringP:"Temp Sampling",indexInt: 13,islongPress: -1)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.sendBleParamete(ains: 0x09, alen: 0,stringP:"Temp Sampling",indexInt: 13,islongPress: -1)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.sendBleParamete(ains: 0x09, alen: 0,stringP:"Temp Sampling",indexInt: 13,islongPress: -1)
                }
            }
            
            self.timer?.invalidate()
            //self.stopTimer()
        }
        
        self.sdCardWorkingStatus = model!.sdCardWorkingStatus
        self.sdCardStatus = model!.sdCardStatus
        self.isRecordSwitch = model!.isTemperatureRecordOn
        
        self.isTempListData = -1
        
        if minute == nil{
            minute = "2";
        }
        
        if record == nil{
            record = "10";
        }
        
        if self.isRecordSwitch!{
            isOnAndOff = "ON"
        }else{
            isOnAndOff = "OFF"
        }
        
        if isTempCF == "°C"{
            isTempCF = "°C"
        }else{
            isTempCF = "°F"
        }
        
        mNames = settingModel.getNames()
        mConImage = settingModel.getImages()
        
        // 获取数据数据
        sampleList = settingModel.getSmapleTimes()
        recordList = settingModel.getRecordTimes()
        
        SwiftEventBus.onMainThread(self, name: "scanResults"){
            result in
            self.scanResultsList = result?.object as! LinkedHashMap<String, BleModel>
            
            for model in self.scanResultsList.list {
                if model.deviceMAC!.contains(self.model!.deviceMAC!){
                    self.model = model
                    self.sdCardWorkingStatus = model.sdCardWorkingStatus
                    self.sdCardStatus = model.sdCardStatus
                    print("self.sdCardStatus======",self.model?.sdCardStatus as Any)
                    //当广播实时更新时，状态的按钮也进行更新
                    if self.model!.isTemperatureRecordOn{
                        self.isRecordSwitch = true
                        self.isOnAndOff = "ON"
                    }else{
                        self.isRecordSwitch = false
                        self.isOnAndOff = "OFF"
                    }
                }
            }
            
            self.settingView.tableView?.reloadData()
        }
        
        SwiftEventBus.onMainThread(self, name: "TEMPSAMPLINGINTERVAL") { result in
            if let interval = result?.object as? String {
                print("tempsampling==", interval)
                
                let components = interval.components(separatedBy: ",")
                
                // 解析温度采样、温度记录和日期时间的值
                if self.isTempListData == 13 {
                    if components.count >= 8 {
                        let tempSamplingInterval = components[2]
                        let temperatureRecordInterval = components[3]
                        let dateTimeComponents = components[4...8].reversed().map { String($0) }
                        let minute = dateTimeComponents[4]
                        var formattedMinute = ""
                        if let minuteInt = Int(minute), minuteInt < 10 {
                            formattedMinute = "0\(minuteInt)"
                        } else {
                            formattedMinute = minute
                        }
                        let dateTime = "20" + dateTimeComponents[0] + "-" + dateTimeComponents[1] + "-" + dateTimeComponents[2] + " " + dateTimeComponents[3] + ":" + formattedMinute
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-M-d"
                        let currentDateString = dateFormatter.string(from: Date())
                        
                        let tempSamplingdata = "20\(dateTimeComponents[0])-\(dateTimeComponents[1])-\(dateTimeComponents[2])"
                        print("111111==",tempSamplingdata)
                        if self.isTempRecordDate!{
                            if tempSamplingdata == currentDateString {
                                print("相等啦啦啦～11")
                            } else {
                                self.isTempRecordDate = false
                                self.examineTimeDate()
                            }
                        }
                        
                        //初始进入的时候判断按钮开关是否打开
                        let recordIntervalSwitch = components[10]
                        if let boolValue = Int(recordIntervalSwitch), boolValue == 1 {
                            self.isRecordSwitch = true
                            self.isOnAndOff = "ON"
                        }else{
                            self.isRecordSwitch = false
                            self.isOnAndOff = "OFF"
                        }
                        self.parseTempSamplingInterval(tempSamplingInterval)
                        self.parseTemperatureRecordInterval(temperatureRecordInterval)
                        self.parseDateTime(dateTime)
                        self.hidHud()
                    }
                }
                
                // 解析单个功能的值
                if self.isTempListData == 0 || self.isTempListData == 1 {
                    if components.count >= self.isTempListData! + 1 {
                        let intervalValue = components[self.isTempListData!]
                        
                        if self.isTempListData == 0 {
                            self.parseTempSamplingInterval(intervalValue)
                        } else if self.isTempListData == 1 {
                            self.parseTemperatureRecordInterval(intervalValue)
                        }
                    }
                }
                
                if self.isTempListData == 6 {
                    // 处理日期初始化查询
                    if components.count > 4 {
                        self.yearData = components[4]
                        self.monthData = components[3]
                        self.dayData = components[2]
                        self.minuteData = components[1]
                        self.secondData = components[0]
                        
                        //用于判断定时器当前时间和设备时间不同的情况下更新日期
                        if let secondInt = Int(self.secondData!), secondInt < 10 {
                            let secondString = String(format: "%02d", secondInt)
                            self.tempSampling = "20\(self.yearData!)-\(self.monthData!)-\(self.dayData!) \(self.minuteData!):\(secondString)"
                        } else {
                            self.tempSampling = "20\(self.yearData!)-\(self.monthData!)-\(self.dayData!) \(self.minuteData!):\(self.secondData!)"
                        }
                       
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        let currentDateString = dateFormatter.string(from: Date())
                        
                        let tempSamplingdata = "20\(self.yearData!)-\(self.monthData!)-\(self.dayData!)"
                        print("222222==",tempSamplingdata)
                        if tempSamplingdata == currentDateString {
                            print("相等啦啦啦～")
                        } else {
                            //self.examineTimeDate()
                        }
                    }
                }
                
                self.settingView.tableView?.reloadData()
                print("wo==0")
                // 判断弹窗
                if let isLongPressPop = self.isLongPressPop, isLongPressPop >= 0 {
                    self.popTipDate(titles: "通知数据信息:")
                }
            }
        }
        
        
        SwiftEventBus.onMainThread(self, name: "successDevice"){
            result in
            self.scanResultsList = result?.object as! LinkedHashMap<String, BleModel>
        }
        
        SwiftEventBus.onMainThread(self, name: "disconnectEvent"){
            result in
            let modelx = result?.object as! BleModel
            //类型相当 用 === 去判断
            if modelx === self.model {
                //断开返回界面
                //启动定时器
                if self.isOta!{
                    self.startTimer()
                }
            }else{
                //WHToast.showMessage("Device is disconnect!", originY: 500, duration: 2, finishHandler: nil)
            }
        }
    }
    
    func parseTempSamplingInterval(_ interval: String) {
        print("WO==2")
        switch interval {
        case "0":
            self.minute = "2"
        case "1":
            self.minute = "5"
        case "2":
            self.minute = "10"
        case "3":
            self.minute = "30"
        case "4":
            self.minute = "60"
        case "5":
            self.minute = "600"
        default:
            break
        }
    }
    
    func parseTemperatureRecordInterval(_ interval: String) {
        print("WO==3")
        switch interval {
        case "0":
            self.record = "5"
        case "1":
            self.record = "10"
        case "2":
            self.record = "30"
        case "3":
            self.record = "60"
        default:
            break
        }
    }
    
    func parseDateTime(_ dateTime: String) {
        print("WO==4")
        //用于判断新进入此界面，获取到日期时间，同步到列表文本进行显示
        self.tempSampling = dateTime
    }
    
    func startDateTimeTimer(){
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            dataTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                
                // 在这里放置定时器触发时执行的代码
                print("我进行及时啦")
                self.sendBleParamete(ains: 0x04, alen: 0,stringP:"DateTime",indexInt:6,islongPress: -1)
                
            }
            RunLoop.current.run()
        }
    }
    
    func startConnectTimer() {
        
        cycyleTimer = Timer.scheduledTimer(withTimeInterval: 12, repeats: false) { cycyleTimer in
            // 停止定时器
            self.cycyleTimer?.invalidate()
            
            // 在这里放置定时器触发时执行的代码
            self.update()
        }
        
    }
    
    func startTimer() {
        // 每秒触发一次计时器事件
        timer = Timer.scheduledTimer(withTimeInterval:26.0, repeats: false) { timer in
            // 在计时器触发时执行的代码
            //print("计时器触发")
            // Do something...
            // 重新连接设备的逻辑
            //centralManager.connect(peripheral, options: nil)
            
            //断开所有的蓝牙
            BleManager.shared.disConnectBle()
            
            SwiftEventBus.unregister(self)
            //断开界面
            for controller in self.navigationController?.viewControllers ?? [] {
                if (controller is BleDeviceController) {
                    let vc = controller as? BleDeviceController
                    if let vc = vc {
                        print("accutherm:==我设置断开退出啦")
                        
                        self.navigationController?.popToViewController(vc, animated: true)
                    }
                }
            }
            
            let uppercaseString = self.model!.deviceMAC!.uppercased()
            WHToast.showMessage("Device \(uppercaseString) disconnect!", originY: 500, duration: 2, finishHandler: nil)
        }
    }
    
    @objc func update() {
        print("我是定时器10")
        if self.scanResultsList.size() < 1 || self.model?.mSendotacharater == nil {
            BleManager.shared.disConnectBle()
            //SwiftEventBus.unregister(self)
            //断开界面
            for controller in self.navigationController?.viewControllers ?? [] {
                if (controller is BleDeviceController) {
                    let vc = controller as? BleDeviceController
                    if let vc = vc {
                        print("accutherm:==我设置断开退出啦")
                        
                        self.navigationController?.popToViewController(vc, animated: true)
                    }
                }
            }
            
            let uppercaseString = self.model!.deviceMAC!.uppercased()
            WHToast.showMessage("Device \(uppercaseString) disconnect!", originY: 500, duration: 2, finishHandler: nil)
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        dataTimer?.invalidate()
        dataTimer = nil
    }
    
    func setupSubviews() {
        
        let view = UIView()
        settingView.delegate = self
        settingView.tableView?.delegate = self
        settingView.tableView?.dataSource = self
        settingView.tableView?.tableFooterView = view
        settingView.frame = self.view.bounds
        self.view.addSubview(settingView)
        
    }
    
    //显示
    func showHud(){
        hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.bezelView.style = .solidColor
        hud?.bezelView.color = UIColor.black.withAlphaComponent(0.7)
        hud?.label.text = NSLocalizedString("Loading...", comment: "HUD loading title")
        hud?.contentColor = UIColor.white
        //正常情况下是10秒后消失
        hideHudTimer = Timer.scheduledTimer(withTimeInterval: 12.0, repeats: false) { [weak self] _ in
            self?.hidHud()
        }
    }
    
    //隐藏
    func hidHud(){
        hideHudTimer?.invalidate()
        hud?.hide(animated: true, afterDelay: 0.5)
    }
    
    //首次检查日期是否是今日
    func examineTimeDate(){
        let tips = "Tips"
        let cancel = "Cancel"
        let ok = "Confirm"
        
        let alertController = UIAlertController(title: tips, message: "Please select the current date and time!", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: ok, style: .default, handler: { action in
            //查询应用程序版本
            self.clickDateTime(titles:"Set DateTime",index: 6)
            
        })
        let noAction = UIAlertAction(title: cancel, style: .cancel, handler: { action in
        })
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        self.present(alertController, animated: true)
    }
    
    
    //长按监听列表数据
    func onSetChangEvent(withRow row: Int){
        print("aa==",row)
        
        if row == 0{
            //self.sendBleParamete(ains: 0x01, alen: 0,stringP:"Temp Sampling",indexInt: row,islongPress: 1)
        }else if row == 1{
            //self.sendBleParamete(ains: 0x02, alen: 0,stringP:"Temp Record",indexInt: row,islongPress: 1)
        }
        //        else if row == 6{
        //            self.sendBleParamete(ains: 0x04, alen: 0,stringP:"DateTime",indexInt:row,islongPress: 1)
        //        }
        //        else if row == 6{
        //            self.sendBleParamete(ains: 0x06, alen: 0,stringP:"DateTime",indexInt: row,islongPress: 1)
        //        }
        else if row == 8{
            self.sendBleParamete(ains: 0x07, alen: 0,stringP:"Ble Instruct",indexInt: row,islongPress: 1)
        }else if row == 9{
            self.sendBleParamete(ains: 0x08, alen: 0,stringP:"Interval Parameter",indexInt: row,islongPress: 1)
        }
        
    }
}

extension SetingContrller{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 155
        } else if indexPath.section == 1 {
            return 65
        } else {
            return 0
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return mNames!.count
        }
        return 0
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: MEVIEWCONTROLLERDATAVIEW) as? SettingCell
        if cell == nil {
            cell = SettingCell(style: .default, reuseIdentifier: MEVIEWCONTROLLERDATAVIEW)
            cell!.selectionStyle = .none
            cell!.delegate = self
        }
        
        switch indexPath.section {
        case 0:
            cell!.topView?.isHidden = false
            cell!.conView?.isHidden = true
            cell!.tempText?.text = communit.isTempScope(temp: model!.temperatureValue!, unit: isTempCF!)
            
            if model!.deviceName == nil{
                model!.deviceName = "Data Logger"
            }
            
            //名称
            let deviceName = model!.deviceName! // 假设 deviceName 为 "RAD25984"
            
            // 获取从第4个位置开始到结尾的子字符串
            let lastFiveDigits = deviceName.suffix(5)
            
            // 如果需要将后5位作为数字（比如 "25984"）
            lastFiveDigitsString = String(lastFiveDigits)
            
            // 修改名称
            cell!.mSettingName?.text = "RAD" + lastFiveDigitsString!
            
            //MAC
            cell!.mSettingMac?.text = "S/N:\(model!.deviceMAC!.uppercased())"
            cell!.mSettingUnit?.text = isTempCF
            
            if model!.isExternalPower{
                cell?.mSettingBatteryImage?.isHidden = false
                cell?.mSettingBatteryLb?.isHidden = true
            }else{
                cell?.mSettingBatteryImage?.isHidden = true
                cell?.mSettingBatteryLb?.isHidden = false
                if let batteryLevel = model?.batteryLevel, let batteryLevelInt = Int(batteryLevel) {
                    if batteryLevelInt > 100 {
                        cell?.mSettingBatteryLb?.isHidden = true
                        cell?.mSettingBatteryImage?.isHidden = false
                    } else {
                        cell?.mSettingBatteryImage?.isHidden = true
                        cell?.mSettingBatteryLb?.isHidden = false
                        cell?.mSettingBatteryLb?.text = "\(batteryLevel)%"
                    }
                } else {
                    cell?.mSettingBatteryLb?.text = "N/A"
                }
            }
            
            
        case 1:
            cell!.topView?.isHidden = true
            cell!.conView?.isHidden = false
            
            //列表的索引
            switch indexPath.row {
            case 0:
                cell!.mRightTextLb?.isHidden = false
                cell!.mRightSwitch?.isHidden = true
                cell!.mRightUnitSwitch?.isHidden = true
                cell!.mRightSwitchText?.isHidden = true
                cell!.mSettingUnitLift?.isHidden = true
                cell!.mRightUnitButton?.isHidden = true
                cell!.mRightTextLb?.text = "\(minute ?? "2")S"
            case 1:
                cell!.mRightTextLb?.isHidden = false
                cell!.mRightSwitch?.isHidden = true
                cell!.mRightUnitSwitch?.isHidden = true
                cell!.mRightSwitchText?.isHidden = true
                cell!.mSettingUnitLift?.isHidden = true
                cell!.mRightUnitButton?.isHidden = true
                cell!.mRightTextLb?.text = "\(record ?? "10")M"
            case 2:
                cell!.mRightTextLb?.isHidden = true
                cell!.mRightSwitch?.isHidden = false
                cell!.mRightUnitSwitch?.isHidden = true
                cell!.mRightSwitchText?.isHidden = false
                cell!.mSettingUnitLift?.isHidden = true
                cell!.mRightUnitButton?.isHidden = true
                cell!.mRightSwitchText?.text = isOnAndOff
            case 3:
                cell!.mRightTextLb?.isHidden = true
                cell!.mRightSwitch?.isHidden = true
                cell!.mRightUnitSwitch?.isHidden = true
                cell!.mRightUnitButton?.isHidden = false
                //温度符号的默认值显示
                if self.isTempCF == "°C"{
                    // cell!.mRightUnitSwitch?.isOn = false
                    cell?.mRightUnitButton?.setImage(UIImage(named: "off"), for: .normal)
                }else{
                    //cell!.mRightUnitSwitch?.isOn = true
                    cell?.mRightUnitButton?.setImage(UIImage(named: "on"), for: .normal)
                }
                
                cell!.mRightSwitchText?.isHidden = false
                cell!.mSettingUnitLift?.isHidden = false
                cell!.mRightSwitchText?.text = "°F"
            case 4:
                cell!.mRightTextLb?.isHidden = true
                cell!.mRightSwitch?.isHidden = true
                cell!.mRightUnitSwitch?.isHidden = true
                cell!.mRightSwitchText?.isHidden = true
                cell!.mSettingUnitLift?.isHidden = true
                cell!.mRightUnitButton?.isHidden = true
            case 5:
                cell!.mRightTextLb?.isHidden = true
                cell!.mRightSwitch?.isHidden = true
                cell!.mRightUnitSwitch?.isHidden = true
                cell!.mRightSwitchText?.isHidden = true
                cell!.mSettingUnitLift?.isHidden = true
                cell!.mRightUnitButton?.isHidden = true
            case 6:
                cell!.mRightTextLb?.isHidden = true
                cell!.mRightSwitch?.isHidden = true
                cell!.mRightUnitSwitch?.isHidden = true
                cell!.mSettingUnitLift?.isHidden = true
                cell!.mRightSwitchText?.isHidden = false
                cell!.mRightUnitButton?.isHidden = true
                cell!.mRightSwitchText?.text = tempSampling
            case 7:
                cell!.mRightTextLb?.isHidden = true
                cell!.mRightSwitch?.isHidden = true
                cell!.mRightUnitSwitch?.isHidden = true
                cell!.mRightSwitchText?.isHidden = true
                cell!.mSettingUnitLift?.isHidden = true
                cell!.mRightUnitButton?.isHidden = true
            case 8:
                cell!.mRightTextLb?.isHidden = true
                cell!.mRightSwitch?.isHidden = true
            case 9:
                cell!.mRightTextLb?.isHidden = true
                cell!.mRightSwitch?.isHidden = true
            case 10:
                cell!.mRightTextLb?.isHidden = true
                cell!.mRightSwitch?.isHidden = true
            default:
                break
            }
            
            //print("WO==我刷新啦啦啦！！")
            
            cell!.mConLb?.text = mNames?[indexPath.row]
            cell!.mConImage?.image = UIImage(named: (mConImage?[indexPath.row])!)
            
            //温度记录开关
            if self.isRecordSwitch!{
                
                cell!.mRightSwitch?.isOn = true
                
            }else{
                cell!.mRightSwitch?.isOn = false
            }
            
        default:
            break
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                clickSendTime(list: sampleList,indexList: "0")
            case 1:
                clickSendTime(list: recordList,indexList: "1")
            case 2:
                print( "温度记录开关")
            case 3:
                print( "切换温度符号")
            case 4:
                let pdf = PDFViewController()
                pdf.model = self.model!
                // 执行其他操作以为pdf设置属性
                isPdfAndCsvOpen(recordSwitch: self.isRecordSwitch, message: "Want to view a pdf file?", controller: pdf)
            case 5:
                let csv = CSVViewController()
                csv.model = self.model!
                isPdfAndCsvOpen(recordSwitch: self.isRecordSwitch, message: "Want to view a csv file?", controller: csv)
            case 6:
                //print( "3")
                currentIndexPath = indexPath
                clickDateTime(titles:"Set DateTime",index: indexPath.row)
                //                let ins: UInt8 = 0x04
                //                let len: UInt8 = 5
                //调取时间的方法函数
                
                //                let data: [UInt8] = [0x0F7, 0x02, 0x17, 0x09, 0x0C]
                //                let packet = self.buildInstructionPacket(ins: ins, len: len, data: data)
                //
                //                let hexString = self.hexadecimalString(from: packet)
                //                print(hexString)
                //
                //                BleManager.shared.writeValue(packet, self.model?.mSendotacharater, self.model?.mPeripheral)
                //allExpanded.setDateTime(minute: minute, hour: hour, day: day, month: month, year: year)
            case 7:
                
                print( "进入OTA模式")
                
                if(readSandBoxFile()){
                    let tips = "Tips"
                    let cancel = "Cancel"
                    let ok = "Confirm"
                    
                    let alertController = CleanAlertController(title: tips, message: "OTA UpGrade", preferredStyle: .alert)
                    
                    let noAction = UIAlertAction(title: cancel, style: .cancel, handler: { action in
                    })
                    
                    let yesAction = UIAlertAction(title: ok, style: .default, handler: { action in
                        //ota升级
                        let ins: UInt8 = 0xFF
                        let len: UInt8 = 4
                        let data: [UInt8] = [0x5A,0xA5,0x67,0x76]
                        let packet = self.allExpanded.buildInstructionPacket(ins: ins, len: len, data: data)
                        
                        let hexString = self.allExpanded.hexadecimalString(from: packet)
                        print(hexString)
                        
                        BleManager.shared.writeValue(packet, self.model?.mSendotacharater, self.model?.mPeripheral)
                        
                        var target: UIViewController? = nil
                        for controller in self.navigationController?.viewControllers ?? [] {
                            //遍历
                            if (controller is BleDeviceController) {
                                //这里判断是否为你想要跳转的页面
                                target = controller
                                //BleManager.shared.disConnectBle()
                                
                                SwiftEventBus.unregister(self)
                            }
                        }
                        if target != nil {
                            if let target = target {
                                self.navigationController?.popToViewController(target, animated: true)
                            } //跳转
                        }
                        
                        
                    })
                    
                    alertController.addAction(noAction)
                    alertController.addAction(yesAction)
                    present(alertController, animated: true)
                }else{
                    WHToast.showMessage("There are no OTA files yet!", originY: 500, duration: 2, finishHandler: nil)
                }
                
            case 8:
                //print( "5")
                let tips = "Tips"
                let cancel = "Cancel"
                let ok = "Confirm"
                
                let alertController = CleanAlertController(title: tips, message: "Are you sure to query the device application version instruction?", preferredStyle: .alert)
                
                let noAction = UIAlertAction(title: cancel, style: .cancel, handler: { action in
                })
                
                let yesAction = UIAlertAction(title: ok, style: .default, handler: { action in
                    //查询应用程序版本
                    self.sendBleParamete(ains: 0x06, alen: 0,stringP:"application version",indexInt: indexPath.row,islongPress: 1)
                    
                })
                
                alertController.addAction(noAction)
                alertController.addAction(yesAction)
                present(alertController, animated: true)
            case 9:
                let tips = "Tips"
                let cancel = "Cancel"
                let ok = "Confirm"
                
                let alertController = CleanAlertController(title: tips, message: "Are you sure to run the query device status command?", preferredStyle: .alert)
                
                let noAction = UIAlertAction(title: cancel, style: .cancel, handler: { action in
                })
                
                let yesAction = UIAlertAction(title: ok, style: .default, handler: { action in
                    //查询设备状态指令
                    
                    self.sendBleParamete(ains: 0x05, alen: 0,stringP:"Device Status",indexInt: indexPath.row,islongPress: 1)
                    
                })
                
                alertController.addAction(noAction)
                alertController.addAction(yesAction)
                present(alertController, animated: true)
            case 10:
                clickSetBleInstruct(titles:"Set Ble-Instruct",adv_one:"ADV_INTV",adv_two:"ADV_TIME",adv_three:"CONN_MIN_INTV",adv_four:"CONN_MAX_INTV",index: indexPath.row)
            case 11:
                clickSetBleInstruct(titles:"Set Interval Parameter",adv_one:"ADV_INTV0",adv_two:"ADV_INTV1",adv_three:"ADV_EV_TIMES",adv_four:"ADV_PERIOD",index: indexPath.row)
            default : /* 可选 */
                print( "meiyouxuanzhel")
            }
        }
    }
    
    func showViewController(_ viewController: UIViewController) {
        // 在这里进行跳转到指定的视图控制器
        // 例如，使用导航控制器进行跳转
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func isPdfAndCsvOpen(recordSwitch: Bool?, message: String?, controller: UIViewController?) {
        if let recordSwitch = recordSwitch, let viewController = controller {
            //判断温度记录开关是否打开
            if self.sdCardStatus == 1 && self.sdCardWorkingStatus == 0{
                //                if recordSwitch {
                //
                //                    let tips = "Tips"
                //                    let cancel = "Cancel"
                //
                //                    let alertController = CleanAlertController(title: tips, message: "You must turn off the temperature recording switch to view SD card files", preferredStyle: .alert)
                //
                //                    let noAction = UIAlertAction(title: cancel, style: .cancel, handler: { action in
                //                    })
                //
                //                    alertController.addAction(noAction)
                //                    self.present(alertController, animated: true)
                //                } else {
                //print("false")
                let tips = "Tips"
                let cancel = "Cancel"
                let ok = "Confirm"
                
                let alertController = CleanAlertController(title: tips, message: message, preferredStyle: .alert)
                
                let noAction = UIAlertAction(title: cancel, style: .cancel, handler: { action in
                })
                
                let yesAction = UIAlertAction(title: ok, style: .default, handler: { action in
                    
                    self.showViewController(viewController)
                })
                
                alertController.addAction(noAction)
                alertController.addAction(yesAction)
                self.present(alertController, animated: true)
                // }
            }else{
                WHToast.showMessage("SD card not inserted or read incorrectl", originY: 500, duration: 2, finishHandler: {
                })
            }
        }
    }
    
    //读取沙盒中的文件
    func readSandBoxFile() -> Bool{
        
        var list = [FileModel]()
        
        let documentPaths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).map(\.path)
        let documentsDirPath = documentPaths[0]
        let fm = FileManager.default
        var dirContents: [String]? = nil
        do {
            dirContents = try fm.contentsOfDirectory(atPath: documentsDirPath)
        } catch {
            print("Get File Error!")
        }
        
        //自定义过滤器
        let predicate = NSPredicate(format: "pathExtension == 'zip'")
        
        //过滤数据
        let fileNameArray = dirContents?.filter({
            return predicate.evaluate(with: $0)
        })
        
        for filename in fileNameArray! {
            if(filename.contains("RT617")){
                let model = FileModel()
                model.filename = filename
                model.filepath = documentsDirPath
                list.append(model)
            }
        }
        
        if list.count>0 {
            return true
        }else{
            return false
        }
    }
    
    func didTapRightUnitButton(){
        
        if isTempCF == "°F" {
            isTempCF = "°C"
            CommonDefaults.shared.saveValue("°C", forKey: UNIT)
            
        }else{
            isTempCF = "°F"
            CommonDefaults.shared.saveValue("°F", forKey: UNIT)
        }
        
        self.settingView.tableView?.reloadData()
    }
    
    //发送指令参数
    func sendBleParamete(ains:UInt8,alen:UInt8,stringP:String,indexInt:Int,islongPress:Int){
        //这段代码只是临时的隐藏了，切记还是需要使用的
        let ins: UInt8 = ains
        let len: UInt8 = alen
        
        let packet = self.allExpanded.queryDeviceData(ins: ins, len: len)
        
        let hexString = self.allExpanded.hexadecimalString(from: packet)
        print(hexString)
        
        BleManager.shared.writeValue(packet, self.model?.mSendotacharater, self.model?.mPeripheral)
        
        self.isTempListData = indexInt
        
        //判断是否是初次进入，是否要弹窗，因为进入界面就查询了3个参数，默认是查询但不弹窗
        self.isLongPressPop = islongPress
        
        if self.isLongPressPop! >= 0{
            WHToast.showMessage("query \(stringP) success!", originY: 500, duration: 2, finishHandler: {
            })
        }
    }
    
    func backController(){
        var target: UIViewController? = nil
        for controller in self.navigationController?.viewControllers ?? [] {
            //遍历
            if (controller is BleDeviceController) {
                //这里判断是否为你想要跳转的页面
                target = controller
            }
        }
        if target != nil {
            if let target = target {
                //断开所有的蓝牙
                BleManager.shared.disAllConnectBle()
                SwiftEventBus.unregister(self)
                self.navigationController?.popToViewController(target, animated: true)
            } //跳转
        }
    }
    
    
    // 生成 CRC 校验码
    func calculateCRC(data: [UInt8]) -> UInt8 {
        var crc: UInt8 = 0
        
        // 计算校验和
        for byte in data {
            crc ^= byte
            for _ in 0..<8 {
                if (crc & 0x80) != 0 {
                    crc = (crc << 1) ^ 0x31
                } else {
                    crc <<= 1
                }
            }
        }
        
        return crc
    }
    
    
    //pickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var result = 0
        if mUptView != nil{
            if pickerView == mUptView!.mMinutePicker {
                
                // 判断当前是哪个UIPickerView
                if let indexPath = currentIndexPath, indexPath.row == 0 {
                    // 如果是第一行，则返回mSettingModel.getMinute().count
                    result = mSettingModel.getMinute().count
                } else {
                    // 否则返回其他数据
                    result = mSettingModel.getRecord().count
                }
            }
        }
        return result
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if mUptView != nil{
            if pickerView == mUptView!.mMinutePicker {
                timeIndex = row
                if let indexPath = currentIndexPath, indexPath.row == 0 {
                    // 如果是第一行，则返回mSettingModel.getMinute().count
                    minute = mSettingModel.getMinute()[row]
                } else {
                    // 否则返回其他数据
                    record = mSettingModel.getRecord()[row]
                }
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let label = UILabel(frame: CGRect(x: Double(300 * component) / 6.0, y: 0, width: 300 / 6.0, height: 30))
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.tag = component * 100 + row
        label.textAlignment = .center
        
        if mUptView != nil{
            if pickerView == self.mUptView!.mMinutePicker! {
                label.textAlignment = .right
                if let indexPath = currentIndexPath, indexPath.row == 0 {
                    // 如果是第一行，则返回mSettingModel.getMinute().count
                    label.text = mSettingModel.getMinute()[row]
                } else {
                    // 否则返回其他数据
                    label.text = mSettingModel.getRecord()[row]
                }
            }
        }
        return label.text
    }
    
    //设置蓝牙参数指令
    func clickSetBleInstruct(titles: String,adv_one:String,adv_two:String,adv_three:String,adv_four:String,index: Int){
        mSetBleInstructView = SetBleInstructView(title: titles, p_name: adv_one,p_name1: adv_two,p_name2: adv_three,p_name3: adv_four, p_tf: "Input value")
        
        var advintv:String?
        var advtime:String?
        var connminintv:String?
        var connmaxintv:String?
        var inde_Ins:UInt8?
        
        if index == 8{
            inde_Ins = 0x07
            
            //获取存储的值
            advintv =  CommonDefaults.shared.getValue(ADVINTV)
            advtime =  CommonDefaults.shared.getValue(ADVTIME)
            connminintv =  CommonDefaults.shared.getValue(CONNMININTV)
            connmaxintv =  CommonDefaults.shared.getValue(CONNMAXINTV)
            
            //默认值
            if advintv == nil{
                advintv = "3"
            }
            if advtime == nil{
                advtime = "1"
            }
            if connminintv == nil{
                connminintv = "3"
            }
            if connmaxintv == nil{
                connmaxintv = "4"
            }
        }else{
            inde_Ins = 0x08
            //获取存储的值
            advintv =  CommonDefaults.shared.getValue(ADVINTV_PARAMETER)
            advtime =  CommonDefaults.shared.getValue(ADVTIME_PARAMETER)
            connminintv =  CommonDefaults.shared.getValue(CONNMININTV_PARAMETER)
            connmaxintv =  CommonDefaults.shared.getValue(CONNMAXINTV_PARAMETER)
            
            //默认值
            if advintv == nil{
                advintv = "32"
            }
            if advtime == nil{
                advtime = "1"
            }
            if connminintv == nil{
                connminintv = "50"
            }
            if connmaxintv == nil{
                connmaxintv = "10"
            }
        }
        
        //显示读取到存储的值
        mSetBleInstructView!.commonTf_intv?.text = advintv
        mSetBleInstructView!.commonTf_time?.text = advtime
        mSetBleInstructView!.commonTf_min_intv?.text = connminintv
        mSetBleInstructView!.commonTf_max_intv?.text = connmaxintv
        
        // 点击确认的时候
        mSetBleInstructView?.clickSureBtn({ [self] _ in
            let ins: UInt8 = inde_Ins!
            let len: UInt8 = 4
            
            let a = mSetBleInstructView!.commonTf_intv?.text
            let b = mSetBleInstructView!.commonTf_time?.text
            let c = mSetBleInstructView!.commonTf_min_intv?.text
            let d = mSetBleInstructView!.commonTf_max_intv?.text
            
            // 将 a 转换为 0x00 格式的 UInt8
            let aValue: UInt8 = a != nil ? UInt8(a!) ?? 0x00 : 0x00
            
            // 将 b 转换为 0x00 格式的 UInt8
            let bValue: UInt8 = b != nil ? UInt8(b!) ?? 0x00 : 0x00
            
            // 将 a 转换为 0x00 格式的 UInt8
            let cValue: UInt8 = c != nil ? UInt8(c!) ?? 0x00 : 0x00
            
            // 将 b 转换为 0x00 格式的 UInt8
            let dValue: UInt8 = d != nil ? UInt8(d!) ?? 0x00 : 0x00
            
            // 创建 data 数组，存储 aValue 和 bValue
            let data: [UInt8] = [aValue,bValue,cValue,dValue]
            
            // 输出 data 数组的内容
            for value in data {
                print(String(format: "0x%02X", value))
            }
            //
            let packet = self.allExpanded.buildInstructionPacket(ins: ins, len: len, data: data)
            let hexString = self.allExpanded.hexadecimalString(from: packet)
            print(hexString)
            
            BleManager.shared.writeValue(packet, self.model?.mSendotacharater, self.model?.mPeripheral)
            
            if index == 8{
                CommonDefaults.shared.saveValue(mSetBleInstructView!.commonTf_intv?.text, forKey: ADVINTV)
                CommonDefaults.shared.saveValue(mSetBleInstructView!.commonTf_time?.text, forKey: ADVTIME)
                CommonDefaults.shared.saveValue(mSetBleInstructView!.commonTf_min_intv?.text, forKey: CONNMININTV)
                CommonDefaults.shared.saveValue(mSetBleInstructView!.commonTf_max_intv?.text, forKey: CONNMAXINTV)
            }else{
                CommonDefaults.shared.saveValue(mSetBleInstructView!.commonTf_intv?.text, forKey: ADVINTV_PARAMETER)
                CommonDefaults.shared.saveValue(mSetBleInstructView!.commonTf_time?.text, forKey: ADVTIME_PARAMETER)
                CommonDefaults.shared.saveValue(mSetBleInstructView!.commonTf_min_intv?.text, forKey: CONNMININTV_PARAMETER)
                CommonDefaults.shared.saveValue(mSetBleInstructView!.commonTf_max_intv?.text, forKey: CONNMAXINTV_PARAMETER)
            }
            
            print("sendTime and Time!!==")
        })
    }
    
    //弹窗提示通知数据
    func popTipDate(titles: String) {
        mPopView = PopupAlartTip(title: titles, p_name: "Value:", p_tf: "Please Input value")
        
        if isTempListData == 0{
            mPopView!.commonTf_y?.text = self.minute!
        }else if isTempListData == 1{
            mPopView!.commonTf_y?.text = self.record!
        }else{
            mPopView!.commonTf_y?.text = self.tempSampling!
        }
        
        // 点击确认的时候
        mSdtView?.clickSureBtn({ [self] _ in
            print("sendData and Pop!!==")
        })
    }
    
    //设置时间日期
    func clickDateTime(titles: String, index: Int) {
        let view = DatePickerView(frame: UIScreen.main.bounds, name: "datePicker")
        // 设置默认选中的年月日时分
        
        view.contenView = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height - 230, width: UIScreen.main.bounds.size.width, height: 230))
        
        view.selectButtonCallBack = { (model: Any) -> Void in
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
            let selectedDate = model as! Date
            let dateString = dateFormatter.string(from: selectedDate)
            //let dateString: String = dateFormatter.string(from: model as! Date)
            print("Selected time is : \(dateString)")
            //将日期倒序放入数组
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute,.second], from: selectedDate)
            
            print(components.year!)
            print(components.month!)
            print(components.day!)
            print(components.hour!)
            print(components.minute!)
            print(components.second!)
            
            let a = UInt8(components.year! - 2000)
            let b = UInt8(components.month! % 256)
            let c = UInt8(components.day! % 256)
            let d = UInt8(components.hour! % 256)
            let e = UInt8(components.minute! % 256)
            let f = UInt8(components.second! % 256)
            
            let data: [UInt8] = [f,e, d, c, b, a]
            
            // 输出 data 数组的内容
            for value in data {
                print(String(format: "0x%02X", value))
            }
            
            // 发送数据
            let ins: UInt8 = 0x0A
            let len: UInt8 = 6
            let packet = self.allExpanded.buildInstructionPacket(ins: ins, len: len, data: data)
            let hexString = self.allExpanded.hexadecimalString(from: packet)
            print(hexString)
            
            BleManager.shared.writeValue(packet, self.model?.mSendotacharater, self.model?.mPeripheral)
            //用于判断点击更新日期后，同步到列表的最新日期
            let eString = (e < 10) ? "0\(e)" : "\(e)"
            self.tempSampling = "20\(a)-\(b)-\(c) \(d):\(eString)"
            self.settingView.tableView?.reloadData()
            view.dismissView()
        }
        
        view.showInWindow()
        
        //        mSdtView = SettingDateTimeView(title: titles, p_name: "Year:", p_tf: "Please Input value")
        //
        //        mSdtView!.commonTf_y?.text = self.yearData
        //        mSdtView!.commonTf_m?.text = self.monthData
        //        mSdtView!.commonTf_d?.text = self.dayData
        //        mSdtView!.commonTf_h?.text = self.minuteData
        //        mSdtView!.commonTf_s?.text = self.secondData
        //
        //        // 点击确认的时候
        //        mSdtView?.clickSureBtn({ [self] _ in
        //            let ins: UInt8 = 0x04
        //            let len: UInt8 = 5
        //
        //            let a = mSdtView!.commonTf_y?.text
        //            let b = mSdtView!.commonTf_m?.text
        //            let c = mSdtView!.commonTf_d?.text
        //            let d = mSdtView!.commonTf_h?.text
        //            let e = mSdtView!.commonTf_s?.text
        //
        //            // 将 a 转换为 0x00 格式的 UInt8
        //            let aValue: UInt8 = UInt8(Int(a ?? "") ?? 0)
        //
        //            let bValue: UInt8 = UInt8(Int(b ?? "") ?? 0)
        //
        //            let cValue: UInt8 = UInt8(Int(c ?? "") ?? 0)
        //
        //            let dValue: UInt8 = UInt8(Int(d ?? "") ?? 0)
        //
        //            let eValue: UInt8 = UInt8(Int(e ?? "") ?? 0)
        //
        //
        //            // 创建 data 数组，存储 aValue 和 bValue
        //            let data: [UInt8] = [eValue, dValue,cValue,bValue,aValue]
        //
        //            // 输出 data 数组的内容
        //            for value in data {
        //                print(String(format: "0x%02X", value))
        //            }
        //            //
        //            let packet = self.allExpanded.buildInstructionPacket(ins: ins, len: len, data: data)
        //            let hexString = self.allExpanded.hexadecimalString(from: packet)
        //            print(hexString)
        //
        //            BleManager.shared.writeValue(packet, self.model?.mSendotacharater, self.model?.mPeripheral)
        //            print("sendTime and Time!!==")
        //        })
    }
    
    //点击切换温度C/F符号
    func onTempUnitRecordSwClick(sender: UISwitch){
        let unitOn = sender.isOn
        print("滑动了C/F", unitOn)
        if unitOn {
            isTempCF = "°F"
            CommonDefaults.shared.saveValue("°F", forKey: UNIT)
            print("true")
            
        }else{
            isTempCF = "°C"
            CommonDefaults.shared.saveValue("°C", forKey: UNIT)
            print("false")
        }
        
        self.settingView.tableView?.reloadData()
    }
    
    //监听到点击温度记录的开关
    func onTempRecordSwClick(sender: UISwitch){
        let tips = "Tips"
        let cancel = "Cancel"
        let ok = "Confirm"
        
        let alertController = UIAlertController(title: tips, message: "Do you want to trigger the temperature log switch?", preferredStyle: .alert)
        
        let noAction = UIAlertAction(title: cancel, style: .cancel, handler: nil)
        
        let yesAction = UIAlertAction(title: ok, style: .default, handler: { action in
            DispatchQueue.main.async {
                // 用户选择确认，执行开关状态更改
                let unitOn = !sender.isOn
                
                if unitOn {
                    if self.sdCardStatus == 1 && self.sdCardWorkingStatus == 0{
                        self.isRecordSwitch = true
                        // 发送开始温度记录指令
                        self.isOnAndOff = "ON"
                        self.tempRecordSwitch(inssub: 0x00)
                    }else{
                        WHToast.showMessage("SD card not inserted or read incorrectl", originY: 500, duration: 2, finishHandler: {
                        })
                    }
                } else {
                    if self.sdCardWorkingStatus == 0{
                        self.isRecordSwitch = false
                        // 进行按钮状态的反转
                        //sender.setOn(!unitOn, animated: true)
                        // 发送开始温度记录指令
                        self.isOnAndOff = "OFF"
                        self.tempRecordSwitch(inssub: 0x01)
                    }else{
                        WHToast.showMessage("An SD card reading error occurred", originY: 500, duration: 2, finishHandler: {
                        })
                    }
                }
                self.settingView.tableView?.reloadData()
            }
        })
        
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        present(alertController, animated: true) {
            //恢复开关状态为之前的状态
            sender.isOn = !sender.isOn
        }
        
    }
    
    //发送温度记录指令的开始和结束
    func tempRecordSwitch(inssub:UInt8){
        let ins: UInt8 = 0x03
        let len: UInt8 = 0x01
        let inssub:UInt8 = inssub
        
        let packet = self.allExpanded.queryDeviceData(ins: ins, len: len,inssub:inssub)
        
        let hexString = self.allExpanded.hexadecimalString(from: packet)
        print(hexString)
        
        BleManager.shared.writeValue(packet, self.model?.mSendotacharater, self.model?.mPeripheral)
        
        WHToast.showMessage("set TempRecord success!", originY: 500, duration: 2, finishHandler: {
        })
    }
    
    //点击弹出设定温度间隔时间/温度记录时间
    //    func clickUpdateTime(titles:String,index:Int){
    //        mUptView = UpdateTimeView(title:titles,p_name: "Name",p_tf: "Please Input DisplayName",view:self.view)
    //        mUptView!.delegate = self
    //        mUptView!.mMinutePicker?.delegate = self
    //        mUptView!.mMinutePicker!.dataSource = self
    //        //默认初始化数据
    //        if index == 0{
    //            minute = "2"
    //        }else if index == 1{
    //            record = "10"
    //        }
    //        //点击确认的时候
    //        mUptView?.clickSureBtn({ [self]_ in
    //            //self.sendTime()mNames?[indexPath.row]
    //            var mm:NSString?
    //            var selectTimeInt:UInt8?
    //            var appIns:UInt8?
    //            var appLen:UInt8?
    //            //如果index为0就是第一个列，如果为1就是第二个列表...
    //            if index == 0{
    //                mm = minute! as NSString
    //                appIns = 0x01
    //                appLen = 1
    //            }else if index == 1{
    //                mm = record! as NSString
    //                appIns = 0x02
    //                appLen = 1
    //            }
    //
    //            // 使用映射关系获取index值
    //            if let mappedIndex = indexMap[timeIndex!] {
    //                selectTimeInt = UInt8(mappedIndex)
    //            }
    //
    //            print("sendTime and Time!!==",mm!,"==",[selectTimeInt!])
    //
    //            let packet = allExpanded.buildInstructionPacket(ins: appIns!, len: appLen!, data: [selectTimeInt!])
    //
    //            let hexString = allExpanded.hexadecimalString(from: packet)
    //            print(hexString)
    //
    //            //发送数据到设备
    //            BleManager.shared.writeValue(packet, self.model?.mSendotacharater, self.model?.mPeripheral)
    //
    //            settingView.tableView?.reloadData()
    //        })
    //    }
    
    
    // 底部弹窗 -> 最后一行请处理
    func clickSendTime(list: [TimeModel],indexList:String){
        
        let view = SelectTimeView.init(frame: UIScreen.main.bounds, list: list)
        view.contenView = UIView.init(frame: CGRect.init(x: 0, y: UIScreen.main.bounds.size.height - 230 , width: UIScreen.main.bounds.size.width, height:230 ))
        
        view.selectButtonCallBack = {
            (model:Any)-> Void in
            
            let t = model as! TimeModel
            
            let send_value = Int(t.time!)!
            
            var appIns:UInt8?
            var appLen:UInt8?
            var selectTimeInt:UInt8?
            
            selectTimeInt = UInt8(t.index!)
            
            let stringValue = String(send_value)
            
            if indexList == "0"{
                appIns = 0x01
                appLen = 1
                print("0")
                self.minute = stringValue
            }else{
                appIns = 0x02
                appLen = 1
                print("1")
                self.record = stringValue
            }
            //发送数据的处理 请写入蓝牙的代码
            
            let packet = self.allExpanded.buildInstructionPacket(ins: appIns!, len: appLen!, data: [selectTimeInt!])
            
            let hexString = self.allExpanded.hexadecimalString(from: packet)
            print(hexString)
            
            //发送数据到设备
            BleManager.shared.writeValue(packet, self.model?.mSendotacharater, self.model?.mPeripheral)
            
            print("send_value is: \(send_value)")
            
            self.settingView.tableView?.reloadData()
            view.dismissView()
        }
        
        view.showInWindow()
        
    }
    
    // 移除定时器
    fileprivate func removeCycleTimer() {
        // 从运行循环中移除
        cycyleTimer?.invalidate()
        cycyleTimer = nil
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("内存警告哟！")
    }
    
}
