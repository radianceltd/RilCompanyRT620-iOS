//
//  BleManager.swift
//  TMW041RT
//
//  Created by RND on 2023/3/23.
//

import UIKit
import CoreBluetooth
import SwiftEventBus
import PDFKit
import WHToast

import CoreGraphics

//import Constants

// 枚举类型
enum DataType: UInt8 {
    case temperatureSamplingInterval = 0x01
    case temperatureRecordInterval = 0x02
    case pdfFileNames = 0x03
    case csvFileNames = 0x04
    case pdfFileDataBlock = 0x05
    case csvFileDataBlock = 0x06
    case fileReadEndNotification = 0x07
    case deviceStatus = 0x08
    case appVersion = 0x09
    case dateTime = 0x0A
    case bleInstruct = 0x0B
    case appNoResponse = 0xFF
    case InternalParameter = 0x0C
    case querBleParameterInternal = 0x0D
    case secDateTime = 0x0E
}

struct DataBlock {
    let dataType: UInt8
    let length: UInt8
    let sequence: UInt8?
    let fileSize: UInt32?
    let fileName: String?
}

struct DeviceStatus {
    var batteryLevel: UInt8
    var deviceStatus: UInt8
    var thermo0: UInt8
    var thermo1: String
}

// 定义Scan Response数据包结构体
struct ScanResponseDataPacket {
    var name: String = ""
    var isOnline: Bool?
}

class BleManager:NSObject,CBCentralManagerDelegate,CBPeripheralDelegate{
    
    //定义管理者
    var centerManager : CBCentralManager!
    
    //外设管理者
    var periperals: [CBPeripheral] = []
    
    var deviceList:Array<BleModel> = []
    
    //连接成功后的列表
    var successList:Array<BleModel> = []
    
    var scanResults: LinkedHashMap<String, BleModel> = LinkedHashMap()
    
    //特征
    var sendCharacteristic:CBCharacteristic?
    
    //数据解析的类
    private var cmUtil = CommonUtilOC()
    
    //单列模式
    public static let shared = BleManager()
    
    //串行队列
    let queue = DispatchQueue.init(label: "github.blemanage.BleManage")
    
    //var deviceList:Array<BleModel> = []

    var dHandler = DataHandler()
    
    var isOta = false
    
    var isWritePacketDataSuccess = false
    
    var allExpanded = AllExpanded()
    
    var bleModel = BleModel()
    
    // 新增数据读取
    let RECEIVE_DATA_UUID = CBUUID(string: "FFF2")
    
    let RECEIVE_FILE_UUID = CBUUID(string: "FFFE")
    
    let SEND_DATA_UUID = CBUUID(string: "FFF1")
    
    let SEND_OTA_UUID = CBUUID(string: "FFF1")
    
    let UPDATE_OTA_UUID = CBUUID(string: "00001531-1212-EFDE-1523-785FEABCD123")
    
    var combinedFileData = Data()
    
    var combinedUint8Data = [UInt8]()
    
    // 类型 新增代码
    var type = 0
    
    // 文件files 新增代码
    var filesName = [UInt8]()
    
    var filesData = [UInt8]()
    
    /// 新增大小
    var fileSize = 0
    
    /// 当前的包大小
    var currentPacket = 0
    
    override init(){
        super.init()
        //第一步：初始化蓝牙
        centerManager = CBCentralManager()
        centerManager?.delegate = self
    }
    
    /// 启动蓝牙加入队列
    public func run(){
        centerManager = CBCentralManager(delegate: self, queue: queue)
    }
    
    //连接后设置MTU最大值为247
    func setMTU(_ central: CBCentralManager, peripheral: CBPeripheral) {
        // 设置设备的 MTU 大小为 247
        let mtuSize = peripheral.maximumWriteValueLength(for: .withoutResponse)
        print("当前 MTU 大小为：\(mtuSize)")
        //        peripheral.setPreferredMTU(247, completion: { (mtu, error) in
        //            if let error = error {
        //                print("设置 MTU 大小失败: \(error.localizedDescription)")
        //            } else {
        //                print("已成功设置设备的 MTU 大小为: \(mtu)")
        //                // 在这里继续执行读取数据的操作
        //            }
        //        })
    }
    
