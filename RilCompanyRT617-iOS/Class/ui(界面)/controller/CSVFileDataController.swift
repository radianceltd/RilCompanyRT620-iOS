//
//  FileViewController.swift
//  RilCompanyRT617-iOS
//
//  Created by RND on 2023/8/15.
//

import UIKit
import WHToast
import SwiftEventBus

class CSVFileDataController:NavigationController,UITableViewDelegate,UITableViewDataSource{
    
    var bleModel = BleModel()
    var readModel = Read()
    var read = ReadModel()
    var csvView = CSVView()
    
    //文件选择
    private var dataList = [FileModel]()
    
    var allExpanded = AllExpanded()
    
    let CELLIDENTIFITER = "CSVLISTTABLEVIEWCELL"
    
    var csvFileName: String?
    
    //    var csvFileText:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //导航栏中间的标题
        aboutNavigationCenter(title: "CsvFile")
        
        //读取csv文件数据
        sendGetCSVfileData(inssub: 0x05)
    }
    
    //右侧
    override func aboutNavigationRight(isTure:Bool,isNameImage:String,isNameText:String){
        if(isTure){
            let item = UIBarButtonItem(image: UIImage(named: "file"), style: .plain, target: self, action: #selector(onToClick))
            item.tintColor = UIColor.white
            navigationItem.rightBarButtonItem = item
        }
    }
    
    override func initView() {
        
        let view = UIView()
        csvView.tableView?.delegate = self
        csvView.tableView?.dataSource = self
        csvView.tableView?.tableFooterView = view
        csvView.frame = self.view.bounds
        self.view.addSubview(csvView)
    }
    
    override func initData() {
        var a:Int = 0
        csvFileName = readModel.fileName
        
        // 接收到APP发送读取CSV文件数据的设备，设备返回过来的通知数据，进行解析
        SwiftEventBus.onMainThread(self, name: CSVFILEPARAMES){ [self]
            result in
            
            // 此处的接收是关键
            read.req = result?.object as! [UInt8]
            print("data==:",read.req)
            
            //创建文件并将数据写入CSV
            if a == 0{
                //创建csv文件存储到沙盒中
                creationCsvFile()
                
                //调用沙盒中已存在的列表
                self.readSandBoxFile()
                a = a + 1
            }
        }
    }
    //第一步，根据CSV界面的列表，传递名称byte数组，进行发送到设备，以获取到当前csv文件里面的数据内容
    //发送读取csv文件名文件
    func sendGetCSVfileData(inssub:UInt8){
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
        
        WHToast.showMessage("Set CSVDataFile Success!", originY: 500, duration: 2, finishHandler: {
        })
    }
    
    //创建csv文件到本地存储
    func creationCsvFile(){
        
        if let result = allExpanded.createCSVAndWriteData(data: read.req, fileName: csvFileName!) {
            // 成功获得 csvString 的值
            print("CSV 字符串：\(result)")
            //self.csvFileText = result
        } else {
            // 处理失败情况
            print("操作失败")
        }
    }

    //读取沙盒中的文件
    func readSandBoxFile(){
        dataList.removeAll()
        
        let documentPaths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).map(\.path)
        let documentsDirPath = documentPaths[0]
        let fm = FileManager.default
        var dirContents: [String]? = nil
        do {
            dirContents = try fm.contentsOfDirectory(atPath: documentsDirPath+"/CSV")
        } catch {
            print("Get File Error!")
        }
        
        //自定义过滤器
        let predicate = NSPredicate(format: "pathExtension == 'CSV'")
        
        //过滤数据
        let fileNameArray = dirContents?.filter({
            return predicate.evaluate(with: $0)
        })
        
        if fileNameArray == nil{
            return
        }
        
        for filename in fileNameArray! {
            let model = FileModel()
            model.filename = filename
            model.filepath = documentsDirPath
            // 读取CSV文件内容
            let fileURL = URL(fileURLWithPath: "\(documentsDirPath)/CSV/\(filename)")
            do {
                let fileContents = try String(contentsOf: fileURL)
                model.fileCsvTextLb = fileContents
            } catch {
                print("Error reading file: \(error)")
            }
            dataList.append(model)
        }
        
        if dataList.count>0 {
            csvView.tableView?.reloadData()
        }
    }
    
    //无通知数据发送指令到设备
    @objc override func onToClick(){
        //无文件通知读取文件结束指令
        sendNofileNotice(inssub: 0xFF)
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
            // model.fileCsvTextLb = self.csvFileText
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
        //        if dataList.count() > 0 {
        //            let readmodel = dataList.get(index: indexPath.row)
        //
        //            let csvdText = CSVTextDataController()
        //
        //            csvdText.readModel = readmodel
        //            self.navigationController?.pushViewController(csvdText, animated: true)
        //        }
        if dataList.count > 0 {
            
            //let model = FileModel()
            
            // model.fileCsvTextLb = self.csvFileText
            
            let readmodel = dataList[indexPath.row]
            
            let csvdText = CSVTextDataController()
            //csvdText.bleModel = model
           // csvdText.readModel = readmodel.fileCsvTextLb
            self.navigationController?.pushViewController(csvdText, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let fileModel = dataList[indexPath.row]
            let filePath = fileModel.filepath! + "/CSV/" + fileModel.filename!
            
            do {
                try FileManager.default.removeItem(atPath: filePath)
                dataList.remove(at: indexPath.row)
                csvView.tableView?.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print("Failed to delete file:", error.localizedDescription)
            }
            // 执行删除操作，比如删除数据源中的数据
            // dataList.remove(at: indexPath.row)
            
            csvView.tableView?.reloadData()
            // 删除tableView中的对应行
            //tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
}

