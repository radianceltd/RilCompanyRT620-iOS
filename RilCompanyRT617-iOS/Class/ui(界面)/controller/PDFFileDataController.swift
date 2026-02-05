//
//  PDFFileDataController.swift
//  RilCompanyRT617-iOS
//
//  Created by RND on 2023/8/10.
//

import UIKit
import WHToast
import SwiftEventBus
import PDFKit
import MBProgressHUD

class PDFFileDataController:NavigationController,UITableViewDelegate,UITableViewDataSource{
    
    //文件选择
    private var dataList = Array<FileModel>()
    
    var bleModel = BleModel()
    var readModel = Read()
    
    var pdfView = PdfView()
    
    var allExpanded = AllExpanded()
    
    // 启动菊花弹窗
    private var hud:MBProgressHUD?
    
    let CELLIDENTIFITER = "PDFLISTTABLEVIEWCELL"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //导航栏中间的标题
        aboutNavigationCenter(title: "FileData")
        
        sendGetPDFfileData(inssub: 0x04)
        
    }
    
    override func initView() {
        
        let view = UIView()
        pdfView.tableView?.delegate = self
        pdfView.tableView?.dataSource = self
        pdfView.tableView?.tableFooterView = view
        pdfView.frame = self.view.bounds
        self.view.addSubview(pdfView)
    }
    
    //右侧
    override func aboutNavigationRight(isTure:Bool,isNameImage:String,isNameText:String){
        if(isTure){
            let item = UIBarButtonItem(image: UIImage(named: "file"), style: .plain, target: self, action: #selector(onToClick))
            item.tintColor = UIColor.white
            navigationItem.rightBarButtonItem = item
        }
    }
    
    //    override func viewWillAppear(_ animated: Bool) {
    //        readSandBoxFile()
    //    }
    
    override func initData() {
        var a:Int = 0
        dataList.removeAll()
        // 启动菊花弹窗
        showHud()
        
        // 获取model数据
        SwiftEventBus.onMainThread(self, name: CSVFILEPARAMES){ [self]
            result in
            
            // 此处的接收是关键
            let data = result?.object as! [UInt8]
            
            if a == 0{
                createPDFDirectory(data: data, fileName: readModel.fileName!)
                //调用沙盒中的列表
                self.readSandBoxFile()
                a = a + 1
            }
        
            //雪花加载消失
            hidHud()
        }
    }
    
    @objc override func onToClick(){
        
        //无文件通知读取文件结束指令
        sendNofileNotice(inssub: 0xFF)
    }
    
    //显示
    func showHud(){
        hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.bezelView.style = .solidColor
        hud?.bezelView.color = UIColor.black.withAlphaComponent(0.7)
        hud?.label.text = NSLocalizedString("File Reading...", comment: "HUD loading title")
        hud?.contentColor = UIColor.white
        
    }
    
    //隐藏
    func hidHud(){
        hud?.hide(animated: true, afterDelay: 0.5)
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
            
            //let data: [UInt8] = [0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x20, 0x57, 0x6F, 0x72, 0x6C, 0x64] // 替换为你的需要插入的 UInt8 数据
            
            let pdfFileURL = pdfFolderURL.appendingPathComponent(fileName)
            //let fileData = Data(bytes: data, count: data.count) // 将 UInt8 数据转换为 Data
            let pdfData = Data(bytes: data)
            
            let pdfDocument = PDFDocument(data: pdfData)
            if pdfDocument != nil {
                pdfDocument!.write(to: pdfFileURL)
                
                print("PDF 文件夹创建成功，并成功生成 PDF 文件")
                print("文件路径：\(pdfFileURL.path)")
            } else {
                print("无法创建 PDF 文档")
            }
            
        } catch {
            print("创建 PDF 文件夹失败：\(error.localizedDescription)")
        }
    }
    
    //读取沙盒中的文件
    func readSandBoxFile() {
        dataList.removeAll()
        
        let documentPaths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirPath = documentPaths[0].path + "/PDF"
        
        let fm = FileManager.default
        
        do {
            let dirContents = try fm.contentsOfDirectory(atPath: documentsDirPath)
            
            // 自定义过滤器
            let pdfPredicate = NSPredicate(format: "pathExtension == 'pdf'")
            
            // 过滤数据
            let pdfFileNameArray = dirContents.filter {
                return pdfPredicate.evaluate(with: $0)
            }
            
            for filename in pdfFileNameArray {
                let model = FileModel()
                model.filename = filename
                model.filepath = documentsDirPath
                dataList.append(model)
            }
            
            if dataList.count > 0 {
                pdfView.tableView?.reloadData() // 列表刷新
            }
            
            // 自定义过滤器
            let csvPredicate = NSPredicate(format: "pathExtension == 'csv'")
            
            // 过滤数据
            let csvFileNameArray = dirContents.filter {
                return csvPredicate.evaluate(with: $0)
            }
            
            for filename in csvFileNameArray {
                let model = FileModel()
                model.filename = filename
                model.filepath = documentsDirPath
                dataList.append(model)
            }
            
            if dataList.count > 0 {
                // 列表刷新
            }
        } catch {
            print("Get File Error!")
        }
    }
    
    
    //无文件通知
    func sendNofileNotice(inssub:UInt8){
        let ins: UInt8 = 0x03
        let len:UInt8 = 2
        let inssub:UInt8 = inssub
        let fsnn:UInt8 = 0x00
        
        let packet = self.allExpanded.noFileNotice(ins: ins, len: len,inssub:inssub,fsnn:fsnn)
        
        let hexString = self.allExpanded.hexadecimalString(from: packet)
        
        print(packet)
        print(hexString)
        
        BleManager.shared.writeValue(packet, self.bleModel.mSendotacharater, self.bleModel.mPeripheral)
        
        WHToast.showMessage("set getFileNotice Success!", originY: 500, duration: 2, finishHandler: {
        })
    }
    
    //发送读取文件名数据文件
    func sendGetPDFfileData(inssub:UInt8){
        let ins: UInt8 = 0x03
        let inssub:UInt8 = inssub
        let fsnn:UInt8 = 0x00
        
        let file16Name = self.allExpanded.hexadecimalString(from: (readModel.fileName?.data(using: .utf8))!)
        
        // let hexString = self.allExpanded.hexadecimalString(from: packet)
        
        // 计算文件的长度
        let length = Int(file16Name.count / 2) + 2
        // 计算文件名长度
        
        var uint8Array = [UInt8]()
        for char in readModel.fileName!.utf8 {
            uint8Array.append(char)
        }
        
        
        let packet = self.allExpanded.combineData(ins: ins, len: UInt8(length),inssub:inssub, data: uint8Array)
        
        let hexString = self.allExpanded.hexadecimalString(from: packet)
        
        print(hexString)
        
        BleManager.shared.writeValue(packet, self.bleModel.mSendotacharater, self.bleModel.mPeripheral)
        
//        WHToast.showMessage("set PDFDataFile Success!", originY: 500, duration: 2, finishHandler: {
//        })
        
    }
    
    //MARK: UITableView Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: FilelistViewCell? = tableView.dequeueReusableCell(withIdentifier: CELLIDENTIFITER) as? FilelistViewCell
        if cell == nil{
            cell = FilelistViewCell(style: .default, reuseIdentifier: CELLIDENTIFITER)
            cell!.selectionStyle = .none
            
        }
        
        if dataList.count > 0 {
            let model = dataList[indexPath.row]
            if model.filename != nil {
                cell?.mFileNameLb?.text = model.filename
            }
        }
        return cell!
    }
    
    //点击列表的事件方法
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //TODO: 点击 进行其他的操作
        var cell: FilelistViewCell? = tableView.dequeueReusableCell(withIdentifier: CELLIDENTIFITER) as? FilelistViewCell
        if cell == nil{
            cell = FilelistViewCell(style: .default, reuseIdentifier: CELLIDENTIFITER)
            cell!.selectionStyle = .none
            //cell!.delegate = self
        }
        
        //let model = dataList[indexPath.row]
        
        if dataList.count > 0 {
            let readmodel = dataList[indexPath.row]
            readModel.fileName = readmodel.filename
            let pdfText = PDFTextDataController()
            pdfText.readPdfName = readmodel.filename
            self.navigationController?.pushViewController(pdfText, animated: true)
  
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
}