    // 打开CCCD
    func openCCCD(peripheral: CBPeripheral) {
        // 获取目标设备的Peripheral对象
        //let peripheral: CBPeripheral = self.peripheral
        
        // 获取通知服务的Characteristics
        guard let characteristic = peripheral.services?.first?.characteristics?.first(where: { $0.uuid == CBUUID(string: "2902") }) else {
            print("无法找到CCCD")
            return
        }
        
        // 设置CCCD值为开启通知
        peripheral.setNotifyValue(true, for: characteristic)
    }
    
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if #available(iOS 10.0, *) {
            if central.state == .poweredOff {
                print("CoreBluetooth BLE hardware is powered off")
                WHToast.showMessage("You need access to your Bluetooth so that the application can always get Bluetooth information!", originY: 500, duration: 2, finishHandler: {
                })
                SwiftEventBus.post("bleInfoEvent",sender: "CoreBluetooth BLE hardware is powered off")
            } else if central.state == .poweredOn {
                print("CoreBluetooth BLE hardware is powered on and ready")
                SwiftEventBus.post("bleInfoEvent",sender: "CoreBluetooth BLE hardware is powered on and ready")
                startScan(name: APP_BLELISTNAME_DATA)
            } else if central.state == .unauthorized {
                print("CoreBluetooth BLE state is unauthorized")
                SwiftEventBus.post("bleInfoEvent",sender: "CoreBluetooth BLE state is unauthorized")
            } else if central.state == .unknown {
                print("CoreBluetooth BLE state is unknown")
                SwiftEventBus.post("bleInfoEvent",sender: "CoreBluetooth BLE state is unknown")
            } else if central.state == .unsupported {
                print("CoreBluetooth BLE hardware is unsupported on this platform")
                SwiftEventBus.post("bleInfoEvent",sender: "CoreBluetooth BLE hardware is unsupported on this platform")
                print("CoreBluetooth BLE hardware is unsupported on this platform")
            }
        } else {
            // Fallback on earlier versions
            print("Fallback on earlier versions")
            SwiftEventBus.post("bleInfoEvent",sender: "Fallback on earlier versions")
        }
    }
    
    //第三步方法体
    func startScan(name: String){
        if periperals.count > 0 {
            periperals.removeAll()
        }
        
        //移除所有的设备数据
        if deviceList.count > 0 {
            deviceList.removeAll()
        }
        
        //扫描设备列表
        queue.async(execute: {
            //扫描设备列表
            if self.centerManager?.state.rawValue == CBManagerState.poweredOn.rawValue {
                let options = [
                    CBCentralManagerScanOptionAllowDuplicatesKey: NSNumber(value: true)
                ]
                //调用实现扫描蓝牙
                self.centerManager!.scanForPeripherals(withServices: nil, options: options)
            }
        })
        
    }
    
    //停止扫描
    func stopScan(){
        centerManager!.stopScan()
    }
    
    //连接蓝牙,当蓝牙列表点击了此方法体,接收int整形的索引
    func connectBle(_ model: BleModel){
        
        if centerManager!.state.rawValue == CBManagerState.poweredOn.rawValue {
            if model.mPeripheral != nil {
                print("我准备连接了!")
                //开始连接设备
                centerManager!.connect(model.mPeripheral!, options: nil)
                model.mSelect = true
                self.successList.append(model)
                SwiftEventBus.post("connectListEvent", sender: self.successList)
                
                // WHToast.showMessage("设备已经连接成功!", originY: 500, duration: 2, finishHandler: {
                //})
            }else{
                print("连接失败了!")
                //WHToast.showMessage("失败连接!", originY: 500, duration: 2, finishHandler: {
                //})
            }
        }
    }
    
    //断开连接蓝牙
    func disConnectBle() {
        if successList.count > 0 {
            for model in successList {
                model.mSelect = false
                centerManager!.cancelPeripheralConnection(model.mPeripheral!)
            }
        }
    }
    
    //断开所有的蓝牙连接
    func disAllConnectBle() {
        
        //断开所有的蓝牙连接
        if successList.count > 0 {
            for model in successList {
                if let peripheral = model.mPeripheral, let manager = centerManager {
                    manager.cancelPeripheralConnection(peripheral)
                }
            }
        }
        
        if periperals.count > 0 {
            periperals.removeAll()
        }
        
        if successList.count > 0 {
            successList.removeAll()
        }
    }
    
    //发现设备
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSS: NSNumber) {
        
        //print("periperal name ;\(peripheral.name)")
        //var index = 0;
        
        if peripheral.name != nil && peripheral.name != "" {
            
            if(peripheral.name!.contains("Acc") || peripheral.name!.contains("ota") ||
               peripheral.name!.contains("CS")) || peripheral.name!.contains("RAD"){
                //制造商信息
                let data =  parseManufacturerData(from: advertisementData)
                
                // 获取设备名称
                let scanResponseData = parseScanResponse(advertisementData: advertisementData)
                //print("Manufacturer data: \(String(describing: scanResponseData?.name))")
                //获取离线的信息
                let scanOnlineData = parseScanOnlineResponse(advertisementData: advertisementData)
                
                //print("Manufacturer data: \(String(describing: scanOnlineData?.isOnline))")
                
                if data.mac != ""{
                    let model = BleModel()
                    model.date = Int(Date().timeIntervalSince1970)
                    model.deviceName = scanResponseData?.name
                    model.deviceRssi = RSS
                    model.deviceMAC = data.mac
                    model.deviceIsOnline = scanOnlineData?.isOnline
                    model.mPeripheral = peripheral
                    model.advertisementData = advertisementData
                    
                    model.temperatureValue = "\(data.temperature)"
                    model.batteryLevel = "\(data.batteryLevel)"
                    model.isTemperatureRecordOn = data.isTemperatureRecordOn
                    model.hasTemperatureRecord = data.hasTemperatureRecord
                    model.isExternalPower = data.isExternalPower
                    
                    //SD卡的信息
                    model.sdCardWorkingStatus = data.sdCardWorkingStatus
                    model.sdCardStatus = data.sdCardStatus
                    
                    let _ = scanResults.put(key: model.deviceMAC!, value: model)
                    
                    
                    SwiftEventBus.post("scanResults", sender: scanResults)
                }else{
                    
                    let model = BleModel()
                    model.date = Int(Date().timeIntervalSince1970)
                    model.deviceName = scanResponseData?.name
                    model.deviceRssi = RSS
                    model.deviceMAC = "Ota"
                    model.deviceIsOnline = scanOnlineData?.isOnline
                    model.mPeripheral = peripheral
                    model.advertisementData = advertisementData
                    
                    model.temperatureValue = "\(data.temperature)"
                    model.batteryLevel = "\(data.batteryLevel)"
                    model.isTemperatureRecordOn = data.isTemperatureRecordOn
                    model.hasTemperatureRecord = data.hasTemperatureRecord
                    model.isExternalPower = data.isExternalPower
                    
                    let _ = scanResults.put(key: model.deviceMAC!, value: model)
                    
                    SwiftEventBus.post("scanResults", sender: scanResults)
                    //index += 1;
                }
            }
        }
    }
    
    // 解析制造商信息广告数据
    func parseManufacturerData(from advertisementData: [String : Any]) -> (mac: String, isExternalPower: Bool, batteryLevel: Int, hasTemperatureRecord: Bool, isTemperatureRecordOn: Bool,TempRecordingSwitch: Int,sdCardWorkingStatus: Int ,sdCardStatus: Int,temperature: Double) {
        guard let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data, manufacturerData.count >= 10 else {
            return ("", false, 0, false, false,0,0,0, 0.0)
        }
        //MAC
        let mac = manufacturerData.subdata(in: 0..<6).map { String(format: "%02x", $0) }.reversed().joined(separator: "")
        //判断是否外部电源
        let isExternalPower = (manufacturerData[6] & 0x80) != 0
        //电量
        let batteryLevel = Int(manufacturerData[6] & 0x7f)
        
        //设备状态
        let deviceStatus = Int(manufacturerData[7])
        //1有温度记录，0：无
        let deviceStatus7 = (deviceStatus & 0b10000000) >> 7
        //1打开温度记录开关，0关
        let TempRecordingSwitch = (deviceStatus & 0b01000000) >> 6
        
        //SD卡工作状态，1发生SD卡读取错误
        let sdCardWorkingStatus = (deviceStatus & 0b00100000) >> 5
        
        //SD卡状态，1为SD卡插入
        let sdCardStatus = (deviceStatus & 0b00010000) >> 4
        
//        print("macmacmacmacmacmac==:",mac)
//        print("deviceState==:",deviceStatus)
//        print("7777777：", deviceStatus7)
//        print("666666==:",TempRecordingSwitch)
//        print("55555：", sdCardWorkingStatus)
//        print("4444==:",sdCardStatus)

        let hasTemperatureRecord = (manufacturerData[7] & 0x80) != 0
        let isTemperatureRecordOn = (manufacturerData[7] & 0x40) != 0
        //print("hasTemperatureRecord==:",hasTemperatureRecord)
        //print("isTemperatureRecordOn==:",isTemperatureRecordOn)
        //温度
        let temperatureValue = Int16(manufacturerData[9]) << 8 | Int16(manufacturerData[8])
        let temperature = Double(temperatureValue) / 10.0
        
        return (mac, isExternalPower, batteryLevel, hasTemperatureRecord, isTemperatureRecordOn,TempRecordingSwitch,sdCardWorkingStatus,sdCardStatus,temperature)
    }
    
    // 解析Scan Response数据包
    func parseScanResponse(advertisementData: [String: Any]) -> ScanResponseDataPacket? {
        let bluetoothNameType: UInt8 = 0x09
        
        // 尝试从Complete Local Name中获取设备名称
        if let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            let scanResponseData = ScanResponseDataPacket(name: localName)
            return scanResponseData
        }
        
        // 尝试从Manufacturer Data中获取设备名称
        if let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data,
           let firstByte = manufacturerData.first,
           firstByte == bluetoothNameType,
           let nameBytes = manufacturerData.dropFirst().map({ $0 }) as? [UInt8],
           let nameString = String(bytes: nameBytes, encoding: .utf8)
        {
            let scanResponseData = ScanResponseDataPacket(name: nameString)
            return scanResponseData
        }
        
        
        return nil
    }
    
    // 解析Scan Response数据包
    func parseScanOnlineResponse(advertisementData: [String: Any]) -> ScanResponseDataPacket? {
        
        //尝试从kCBAdvDataIsConnectable中进行判断是否离线
        if let lastonLine = advertisementData[CBAdvertisementDataIsConnectable] as? Bool {
            let scanResponseData = ScanResponseDataPacket(isOnline: lastonLine)
            return scanResponseData
        }
        
        return nil
    }
    
    //蓝牙连接
    func connect(_ peripheral: CBPeripheral?, completionBlock completionHandler: @escaping (_ success: Bool, _ error: String?) -> Void) {
        //中心管理者的状态等于蓝牙打开的模式
        if centerManager!.state.rawValue == CBManagerState.poweredOn.rawValue {
            
            //外设的状态等于连接成功
            if peripheral?.state == .disconnected {
                
                completionHandler(true, "Connect Success")
                if let peripheral = peripheral {
                    //调用中心管理者的链接（参数为：传入外设）
                    centerManager!.connect(peripheral, options: nil)
                    //                    let model = BleModel()
                    //                    model.mSelect = true
                }
                
            }
        }
    }
    
    //设备已经成功连接代理
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //periperals.append(peripheral)
        //停止关闭扫描
        centerManager!.stopScan() // 根号 3
        peripheral.delegate = self
        //调取服务
        //discoverServices(peripheral: peripheral)
        peripheral.discoverServices(nil)
        print("连接成功设备，正扫描服务...");
        
        SwiftEventBus.post("successDevice", sender: scanResults)
        setMTU(central, peripheral: peripheral)
        openCCCD(peripheral: peripheral)
    }
    
    
    //MARK: 手动断开蓝牙连接服务
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        //断开蓝牙做相对应的处理
        if successList.count > 0{
            for model in successList {
                if model.mPeripheral == peripheral {
                    successList.removeAll { $0 as BleModel === model as BleModel }
                    //断开蓝牙事件
                    SwiftEventBus.post("disconnectEvent",sender: model)
                    
                }
            }
        }
        SwiftEventBus.post("connectListEvent",sender: successList)
    }
    
    //////////////////////////////////////////
    //MARK: CBPeripheralDelegate
    //发现蓝牙服务
    ///////////////////////////////////////
    
    //在外设中查询服务
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            if let error = error {
                print("扫描服务出现错误,错误原因:\(error)")
            }
        } else {
            for service in peripheral.services ?? [] {
                print("服务UUID为...:\(service.uuid)");
                peripheral.discoverCharacteristics(nil, for: service)
                
                if service.uuid == CBUUID(string: "FFF2") {
                    // 发现目标服务，设置通知和温度采样间隔
                    //peripheral.setNotifyValue(true, for: service.characteristics?.first!)
                    //setTemperatureSamplingInterval(interval: 0x02)
                    enableNotification(peripheral) // 调用enableNotification()方法
                }
            }
        }
    }
    
    //读取蓝牙服务特征的描述符UUID值
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        guard let descriptors = characteristic.descriptors else {
            return
        }
        
        for descriptor in descriptors {
            print("Descriptor UUID: \(descriptor.uuid.uuidString)")
            //            if descriptor.uuid == CBUUID(string: "2902") {
            //                peripheral.readValue(for: descriptor) // 异步读取描述符的值
            //                //                        }
            //                print("CCCD Descriptor UUID: \(descriptor.uuid)")
            //
            //   }
        }
    }
    
    //打开通知服务成功
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            if let error = error {
                print("读取特征数据失败--\(error)")
            }
            return
        }
        print("aa","\(characteristic.isNotifying)")
        
        if(characteristic.isNotifying){
            peripheral.readValue(for: characteristic);
            print("zzz==",characteristic.uuid.uuidString);
        }
    }
    
    //调取服务成功，读取特征值
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            if let error = error {
                print("发现蓝牙特征出现错误,错误原因:\(error)")
            }
        } else {
            for character in service.characteristics ?? [] {
                print("==character== ",character.uuid)
                
                // 重新设计制作 2023/6/27 13:46
                if character.uuid == RECEIVE_DATA_UUID {
                    
                    for model in successList {
                        
                        // 当前的peripheral 相等
                        if model.mPeripheral == peripheral{
                            
                            model.readTempCharater = character
                            //peripheral.discoverDescriptors(for: character)
                            //peripheral.readValue(for: character)
                            peripheral.setNotifyValue(true, for: character)
                            // 打开通知代码
                            //peripherals(peripheral: peripheral, didDiscoverCharacteristicsForService: service, error: error as NSError?)
                        }
                    }
                }
                // Ota
                else if character.uuid == SEND_OTA_UUID {
                    
                    for model in successList {
                        if model.mPeripheral == peripheral {
                            model.mSendotacharater = character
                            //开启通知
                            peripheral.setNotifyValue(true, for: character)
                        }
                    }
                }else if character.uuid == RECEIVE_FILE_UUID{
                    for model in successList {
                        if model.mPeripheral == peripheral {
                            
                            //开启通知
                            peripheral.setNotifyValue(true, for: character)
                        }
                    }
                }
            }
        }
    }
    
    // Consider storing important characteristics internally for easy access and equivalency checks later.
    // From here, can read/write to characteristics or subscribe to notifications as desired.
    
    //蓝牙外设发现特征后的回调方法
    //    func peripherals(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
    //        if let characteristics = service.characteristics {
    //            for characteristic in characteristics {
    //                if characteristic.uuid == RECEIVE_DATA_UUID {
    //                    // dataCharacteristic = characteristic
    //                    peripheral.readValue(for: characteristic)
    //                    peripheral.setNotifyValue(true, for: characteristic)
    //
    //                }
    //            }
    //        }
    //    }
    
    //MARK: 蓝牙外设通知数据
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        for model in successList {
            
            if model.mPeripheral == peripheral{
                print("uuid--\(characteristic.uuid.uuidString)")
                //
                if characteristic.uuid == RECEIVE_DATA_UUID {
                    // 特征处于通知状态
                    // 进行相应操作
                    if let data = characteristic.value {
                        let qdata = [UInt8](data)
                        print("FFF2==",qdata)
                        receiveData(data: qdata, model: model)
                    }
                    
                }else if characteristic.uuid == SEND_DATA_UUID{
                    
                    guard let value = characteristic.value else {
                        return
                    }
                    // 处理接收到的通知数据value
                    print("接收到通知数据: \(value)")
                    //peripheral.setNotifyValue(true, for: characteristic)
                }else if characteristic.uuid == RECEIVE_FILE_UUID{
                    if let data = characteristic.value {
                        let qdata = [UInt8](data)
                        print("FFFE==",qdata)
                        receiveData(data: qdata, model: model)
                    }
                }
            }
        }
    }
    
    func receiveData(data: [UInt8], model: BleModel) {
        
        guard data.count >= 2 else {
            print("Invalid data")
            return
        }
        
        let dataTypeRawValue = data[0]
        guard let dataType = DataType(rawValue: dataTypeRawValue) else {
            print("Invalid data type")
            return
        }
        
        switch dataType {
        case .temperatureSamplingInterval:
            if data.count == 3 {
                let interval = String(data[2])
                
                SwiftEventBus.post(TEMPSAMPLINGINTERVAL, sender: interval)
                // 解析温度采样间隔
            } else {
                print("Invalid data length")
            }
            
        case .temperatureRecordInterval:
            if data.count == 3 {
                let interval = String(data[2])
                SwiftEventBus.post(TEMPSAMPLINGINTERVAL, sender: interval)
                // 解析温度记录间隔
            } else {
                print("Invalid data length")/// 我的天空@
            }
            
        case .pdfFileNames:
            type = 3
            // 解析 PDF 文件名参数列表
            //let qdata: [UInt8] = [46, 112, 100, 102]
            //let params = allExpanded.parseFileData1(data,qdata)
            //SwiftEventBus.post(FILEPARAMES, sender: params)
            combineFileNameData(list: data)

        case .csvFileNames:
            type = 4
            // 解析 CSV 文件名参数列表
            //let qdata: [UInt8] = [46, 67, 83, 86]
            //let params = allExpanded.parseFileData(data,qdata)
            //SwiftEventBus.post(CSVFILENAMEPARAMES, sender: params)
            combineFileNameData(list: data)
            
        case .pdfFileDataBlock:
            //不断接收0x05的通知数据
            type = 5
            // 解析数据块
            let fileData = Array(data.suffix(from: 5))
            combinedUint8Data += fileData
            
            let interval = String(data[3])
            let interval4 = String(data[4])
            
            if interval == "0" && interval4 == "0"{
                currentPacket = 0
            }
            
            if fileSize != 0  {
                currentPacket += 1
                let q = calculateProgress(fileSize: Int64(fileSize), currentPacket: currentPacket)
                //print("currentPacket==",currentPacket)
                //print("qqqqqqqq==",q)
                SwiftEventBus.post(PROGRESS_INT, sender: q)
            }
            
            
            break
              
        case .csvFileDataBlock:
            //不断接收0x06的通知数据
            type = 6
            let fileData = Array(data.suffix(from: 5))
            bleModel.fileReq += fileData
            
            let interval = String(data[3])
            let interval4 = String(data[4])
            
            if interval == "0" && interval4 == "0"{
                currentPacket = 0
            }
            
            if fileSize != 0  {
                currentPacket += 1
                let q = calculateProgress(fileSize: Int64(fileSize), currentPacket: currentPacket)
                SwiftEventBus.post(PROGRESS_INT, sender: q)
            }
            
            break
            
        case .fileReadEndNotification:
          
            //接收到结束通知文件的0x07; 这里只是一个数据传输跟[Uint8]类型的数据与那个model没有任何的关系所以不能用model类型，使用model的类型反而会造成代码错误，请理解并不是所有的类型都可以使用错误，再不确定的时候最好不用。应该修改为直接传 如下代码：如果要传数据需要重新定义一个model而不是使用重复的之前model不是你想的那样子的
            if(type == 3){
                //获取pdf文件列表
                let qdata: [UInt8] = [46, 112, 100, 102]
                let params = allExpanded.parseFileNameData2(data: filesName,subArray: qdata)
                SwiftEventBus.post(FILEPARAMES, sender: params)
                filesName.removeAll()
            }else if(type == 4){
                let qdata: [UInt8] = [46, 67, 83, 86]
                let params = allExpanded.parseFileNameData2(data: filesName,subArray: qdata)
                SwiftEventBus.post(CSVFILENAMEPARAMES, sender: params)
                filesName.removeAll()
            }else if(type == 5){
                // 发送完成归零
                currentPacket = 0
                //print("combinedUint8Data==",combinedUint8Data.count)
                if combinedUint8Data.count > 0{
                    SwiftEventBus.post(CSVFILEPARAMES, sender: combinedUint8Data)
                    combinedUint8Data = []
                }else{
                    //为nil时
                    let params = allExpanded.parseFileData(data: bleModel.fileReq)
                    SwiftEventBus.post(CSVFILEPARAMES, sender: params)
                    bleModel.fileReq = []
                }
            }else if(type == 6){
                // 发送完成归零
                currentPacket = 0
                
                //判断文件是否可以读取到
                if bleModel.fileReq.count > 0{
                    let params = allExpanded.parseFileData(data: bleModel.fileReq)
                    SwiftEventBus.post(CSVFILEPARAMES, sender: params)
                    bleModel.fileReq = []
                }else{
                    //为nil时
                    SwiftEventBus.post(CSVFILEPARAMES, sender: combinedUint8Data)
                    combinedUint8Data = []
                }
            }
            break
            
        case .deviceStatus:
            if data.count == 6 {
                let datetype = data[0]
                let length = data[1]
                let batteryLevel = data[2]
                let deviceStatus = data[3]
                let thermo0 = data[4]
                let thermo1 = data[5]
                
                let temperatureValue = Int16(data[5]) << 8 | Int16(data[4])
                let temperature = Double(temperatureValue) / 10.0
                
                let devst_tempSwitch = (deviceStatus & 0b01000000) >> 6
                let recordsWorlkState = (deviceStatus & 0b00100000) >> 5
                let recordsSD_State = (deviceStatus & 0b00010000) >> 4

                let deviceStatusInfo = DeviceStatus(batteryLevel: batteryLevel, deviceStatus: deviceStatus, thermo0: thermo0, thermo1: "\(temperature)")
                // 解析设备状态
                model.batteryLevel = "\(batteryLevel)"
                model.temperatureValue = "\(temperature)"
                model.sdCardWorkingStatus = Int(recordsWorlkState)
                model.sdCardStatus = Int(recordsSD_State)
                
                if devst_tempSwitch == 0{
                    model.isTemperatureRecordOn = false
                }else{
                    model.isTemperatureRecordOn = true
                }
            
                
                print("device status :\(deviceStatusInfo.thermo1)")
                
                
                let _ = scanResults.put(key: model.deviceMAC!, value: model)
                SwiftEventBus.post("scanResults", sender: scanResults)
                
                
                //                let stringFormat = "\(length),\(batteryLevel),\(deviceStatus),\(thermo0),\(thermo1)"
                //
                //                SwiftEventBus.post(TEMPSAMPLINGINTERVAL, sender: stringFormat)
            } else {
                print("Invalid data length")
            }
            
        case .appVersion:
            if data.count == 4 {
                let versionCode = data[0...3]
                let stringFormat = "\(versionCode[0]),\(versionCode[1]),\(versionCode[2]),\(versionCode[3])"
                
                SwiftEventBus.post(TEMPSAMPLINGINTERVAL, sender: stringFormat)
                // 解析应用程序版本信息
            } else {
                print("Invalid data length")
            }
            
        case .appNoResponse:
            // 解析应用程序无响应指令
            break
        case .dateTime:
            let interval2 = data[2]
            let interval3 = data[3]
            let interval4 = data[4]
            let interval5 = data[5]
            let interval6 = data[6]
            
            let data = [interval2, interval3, interval4, interval5, interval6]
            //let reversedData = Array(data.reversed())
            let stringFormat = "\(data[0]),\(data[1]),\(data[2]),\(data[3]),\(data[4])"
            
            SwiftEventBus.post(TEMPSAMPLINGINTERVAL, sender: stringFormat)
        case .bleInstruct:
            let interval0 = data[0]
            let interval1 = data[1]
            let interval2 = data[2]
            let interval3 = data[3]
            let interval4 = data[4]
            let interval5 = data[5]
            
            let data = [interval0, interval1, interval2, interval3, interval4,interval5]
            
            let stringFormat = "\(data[0]),\(data[1]),\(data[2]),\(data[3]),\(data[4]),\(data[5])"
            
            SwiftEventBus.post(TEMPSAMPLINGINTERVAL, sender: stringFormat)
        case .InternalParameter:
            let interval0 = data[0]
            let interval1 = data[1]
            let interval2 = data[2]
            let interval3 = data[3]
            let interval4 = data[4]
            let interval5 = data[5]
            
            let data = [interval0, interval1, interval2, interval3, interval4,interval5]
            
            let stringFormat = "\(data[0]),\(data[1]),\(data[2]),\(data[3]),\(data[4]),\(data[5])"
            
            SwiftEventBus.post(TEMPSAMPLINGINTERVAL, sender: stringFormat)
            
        case .querBleParameterInternal:
            let interval0 = data[0]
            let interval1 = data[1]
            let interval2 = data[2]
            let interval3 = data[3]
            let interval4 = data[4]
            let interval5 = data[5]
            let interval6 = data[6]
            let interval7 = data[7]
            let interval8 = data[8]
            let interval9 = data[9]
            let interval10 = data[10]
            let devst_tempSwitch = (interval10 & 0b01000000) >> 6
            let recordsWorlkState = (interval10 & 0b00100000) >> 5
            let recordsSD_State = (interval10 & 0b00010000) >> 4
            let interval11 = data[11]
            let interval12 = data[12]
            
            let data = [interval0, interval1, interval2, interval3, interval4,interval5,interval6, interval7, interval8, interval9, interval10,interval11,interval12]
            
            let stringFormat = "\(data[0]),\(data[1]),\(data[2]),\(data[3]),\(data[4]),\(data[5]),\(data[6]),\(data[7]),\(data[8]),\(data[9]),\(devst_tempSwitch),\(recordsWorlkState),\(recordsSD_State),\(data[11]),\(data[12])"
            
            SwiftEventBus.post(TEMPSAMPLINGINTERVAL, sender: stringFormat)
        case .secDateTime:
            let interval0 = data[0]
            
            let data = [interval0]
            let stringFormat = "\(data[0])"
            SwiftEventBus.post(TEMPSAMPLINGINTERVAL, sender: stringFormat)
        }
        
    }
    
    private func calculateProgress(fileSize: Int64, currentPacket: Int) -> Int {
        let totalPackets = fileSize / 239 + (fileSize % 239 != 0 ? 1 : 0)
       // print("currentPacket222==",currentPacket)
        //print("totalPackets==",totalPackets)
        return Int(100.0 * Double(currentPacket) / Double(totalPackets))
    }
    
    
    //读取记录时间代码
    func readRecordTime(_ valueData: Data)->String?{
        guard valueData.count == 1 else {
            return "0"
        }
        let value = valueData[0]
        switch value {
        case 0x00:
            return "5"
        case 0x01:
            return "10"
        case 0x02:
            return "30"
        case 0x03:
            return "60"
        default:
            return "0"
        }
    }
    
    
    // 组合代码4
    func combineFileNameData(list: [UInt8]) {
        let list1 = Array(list.dropFirst(4))
        filesName += list1
    }
    
    // 组合类型代码5
    func combineFileData(list: [UInt8]) {
        let list1 = Array(list.dropFirst(5))
        filesData += list1
    }
    
    
    
    func createPDF(fromData data: [UInt8], fileName: String) {
        guard let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("无法访问文档目录.")
            return
        }
        
        let pdfURL = documentDirectoryURL.appendingPathComponent(fileName)
        
        guard let dataProvider = CGDataProvider(data: NSData(bytes: data, length: data.count)) else {
            print("无法创建CGDataProvider")
            return
        }
        
        guard let document = CGPDFDocument(dataProvider) else {
            print("无法创建CGPDFDocument")
            return
        }
        
        guard let pdfContext = CGContext(pdfURL as CFURL, mediaBox: nil, nil) else {
            print("无法创建CGContext")
            return
        }
        
        let pageCount = document.numberOfPages
        
        pdfContext.beginPDFPage(nil)
        
        for index in 1...pageCount {
            guard let page = document.page(at: index) else {
                print("无法获取PDF页码")
                continue
            }
            
            pdfContext.drawPDFPage(page)
            pdfContext.beginPDFPage(nil)
        }
        
        pdfContext.endPDFPage()
        pdfContext.closePDF()
        
        print("PDF文件已创建：\(pdfURL.path)")
    }
    
    
    
    
    func parseAndCreatePDF(from fileData: Data, name: String) {
        // 创建一个新的 PDFDocument
        //let document = PDFDocument()
        
        // 将文件数据转换为 UIImage
        //        guard let image = UIImage(data: fileData) else {
        //            print("无法解析图像数据.")
        //            return
        //        }
        
        
        // 使用PDFDocument加载数据创建PDF文档
        guard let pdfDocument = PDFDocument(data: fileData) else {
            fatalError("无法创建PDF文档")
        }
        
        //        // 使用 UIImage 创建一个 PDFPage
        //        if let page = PDFPage(image: image) {
        //            // 将页面添加到文档中
        //            document.insert(page, at: document.pageCount)
        //        }
        
        // 获取文档目录路径
        guard let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("无法访问文档目录.")
            return
        }
        
        // 拼接输出文件路径
        let outputURL = documentDirectoryURL.appendingPathComponent(name)
        
        // 保存 PDF 文档到指定路径
        pdfDocument.write(to: outputURL)
        print("PDF 文件已保存至: \(outputURL)")
    }
    
    
    
    // 打开通知服务CCCD
    func enableNotification(_ peripheral: CBPeripheral) {
        // 将CCCD的值设置为1，表示打开通知服务
        let value: [UInt8] = [0x01, 0x00]
        let cccd = CBUUID(string: "2902")
        let characteristic = peripheral.services?.first?.characteristics?.first(where: { $0.uuid == cccd })
        peripheral.writeValue(Data(value), for: characteristic!, type: .withResponse)
    }
    
    
    //设备连接失败代理
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
 
        //断开蓝牙做相对应的处理
        if successList.count > 0{
            for model in successList {
                if model.mPeripheral == peripheral {
                    successList.removeAll { $0 as BleModel === model as BleModel }
                }
            }
        }
        SwiftEventBus.post("disconnectEvent",sender: successList)
        // Handle error
        print("连接设备失败，重新连接扫描服务...")
    }
    
    /// 开启通知
    public func nofity(_ model:BleModel?, characteristic: CBCharacteristic?,open:Bool){
        //c = characteristic
        if let model = model,let characteristic = characteristic{
            model.mPeripheral!.setNotifyValue(open, for: characteristic)
        }
    }
    
    /// 读取蓝牙值
    public func read(_ model:BleModel?,characteristic: CBCharacteristic?){
        //c = characteristic
        if let model = model,let characteristic = characteristic{
            model.mPeripheral!.readValue(for: characteristic)
        }
    }
    
    //写入蓝牙数据
    func writeValue(_ value:Data?, _ character:CBCharacteristic?, _ periperal:CBPeripheral?){
        if value != nil && character != nil && periperal != nil {
            writeataValue(value!, for: character, periperalData: periperal)
        }
    }
    
    func writeataValue(_ value:Data, for characteristic: CBCharacteristic?, periperalData periperal: CBPeripheral?){
        let data:Data = value
        if (characteristic?.properties.rawValue)! & CBCharacteristicProperties.writeWithoutResponse.rawValue != 0 {
            periperal?.writeValue(data, for: characteristic!, type: .withoutResponse)
        } else {
            
            periperal?.writeValue(data, for: characteristic!, type: .withResponse)
        }
    }
    
    /**
     -写入后的回掉方法
     -参数外围设备：<＃外围设备描述＃>
     -参数特征：<＃特征描述＃>
     -参数错误：<＃错误描述＃>
     */
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
       // print("didWriteValueForCharacteristic")
        if error != nil {
            if let error = error {
                print("写入数据失败--\(error)")
                SwiftEventBus.post("writeValueError",sender: "write data \(error)")
            }
            return
        }
    }
    
    //取消Ota升级
    func cancelOtaUpdate(model:BleModel) {
        isOta = false
        isWritePacketDataSuccess = false
        //移除列表数据
        successList.removeAll()
        dHandler.commandArray.removeAllObjects()
        if model.mPeripheral != nil {
            centerManager!.cancelPeripheralConnection(model.mPeripheral!)
        }
    }
    
}


