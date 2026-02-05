//
//  OtaViewController.swift
//  TMW041RT
//
//  Created by RND on 2023/3/28.
//

import UIKit
import WHToast
import cysmart_ota_update

class OtaViewController:NavigationController,OtaViewProtocol{
    
    let MAX_DATA_SIZE = 133
    
    var timer: Timer?
    
    var otaView = OtaView()
    
    var model:FileModel?
    
    var bleModel:BleModel?
    
    var filePath: String?
    
    var fileName: String?
    
    var fileHeaderDictionary = [String: String]()
    
    var firmWareRowDataArray = [Any]()
    
    //OTA升级新增
    var isBootLoaderCharacteristicFound = false
    
    var currentIndex = 0
    
    private var cmUtil = UpgradeUtil()
    
    var currentArrayID: String?
    
    var currentRowNumber = 0
    
    var currentRowDataArray = [Any]()
    
    var qq = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //导航栏中间的标题
        aboutNavigationCenter(title: "Ota")
        
        //左侧
        //aboutNavigationLeft(isBack: true)
        
    }
    
    override func initView() {
        super.initView()
        
        print("我进来了OTA界面!!")
        
        otaView.delegate = self
        otaView.frame = self.view.bounds
        self.view.addSubview(otaView)
        
        //默认隐藏
        otaView.cancelBtn?.isHidden = true
    }
    
    override func initData() {
        //必须重制为0不然不能运行重复的升级
        BleManager.shared.dHandler.startRowNumber = 0
        BleManager.shared.dHandler.endRowNumber = 0
        otaView.downView?.totalLoadLb.isHidden = true
        otaView.downView?.currentLoadLb.isHidden = true

        initServiceModel()
        
    }
    
    func initServiceModel() {
        BleManager.shared.dHandler.discoverCharacteristics(completionHandler: { success, error in
            if success {
                self.isBootLoaderCharacteristicFound = true
            }
        })
    }
  
    /*
     Check Files
     */
    func initializeFileTransfer() {
        if isBootLoaderCharacteristicFound {
            currentIndex = 0
            handleCharacteristicUpdates()
            // Set the checksum type
            if fileHeaderDictionary.count > 0{
                if Int(fileHeaderDictionary[CHECKSUM_TYPE]!) != 0 {
                   BleManager.shared.dHandler.checkSumType = CRC_16
                } else {
                   BleManager.shared.dHandler.checkSumType = CHECK_SUM
               }
            }else{
                WHToast.showMessage("File error, please re-import!", originY: 500, duration: 2, finishHandler: nil)
            }
   
            let dic: [AnyHashable : Any] = [:]
            // Write the ENTER_BOOTLOADER command
            let data = BleManager.shared.dHandler.createCommandPacket(withCommand: UInt8(ENTER_BOOTLOADER), dataLength: 0, data: dic)
            
            BleManager.shared.dHandler.writeOtaValueToCharacteristic(with: data, otaCharater: (bleModel?.mSendotacharater)!, otaPeripheral: (bleModel?.mPeripheral)!, bootLoaderCommandCode: UInt16(ENTER_BOOTLOADER))
        }
    }
    
    
    func startParsingFirmwareFile(_ model:FileModel) {
        
        fileName = model.filename
        filePath = model.filepath
        
        let fileParser = UpgradeFileParser()
        
        fileParser.parseFirmwareFile(withName: fileName!, andPath: filePath!, onFinish: { header, rowData, rowIdArray, error in
            if rowIdArray.count > 0 {
                self.fileHeaderDictionary = header as! [String : String]
                self.firmWareRowDataArray = rowData
            }
        })
    }
    
    func handleCharacteristicUpdates() {
        
        BleManager.shared.dHandler.updateValue(for: (bleModel?.mSendotacharater)!, otaPeripheral: (bleModel?.mPeripheral)!, withCompletionHandler: {
            success, commandCode, error in
            if success {
                self.handleResponseFromCharacteristic(forCommand: commandCode)
            }
        })
    }
    
    func handleResponseFromCharacteristic(forCommand commandCode: Any?) {
        
        if let commandCode = commandCode {
            print("commandCode is \(commandCode)")
        }
        
        if commandCode as! NSObject == NSNumber(value: ENTER_BOOTLOADER) {
            if ((fileHeaderDictionary[SILICON_ID] as AnyObject).lowercased == BleManager.shared.dHandler.siliconIDString) && (fileHeaderDictionary[SILICON_REV] == BleManager.shared.dHandler.siliconRevString) {
                
                let dataDict = cmUtil.changerFirstData(firmWareRowDataArray, currentIndex: currentIndex)
                
                let data = BleManager.shared.dHandler.createCommandPacket(withCommand: UInt8(GET_FLASH_SIZE), dataLength: 1, data: dataDict)
                
                // Initilaize the arrayID
                currentArrayID = cmUtil.currentArrayId(firmWareRowDataArray, currentIndex: currentIndex)
                
                BleManager.shared.dHandler.writeOtaValueToCharacteristic(with: data, otaCharater: (bleModel?.mSendotacharater)!, otaPeripheral: (bleModel?.mPeripheral)!, bootLoaderCommandCode: UInt16(GET_FLASH_SIZE))
            } else {
                print("Ota upgrade fail!")
                
                //取消ota升级的操作
                BleManager.shared.cancelOtaUpdate(model: bleModel!)
                
                //对话框提示错误
                WHToast.showMessage("Device Update fail!", originY: 500, duration: 2, finishHandler: nil)
                
                //返回操作
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        else if commandCode as! NSObject == NSNumber(value: GET_FLASH_SIZE){
            writeFirmWareFileData(at: currentIndex)
        }
        
        else if commandCode as! NSObject == NSNumber(value: SEND_DATA){
            if BleManager.shared.isWritePacketDataSuccess {
                writeCurrentRowDataArray(index: currentIndex)
            }
        }
        
        else if commandCode as! NSObject ==  NSNumber(value: PROGRAM_ROW){
            if BleManager.shared.isWritePacketDataSuccess {
                
                let dataDict = cmUtil.changeVerifyRow(firmWareRowDataArray, currentIndex: currentIndex, currentRow: currentRowNumber)
                
                let verifyRowData = BleManager.shared.dHandler.createCommandPacket(withCommand: UInt8(VERIFY_ROW), dataLength: 3, data: dataDict)
                
                BleManager.shared.dHandler.writeOtaValueToCharacteristic(with: verifyRowData, otaCharater: (bleModel?.mSendotacharater)!, otaPeripheral: (bleModel?.mPeripheral)!, bootLoaderCommandCode: UInt16(VERIFY_ROW))
                
            }
        }
        
        else if commandCode as! NSObject == NSNumber(value: VERIFY_ROW) {
            qq = true;
            let sum = cmUtil.rowCheckSumUint8(firmWareRowDataArray, currentIndex: currentIndex)
            
            print("SUM IS \(BleManager.shared.dHandler.checkSum)")
            
            if sum == BleManager.shared.dHandler.checkSum {
                currentIndex += 1
                
                //布局改变
                let percentage = Float(currentIndex) / Float(firmWareRowDataArray.count)
                
                if percentage <= 1.0 {
                    otaView.downView?.musicalProgress = CGFloat(percentage)
                    //otaView.downView?.currentLoadLb.text = String(currentIndex)
                } else {
                    otaView.downView?.musicDownLoadLab.text = "OTA Complete"
                }
                
                //刷新
                UIView.animate(withDuration: 1, animations: {
                    self.view.layoutIfNeeded()
                })
                
                // Writing the next line from file
                if currentIndex < firmWareRowDataArray.count {
                    writeFirmWareFileData(at: currentIndex)
                } else {
                    let dic: [AnyHashable : Any] = [:]
                    // Write VERIFY_CHECKSUM command
                    let data = BleManager.shared.dHandler.createCommandPacket(withCommand: UInt8(VERIFY_CHECKSUM), dataLength: 0, data: dic)
                    
                    BleManager.shared.dHandler.writeOtaValueToCharacteristic(with: data, otaCharater: (bleModel?.mSendotacharater)!, otaPeripheral: (bleModel?.mPeripheral)!, bootLoaderCommandCode: UInt16(VERIFY_CHECKSUM))
                    
                }
            }else{
                currentIndex = 0
            }
        }
        else if commandCode as! NSObject == NSNumber(value: VERIFY_CHECKSUM) {
            
            if BleManager.shared.dHandler.isApplicationValid {
                otaView.downView?.musicDownLoadLab.text="Upgarde...";
                let dic: [AnyHashable : Any] = [:]
                // Exit Boot
                let exitBootData = BleManager.shared.dHandler.createCommandPacket(withCommand: UInt8(EXIT_BOOTLOADER), dataLength: 0, data: dic)
                BleManager.shared.dHandler.writeOtaValueToCharacteristic(with: exitBootData, otaCharater: (bleModel?.mSendotacharater)!, otaPeripheral: (bleModel?.mPeripheral)!, bootLoaderCommandCode: UInt16(EXIT_BOOTLOADER))
                
                //升级完成需要执行的
                //BleManager.shared.cancelOtaUpdate(model: bleModel!)
                
                WHToast.showMessage("Device Update Grade!", originY: 500, duration: 2, finishHandler: nil)
                
                BleManager.shared.isOta = false
                
                //返回操作
                self.navigationController?.popViewController(animated: true)
                
            }else{
                //当前改为0
                currentIndex = 0
            }
        }
    }
    
    func writeFirmWareFileData(at index: Int) {
        
        let rowDataDicts = firmWareRowDataArray[index] as? [AnyHashable: Any]
        
        // Check for change in arrayID
        if !(rowDataDicts![ARRAY_ID] as? String == currentArrayID) {
            // GET_FLASH_SIZE command is passed to get the new start and end row numbers
            let rowDataDictionary = firmWareRowDataArray[index] as? [AnyHashable : Any]
            var dict: [AnyHashable : Any]? = nil
            if let object = rowDataDictionary?[ARRAY_ID] {
                dict = [FLASH_ARRAY_ID : object]
            }
            let data = BleManager.shared.dHandler.createCommandPacket(withCommand: UInt8(GET_FLASH_SIZE), dataLength: 1, data: dict!)
            BleManager.shared.dHandler.writeOtaValueToCharacteristic(with: data, otaCharater: (bleModel?.mSendotacharater)!, otaPeripheral: (bleModel?.mPeripheral)!, bootLoaderCommandCode: UInt16(GET_FLASH_SIZE))
            currentArrayID = rowDataDictionary?[ARRAY_ID] as? String
            return
        }
        
        currentRowNumber = Int(cmUtil.getIntegerFromHexString((rowDataDicts![ROW_NUMBER]) as! String))
        
        print("\(BleManager.shared.dHandler.startRowNumber)")
        print("\(BleManager.shared.dHandler.endRowNumber)")
        
        if currentRowNumber >= BleManager.shared.dHandler.startRowNumber && currentRowNumber <= BleManager.shared.dHandler.endRowNumber {
            // Write data using PROGRAM_ROW command
            currentRowDataArray = rowDataDicts![DATA_ARRAY] as! [Any]
            writeCurrentRowDataArray(index: index)
        } else {
            currentIndex = 0
        }
    }
    
    func writeCurrentRowDataArray(index: Int) {
        
        let rowDataDict = firmWareRowDataArray[index] as? [AnyHashable: Any]
        
        if currentRowDataArray.count > MAX_DATA_SIZE {
            
            let dataDict = cmUtil.changerDictionary(currentRowDataArray)
            
            let data = BleManager.shared.dHandler.createCommandPacket(withCommand: UInt8(SEND_DATA), dataLength: UInt16(MAX_DATA_SIZE), data: dataDict)
            
            BleManager.shared.dHandler.writeOtaValueToCharacteristic(with: data, otaCharater: (bleModel?.mSendotacharater)!, otaPeripheral: (bleModel?.mPeripheral)!, bootLoaderCommandCode: UInt16(SEND_DATA))
            
            currentRowDataArray = cmUtil.removeData(currentRowDataArray)
            //cmUtil.remove(currentRowDataArray as! NSMutableArray)
            
        } else {
            
            let dict = cmUtil.changeLastPacketDict(currentRowDataArray, row: currentRowNumber, dict: rowDataDict!)
            
            let lastChunkData = BleManager.shared.dHandler.createCommandPacket(withCommand: UInt8(PROGRAM_ROW), dataLength: (UInt16(currentRowDataArray.count)+3), data: dict)
            
            BleManager.shared.dHandler.writeOtaValueToCharacteristic(with: lastChunkData, otaCharater: (bleModel?.mSendotacharater)!, otaPeripheral: (bleModel?.mPeripheral)!, bootLoaderCommandCode: UInt16(PROGRAM_ROW))
        }
    }
    
    @objc func timerRun(){
        if !qq {
            print("升级失败，其他原因或者没有配对，请重新执行")
            let yes = NSLocalizedString("Comfirm", comment: "")
            let Tips = NSLocalizedString("Tips", comment: "")

            let alertController = UIAlertController(title: Tips, message: "Upgrade failure, other reasons or no pairing, please re-execute", preferredStyle: .alert)

            let yesAction = UIAlertAction(title: yes, style: .default, handler: { action in
                    //确定事件
                    //[[BleManager sharedManager] disConnectBle];
                    self.onCancel()
                    for controller in self.navigationController?.viewControllers ?? [] {
                        if (controller is OtaViewController) {
                            let vc = controller as? OtaViewController
                            if let vc = vc {
                                self.navigationController?.popToViewController(vc, animated: true)
                            }
                        }
                    }
                })

            if timer != nil {
                timer!.invalidate()
                timer = nil
            }
            alertController.addAction(yesAction)
            present(alertController, animated: true)
        }
    }
    
    func onUpdate() {
        //print("on-Update")
        
        if model?.filepath != nil {
            
            if bleModel?.mPeripheral != nil {
                otaView.selectBtn?.isHidden = true
                otaView.updateBtn?.isEnabled = false
                otaView.cancelBtn?.isHidden = false
                
                otaView.updateBtn?.backgroundColor = UIColor.gray
                
                startParsingFirmwareFile(model!)
                initializeFileTransfer()
                
                timer = Timer(timeInterval: 3.0, target: self, selector: #selector(timerRun), userInfo: nil, repeats: true)
                RunLoop.current.add(timer!, forMode: .default)
            }else{
                WHToast.showMessage("Bluetooth connection failed!. Please connect again.", originY: 500, duration: 2, finishHandler: nil)
            }
            
        }else{
            WHToast.showMessage("Please select file!", originY: 500, duration: 2, finishHandler: nil)
        }
        
    }
    
    func onSelect() {
        print("on-Select")
        //选择文件
        let file = FilelistViewController()
        self.navigationController?.pushViewController(file, animated:true)
    }
    
    func onCancel() {
        print("on-Cancel")
        //取消ota升级的操作
        BleManager.shared.cancelOtaUpdate(model: bleModel!)
        
        //返回操作
        self.navigationController?.popViewController(animated: true)
    }
    
}
