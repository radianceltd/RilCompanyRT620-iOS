//
//  BleDeviceController.swift
//  TMW041RT
//
//  Created by RND on 2023/3/22.
//

import UIKit
import CoreBluetooth
import SwiftEventBus
import MBProgressHUD

class BleDeviceController:NavigationController,AppDelegateDelegate,UITableViewDelegate, UITableViewDataSource{
    
    //定义数组返回蓝牙列表
    
    var scanResultsList: LinkedHashMap<String, BleModel> = LinkedHashMap()
    
    private var hud:MBProgressHUD?
    
    private var refresh = UIRefreshControl()
    
    private var bleDviceView = BleDeviceView()
    
    var communit = CommonUtil()
    
    private var isEdit = false
    
    var current:Int? = 0
    
    var timer:Timer?
    
    var bleTextUnit:String?
    
    //var timeInter:Int? = 0
    
    var isVersion:String?
    
    //判断是奇数还是偶数
    var evenOdd:String?
    
    let networkManager = NetworkManager.shared
    
    var scanResults: LinkedHashMap<String, BleModel> = LinkedHashMap()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        //调用导航类方法
        aboutNavigationCenter(title: "Ble Device")
        
        // 设置 AppDelegate 的代理为当前控制器
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.delegate = self
        }
        
    }
    
    //开始的时候触发函数
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadBle()
        //启动定时器
        self.startTimer()
    }
    
    // 实现 AppDelegateDelegate 协议中的方法来处理应用程序事件
    func applicationWillResignActive() {
        // 应用程序将要进入非活动状态并且失去焦点时的处理
        print("关闭了活动BLE")
    }
    
    func applicationDidBecomeActive() {
        // 应用程序从非活动状态变为活动状态时的处理
        loadBle()
    }
    
    //视图将要显示
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    //结束的时候触发函数
    override func viewWillDisappear(_ animated: Bool) {
        
        // 停止定时器
        self.stopTimer()
        
    }
    //初始化定义
    override func initView() {
        showHud()
        //刷新
        //refresh = UIRefreshControl()
        refresh.tintColor = UIColor.gray
        refresh.attributedTitle = NSAttributedString(string: "Scanning...")
        refresh.addTarget(self, action: #selector(loadBle), for: .valueChanged)
        bleDviceView.tableView?.refreshControl = refresh
        
        let view = UIView()
        bleDviceView.tableView?.delegate = self
        bleDviceView.tableView?.dataSource = self
        bleDviceView.tableView?.tableFooterView = view
        bleDviceView.frame = self.view.bounds
        self.view.addSubview(bleDviceView)
        
    }
    
    override func initData() {
        
        SwiftEventBus.onMainThread(self, name: "scanResults"){
            result in
            self.refresh.endRefreshing()
            // 2023/3/9 更新
            // let res = result?.object as! BleModel
            
            //self.scanResultsList.put(key: res.deviceMAC!, value: res)
            //self.scanResults = result?.object as! LinkedHashMap<String, BleModel>
            self.scanResultsList = result?.object as! LinkedHashMap<String, BleModel>
            //self.hidHud()
            if !self.isEdit {
                //可以自定义判断蓝牙为空的时候不能添加进去直接排除
                self.bleDviceView.tableView?.reloadData()
            }
        }
        
        //App Store中心的版本号为奇数，因此给予提示必须进行升级
        evenOdd = CommonDefaults.shared.getValue(BLE_EVEN_ODD)
        //如果是偶数就弹窗提示必须升级
        if evenOdd == "EVEN"{
            let tips = "Tips"
            let cancel = "Cancel"
            let ok = "Update"
            
            let alertController = CleanAlertController(title: tips, message: "There is a new version of the current application! Due to some fatal problems in the current program, it is recommended to update to the latest version immediately", preferredStyle: .alert)
            
            let yesAction = UIAlertAction(title: ok, style: .default, handler: { action in
                let str = "itms-apps://itunes.apple.com/cn/app/id6473766555?mt=8"
                if let url = URL(string: str) {
                    UIApplication.shared.open(url)
                }
            })
            
            let noAction = UIAlertAction(title: cancel, style: .cancel, handler: { action in
            })

            alertController.addAction(noAction)
            alertController.addAction(yesAction)
            self.present(alertController, animated: true)
        }
        
    }
    
    func startTimer() {
        // 每秒触发一次计时器事件
        timer = Timer.scheduledTimer(withTimeInterval:1.0, repeats: true) { timer in
            // 在计时器触发时执行的代码
            //print("计时器触发")
            // Do something...
            self.current = Int(Date().timeIntervalSince1970)
            self.bleDviceView.tableView?.reloadData()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    //刷新蓝牙列表的方法
    @objc func loadBle() {
        
        if scanResultsList.size() > 0 {
            scanResultsList.clear()
        }
        
        //me
        isVersion = CommonDefaults.shared.getValue(VERSION)
        
        if isVersion == "true"{
            aboutNavigationRight(isTure: true,isNameImage:"me_true",isNameText:"")
        }else{
            aboutNavigationRight(isTure: true,isNameImage:"me_false",isNameText:"")
        }
        
        
        BleManager.shared.startScan(name: APP_BLELISTNAME_DATA)
        
        self.refresh.endRefreshing()
        self.bleDviceView.tableView?.reloadData()
        
    }
    
    //显示
    func showHud(){
        hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.bezelView.style = .solidColor
        hud?.bezelView.color = UIColor.black.withAlphaComponent(0.7)
        hud?.label.text = NSLocalizedString("Loading...", comment: "HUD loading title")
        hud?.contentColor = UIColor.white
        //正常情况下是10秒后消失
        hud?.hide(animated: true, afterDelay: 0.5)
    }
    
    //隐藏
    func hidHud(){
        hud?.hide(animated: true, afterDelay: 0.5)
    }
    
    //tableview列表代理的方法体如下
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scanResultsList.size()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:BleDeviceCell? = tableView.dequeueReusableCell(withIdentifier: BLEDEVICELISTCELL) as? BleDeviceCell
        
        if cell == nil{
            cell = BleDeviceCell(style: .default, reuseIdentifier: BLEDEVICELISTCELL)
            cell!.selectionStyle = .none
        }
        
        if scanResultsList.size() > 0{
            hidHud()
            let model = scanResultsList.get(index: indexPath.row)
            if(model.deviceName != nil){
                if model.deviceName!.hasPrefix("Acc") {
                    let index = model.deviceName!.index(model.deviceName!.startIndex, offsetBy: 8) //获取数字开始位置索引
                    let number = model.deviceName![index...] // 获取数字
                    cell?.mNameLb?.text = "RAD" + number // 修改名称
                } else {
                    cell?.mNameLb?.text = model.deviceName // 其他情况不做修改
                }
                // cell?.mNameLb?.text = model.deviceName
                cell?.mAddressLb?.text = "S/N:\(model.deviceMAC!.uppercased())"
                
                //判断外部电源
                if model.isExternalPower{
                    cell?.mBatteryImage?.isHidden = false
                    cell?.mBatteryLb?.isHidden = true
                }else{
                    cell?.mBatteryImage?.isHidden = true
                    cell?.mBatteryLb?.isHidden = false
                    if let batteryLevel = model.batteryLevel {
                        cell?.mBatteryLb?.text = "\(batteryLevel)%"
                    } else {
                        cell?.mBatteryLb?.text = "N/A"
                    }
                }
                
                //判断信号值
                var signal = labs(model.deviceRssi?.intValue ?? 100)
                
                //不能越界 超过的话就得给值为100
                if(signal > 100){
                    signal = 100
                }
                
                cell?.mSignalLb?.text = "\(signal)"
                
                let retrievedUnit = CommonDefaults.shared.getValue(UNIT)
                
                if retrievedUnit != nil{
                    self.bleTextUnit = retrievedUnit
                }else{
                    // 存储单位
                    CommonDefaults.shared.saveValue("°C", forKey: UNIT)
                    self.bleTextUnit = "°C"
                }
                
                //判断离线
                if current! - model.date! >= 15 {
                    cell?.mOnlineLb?.isHidden = true
                    cell?.mTempUnitLb?.isHidden = true
                    cell?.mTempLb?.text = "OFFLINE"
                    cell?.mSignalIm?.image = UIImage(named: "signal0")
                    
                }else{
                    cell?.mOnlineLb?.isHidden = true
                    
                    cell?.mTempUnitLb?.isHidden = false
                    cell?.mTempUnitLb?.text = self.bleTextUnit
                    cell?.mTempLb?.text = communit.isTempScope(temp: model.temperatureValue!,unit:self.bleTextUnit!)
                    
                    //信号WIFI图
                    switch labs(model.deviceRssi?.intValue ?? 100) {
                    case 0...53:
                        cell?.mSignalIm?.image = UIImage(named: "signal3")
                    case 54...77:
                        cell?.mSignalIm?.image = UIImage(named: "signal2")
                    case 78...89:
                        cell?.mSignalIm?.image = UIImage(named: "signal1")
                    default:
                        cell?.mSignalIm?.image = UIImage(named: "signal1")
                    }
                }
            }
        }
        return cell!
    }
    
    //点击
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //连接蓝牙
        //connectBluetooth(index: indexPath.row)
        
        let model = self.scanResultsList.get(index: indexPath.row)
        
        var selectBle:String?
        var title:String?
        var titleMessage:String?
        var leftBt:String?
        var rightBt:String?
        
        if (model.deviceName?.contains("OTA"))!{
            selectBle = "ota"
            title = "Connect OTA"
            titleMessage = "Do you need to connect to OTA"
            leftBt = "Cancel"
            rightBt = "OTA"
        }else{
            selectBle = "ble"
            title = "Connect Bluetooth"
            titleMessage = "Do you need to connect to Bluetooth"
            leftBt = "Temp"
            rightBt = "Send"
        }
        
        connectBluetooth(model,selectBle:selectBle!,title: title!,titleMessage: titleMessage!,leftBt: leftBt!,rightBt: rightBt!,index: indexPath.row)
    }
    
    //连接蓝牙读取数据
    func connectBluetooth(_ model: BleModel,selectBle:String,title:String,titleMessage:String,leftBt:String,rightBt:String,index:Int){
        
        let alertController = CleanAlertController(title: title, message: titleMessage, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: rightBt, style: .default) {
            (action: UIAlertAction!) -> Void in
            if !model.deviceName!.contains("OTA"){
                print("send")
                //进入send界面
                BleManager.shared.stopScan()
                BleManager.shared.connectBle(model)
                let temp = SetingContrller()
                temp.model = model
                temp.isTempCF = self.bleTextUnit
                self.navigationController?.pushViewController(temp, animated: true)
            }else{
                //print("ota")
                //进入ota界面
                //let ota = OtaViewController()
                BleManager.shared.stopScan()
                BleManager.shared.connectBle(model)
                
                let ota = DFUViewController()
                ota.bleModel = model
                self.navigationController?.pushViewController(ota, animated: true)
            }
        }
        let cancelAction = UIAlertAction(title: leftBt, style: UIAlertAction.Style.cancel){ [self]
            (action: UIAlertAction!) -> Void in
            if selectBle != "ota"{
                print("ble")
                //进入ble界面
                //BleManager.shared.connectBle(model)
                // 获取符号值
                //                let retrievedUnit = self.commonDefaults.getDataUnit(model.deviceMAC)
                //                print("Retrieved Unit: \(retrievedUnit ?? "Not found")")
                //
                let temp = DataViewController()
                temp.model = model
                temp.position = index
                temp.tempUnit = self.bleTextUnit
                self.navigationController?.pushViewController(temp, animated: true)
                
            }else{
                print("cancel")
            }
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }
    
    //当TableView编辑取消的时候执行
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        
        isEdit = false
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        //cellRloaderType = 0
        isEdit  = true
        
        print("滑动开始")
        
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
        print("滑动松开自动滑动开始")
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        //cellRloaderType = 1
        print("滑动结束")
        isEdit  = false
        
    }
    
    
}
