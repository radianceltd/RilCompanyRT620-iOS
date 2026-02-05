//
//  DFUViewController.swift
//  RilCompanyRT617-iOS
//
//  Created by RND on 2023/7/26.
//

import UIKit
import CoreBluetooth
import iOSDFULibrary
import WHToast

class DFUViewController: NavigationController,DFUServiceDelegate, DFUProgressDelegate, LoggerDelegate, DFUViewProtocol {
    
    private var dfuController    : DFUServiceController!
    
    var bleModel:BleModel?
    
    var model:FileModel?
    
    var dfuView = DFUView()
    
    var filePath: String?
    
    var fileName: String?
 
    override func viewDidLoad() {
        super.viewDidLoad()
        //导航栏中间的标题
        aboutNavigationCenter(title: "Ota")
        //startDFU()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(model?.filename != nil) {
            dfuView.downView?.musicDownLoadLab.text = model?.filename
        }
    }
    
    override func initView() {
        print("我进来了DFU界面!!")
    
        dfuView.delegate = self
        dfuView.frame = self.view.bounds
        self.view.addSubview(dfuView)
        
        //默认隐藏
        dfuView.cancelBtn?.isHidden = true
    }
    
    override func initData() {
        dfuView.downView?.totalLoadLb.isHidden = true
        dfuView.downView?.currentLoadLb.isHidden = true
    }
    
    
    func startDFU() {
        
        
//        guard let filePath = Bundle.main.path(forResource: "RT617_ota-TEST-V04", ofType: "zip") else {
//            return
//        }
        
       
        fileName = model?.filename
        filePath = model?.filepath
        
        //let ok = filePath+fileName
        
        //let fileURL = URL(fileURLWithPath: )
        
        //let trimmedStr = fileURL.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let selectedFirmware = try? DFUFirmware(urlToZipFile: URL(fileURLWithPath: filePath! + "/"+fileName!)) else { return }

        
        let dfuInitiator = DFUServiceInitiator(queue: DispatchQueue(label: "Other"))
        dfuInitiator.delegate = self
        dfuInitiator.progressDelegate = self
        dfuInitiator.logger = self
        //dfuInitiator.dataObjectPreparationDelay = 0.4
        dfuInitiator.disableResume = true
        dfuInitiator.alternativeAdvertisingNameEnabled = false
        dfuInitiator.enableUnsafeExperimentalButtonlessServiceInSecureDfu = true
        
        if #available(iOS 11.0, macOS 10.13, *) {
            //dfuInitiator.packetReceiptNotificationParameter = 0
        }
        
        dfuController = dfuInitiator.with(firmware: selectedFirmware).start(target: (bleModel?.mPeripheral)!)
    }
    
    func onUpdate() {
        if model?.filename != nil {
            dfuView.selectBtn?.isHidden = true
            dfuView.updateBtn?.isEnabled = false
            dfuView.cancelBtn?.isHidden = false
            
            startDFU()
        }else{
            WHToast.showMessage("Please select ota File", originY: 500, duration: 2, finishHandler: nil)
        }
    }
    
    func onSelect() {
        //选择文件
        let file = FilelistViewController()
        self.navigationController?.pushViewController(file, animated:true)
    }
    
    func onCancel() {
        //取消ota升级的操作
        cancel()
    }
    
    func cancel(){
        if(dfuController != nil){
            dfuController = nil
        }
        
        BleManager.shared.cancelOtaUpdate(model: bleModel!)
        //返回操作
        self.navigationController?.popViewController(animated: true)
    }
    
    

    // 升级状态回调
    func dfuStateDidChange(to state: DFUState) {
        switch state {
        case .completed:
            cancel()
        default:
            break
        }
    }

    // 升级进度回调，范围 1-100
    func dfuProgressDidChange(for part: Int, outOf totalParts: Int, to progress: Int, currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
        DispatchQueue.main.async { [self] in
            // 回主线程更新 UI
            print("part \(part),totalPart \(totalParts), progress \(progress)")
            dfuView.downView?.musicalProgress = CGFloat(Double(progress)/100.0)
        }
    }

    func dfuError(_ error: DFUError, didOccurWithMessage message: String) {
        print("⚠︎  dfuError: \(error), didOccurWithMessage: \(message)")
        WHToast.showMessage(message, originY: 500, duration: 2, finishHandler: nil)
        cancel()
        
    }

    func logWith(_ level: LogLevel, message: String) {
        print("⚠︎  logWith   \(level), message: \(message)")
    }
}
