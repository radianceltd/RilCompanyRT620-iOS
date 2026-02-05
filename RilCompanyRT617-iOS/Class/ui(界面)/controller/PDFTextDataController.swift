//
//  PDFTextDataController.swift
//  RilCompanyRT617-iOS
//
//  Created by RND on 2023/10/25.
//

import UIKit
import PDFKit
import WHToast
import SwiftEventBus
import MBProgressHUD

class PDFTextDataController: NavigationController, ProgressViewDelegate {
    
    var readPdfName: String?
    var read = Read()
    var pdfNowFileSize: UInt64?
    var pdfNowFileSizeStr: String?
    var bleModel = BleModel()
    var pdfView: PDFView!
    var allExpanded = AllExpanded()
    
    // 启动菊花弹窗
    private var hud: MBProgressHUD?
    var progressView: ProgressView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 导航栏中间的标题
        aboutNavigationCenter(title: "PDF")
        // 设置右侧菜单按钮
        aboutNavigationRight(isTure: true, isNameImage: "share", isNameText: "")
    }
    
    override func initView() {
        // 初始化视图
    }
    
    // 重写右侧按钮点击事件 - 直接弹出系统分享
    override func onToClick() {
        sharePDFWithSystemShareSheet()
    }
    
    // 使用系统分享功能分享PDF
    func sharePDFWithSystemShareSheet() {
        // 获取PDF文件路径
        guard let pdfURL = getPDFFileURL() else {
            WHToast.showMessage("The PDF file does not exist", originY: 500, duration: 2, finishHandler: nil)
            return
        }
        
        // 检查文件是否存在
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: pdfURL.path) else {
            WHToast.showMessage("The PDF file does not exist", originY: 500, duration: 2, finishHandler: nil)
            return
        }
        
        // 创建系统分享控制器
        let activityViewController = UIActivityViewController(
            activityItems: [pdfURL],
            applicationActivities: nil
        )
        
        // 排除一些不需要的分享选项（可选）
        activityViewController.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .markupAsPDF
        ]
        
        // 设置分享完成回调
        activityViewController.completionWithItemsHandler = { [weak self] (activityType, completed, returnedItems, error) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    print("Share failure: \(error.localizedDescription)")
                    WHToast.showMessage("Share failure: \(error.localizedDescription)", originY: 500, duration: 2, finishHandler: nil)
                } else if completed {
                    let activityTypeString = activityType?.rawValue ?? "unknown"
                    print("Share success! type: \(activityTypeString)")
               
                    // 根据分享类型显示不同的提示
                    if activityTypeString.contains("Mail") {
                        // 邮件分享
                        WHToast.showMessage("The email has been added to the sending queue", originY: 500, duration: 2, finishHandler: nil)
                        
                        // 邮件发送可能需要时间，添加额外提示
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            WHToast.showMessage("The email is being sent. Please check your inbox later", originY: 500, duration: 3, finishHandler: nil)
                        }
                    } else {
                        // 其他分享方式
                        WHToast.showMessage("Share success!", originY: 500, duration: 2, finishHandler: nil)
                    }
                    
                } else {
                    print("The sharing has been cancelled.")
                }
            }
        }
        
        // 适配iPad - 设置弹出位置
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.width - 50, y: 100, width: 0, height: 0)
            popoverController.permittedArrowDirections = .up
        }
        
        // 显示分享界面
        present(activityViewController, animated: true, completion: nil)
    }
 
    
    // 获取PDF文件URL
    private func getPDFFileURL() -> URL? {
        guard let pdfName = readPdfName else {
            return nil
        }
        
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let pdfFolderURL = documentsURL.appendingPathComponent("PDF")
        let fileURL = pdfFolderURL.appendingPathComponent(pdfName)
        
        return fileURL
    }
    
    override func initData() {
        var a: Int = 0
        
        showPDF()
        
        // 结束接收0x05指令的广播事件
        SwiftEventBus.onMainThread(self, name: CSVFILEPARAMES) { [self] result in
            // 此处的接收是关键
            if let data = result?.object as? [UInt8] {
                if a == 0 {
                    createPDFDirectory(data: data, fileName: readPdfName!)
                    a = a + 1
                }
            } else {
                print("pdf nil result.")
                WHToast.showMessage("pdf nil result!", originY: 500, duration: 2, finishHandler: nil)
                progressView?.hide()
            }
            // 判断一旦接收到结束0x07指令就关闭加载框
            progressView?.hide()
        }
        
        // 进度条功能
        SwiftEventBus.onMainThread(self, name: PROGRESS_INT) { [self] result in
            if let data = result?.object as? Int {
                DispatchQueue.main.async { [self] in
                    progressView!.downView?.musicalProgress = CGFloat(Double(data) / 100.0)
                    // 隐藏
                    if data == 100 {
                        progressView?.hide()
                    }
                }
            }
        }
    }
    
    // 显示
    func showHud() {
        hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.bezelView.style = .solidColor
        hud?.bezelView.color = UIColor.black.withAlphaComponent(0.7)
        hud?.label.text = NSLocalizedString("File Reading...", comment: "HUD loading title")
        hud?.contentColor = UIColor.white
    }
    
    // 隐藏
    func hidHud() {
        hud?.hide(animated: true, afterDelay: 0.5)
    }
    
    // 显示PDF
    func showPDF() {
        print("readPdfName!", readPdfName!)
        pdfNowFileSizeStr = CommonDefaults.shared.getValue(readPdfName!)
        
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        // 显示PDF文件到view上
        let pdfFolderURL = documentsURL.appendingPathComponent("PDF")
        let fileURL = pdfFolderURL.appendingPathComponent("\(readPdfName!)")
        
        let fileSizeString = String(read.fileSize)
        if pdfNowFileSizeStr == fileSizeString {
            if let pdfDocument = PDFDocument(url: fileURL) {
                let pdfView = PDFView(frame: view.bounds)
                pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                pdfView.displayMode = .singlePageContinuous
                pdfView.displayDirection = .vertical
                pdfView.document = pdfDocument
                view.addSubview(pdfView)
            } else {
                sendBleProment(bleOne: 3, bleTwo: 4)
                sendGetPDFfileData(inssub: 0x04)
            }
        } else {
            sendBleProment(bleOne: 3, bleTwo: 4)
            sendGetPDFfileData(inssub: 0x04)
        }
    }
    
    func sendBleProment(bleOne: UInt8, bleTwo: UInt8) {
        let ins: UInt8 = 0x07
        let len: UInt8 = 4
        
        // 创建 data 数组
        let data: [UInt8] = [3, 1, bleOne, bleTwo]
        
        let packet = self.allExpanded.buildInstructionPacket(ins: ins, len: len, data: data)
        let hexString = self.allExpanded.hexadecimalString(from: packet)
        print(hexString)
        
        BleManager.shared.writeValue(packet, self.bleModel.mSendotacharater, self.bleModel.mPeripheral)
    }
    
    func createPDFDirectory(data: [UInt8], fileName: String) {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("无法获取文档目录路径")
            return
        }
        
        let pdfFolderURL = documentsDirectory.appendingPathComponent("PDF")
        
        do {
            try fileManager.createDirectory(at: pdfFolderURL, withIntermediateDirectories: true, attributes: nil)
            
            let pdfFileURL = pdfFolderURL.appendingPathComponent(fileName)
            let pdfData = Data(bytes: data)
            
            let pdfDocument = PDFDocument(data: pdfData)
            if pdfDocument != nil {
                pdfDocument!.write(to: pdfFileURL)
                showPDF()
                sendBleProment(bleOne: 40, bleTwo: 80)
                print("PDF 文件夹创建成功，并成功生成 PDF 文件")
                print("文件路径：\(pdfFileURL.path)")
            } else {
                print("无法创建 PDF 文档")
            }
            
        } catch {
            print("创建 PDF 文件夹失败：\(error.localizedDescription)")
        }
    }
    
    // 发送读取文件名数据文件
    func sendGetPDFfileData(inssub: UInt8) {
        openShowWindow()
        
        let ins: UInt8 = 0x03
        let inssub: UInt8 = inssub
        
        var uint8Array = [UInt8]()
        for char in readPdfName!.utf8 {
            uint8Array.append(char)
        }
        
        let length = Int(uint8Array.count) + 2
        let packet = self.allExpanded.combineData(ins: ins, len: UInt8(length), inssub: inssub, data: uint8Array)
        
        let hexString = self.allExpanded.hexadecimalString(from: packet)
        print(hexString)
        
        // 得到大小
        BleManager.shared.fileSize = Int(read.fileSize)
        
        // 存储大小，用于判断下次进入读取时，大小如果不同，就获取新的数据;
        CommonDefaults.shared.saveValue(String(read.fileSize), forKey: readPdfName!)
        
        BleManager.shared.writeValue(packet, self.bleModel.mSendotacharater, self.bleModel.mPeripheral)
    }
    
    func openShowWindow() {
        progressView = ProgressView()
        progressView?.delegate = self
        progressView?.downView?.totalLoadLb.isHidden = true
        progressView?.downView?.currentLoadLb.isHidden = true
    }
    
    /// 关闭界面
    func closeAction() {
        // 断开所有的蓝牙
        BleManager.shared.disConnectBle()
        
        SwiftEventBus.unregister(self)
        // 断开界面
        for controller in self.navigationController?.viewControllers ?? [] {
            if (controller is BleDeviceController) {
                let vc = controller as? BleDeviceController
                if let vc = vc {
                    print("accutherm:==我设置断开退出啦")
                    self.navigationController?.popToViewController(vc, animated: true)
                }
            }
        }
    }
    
    // 界面消失的时候
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SwiftEventBus.unregister(self)
    }
}
