//
//  CSVTextDataController.swift
//  RilCompanyRT617-iOS
//
//  Created by RND on 2023/9/28.
//

import UIKit
import WHToast
import SwiftEventBus

class CSVTextDataController: NavigationController, ProgressViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var bleModel = BleModel()
    var read = ReadModel()
    var csvRead = Read()
    var dataList = LinkedHashMap<String, Read>()
    var readCsvFileName: String?
    var csvUnit: String?
    var communit = CommonUtil()
    var allExpanded = AllExpanded()
    var csvTextView = CsvTextView()
    var progressView: ProgressView?
    
    let CELLCSVTEXTDATACONTROLLER = "CELLCSVTEXTDATACONTROLLER"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        aboutNavigationLeft(isBack: false)
        // 导航栏中间的标题
        aboutNavigationCenter(title: "CSV")
        // 设置右侧分享按钮
        aboutNavigationRight(isTure: true, isNameImage: "share", isNameText: "")
    }
    
    // 重写右侧按钮点击事件
    override func onToClick() {
        shareCSVFile()
    }
    
    // 分享CSV文件
    func shareCSVFile() {
        // 先创建CSV文件
        guard let csvURL = createCSVFile() else {
            WHToast.showMessage("Failed to create CSV file", originY: 500, duration: 2, finishHandler: nil)
            return
        }
        
        // 检查文件是否存在
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: csvURL.path) else {
            WHToast.showMessage("The CSV file does not exist", originY: 500, duration: 2, finishHandler: nil)
            return
        }
        
        // 创建系统分享控制器
        let activityViewController = UIActivityViewController(
            activityItems: [csvURL],
            applicationActivities: nil
        )
        
        // 排除一些不需要的分享选项
        activityViewController.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .markupAsPDF
        ]
        
        // 设置分享完成回调
        activityViewController.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
            DispatchQueue.main.async {
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
    
    // 创建CSV文件
    private func createCSVFile() -> URL? {
        guard dataList.size() > 0 else {
            WHToast.showMessage("No data to export", originY: 500, duration: 2, finishHandler: nil)
            return nil
        }
        
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        // 创建CSV文件夹
        let csvFolderURL = documentsURL.appendingPathComponent("CSV")
        if !fileManager.fileExists(atPath: csvFolderURL.path) {
            do {
                try fileManager.createDirectory(at: csvFolderURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Failed to create CSV directory: \(error)")
                return nil
            }
        }
        
        // 生成文件名（使用当前时间戳）
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let timestamp = dateFormatter.string(from: Date())
        let fileName = "data_\(timestamp).csv"
        let fileURL = csvFolderURL.appendingPathComponent(fileName)
        
        // 创建CSV内容
        var csvContent = ""
        
        for i in 0..<dataList.size() {
            // 直接获取模型，因为 get(index:) 返回非可选类型
            let model = dataList.get(index: i)
            
            let fileTime = model.fileTime?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let fileData = model.fileData?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            
            // 处理温度1
            var temp1 = model.fileTemp1?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if let firstChar = temp1.first, firstChar == "0" {
                temp1.removeFirst()
            }
            // 去掉括号内容
            if let leftBracketIndex = temp1.firstIndex(of: "("),
               let rightBracketIndex = temp1.firstIndex(of: ")") {
                let rangeToRemove = leftBracketIndex...rightBracketIndex
                temp1.removeSubrange(rangeToRemove)
            }
            
            // 处理温度2
            var temp2 = model.fileTemp2?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if let firstChar = temp2.first, firstChar == "0" {
                temp2.removeFirst()
            }
            // 去掉括号内容
            if let leftBracketIndex = temp2.firstIndex(of: "("),
               let rightBracketIndex = temp2.firstIndex(of: ")") {
                let rangeToRemove = leftBracketIndex...rightBracketIndex
                temp2.removeSubrange(rangeToRemove)
            }
            
            // 添加单位
            if let unit = csvUnit {
                if Float(temp1) != nil {
                    if let convertedTemp1 = communit.isTempScope(temp: temp1, unit: unit) {
                        temp1 = convertedTemp1 + csvUnit!
                      
                    }
                }
                
                if Float(temp2) != nil {
                    if let convertedTemp2 = communit.isTempScope(temp: temp2, unit: unit) {
                        temp2 = convertedTemp2 + csvUnit!
                        
                    }
                }
            }
            
            // 转义CSV特殊字符
            let escapedTime = escapeCSVField(fileTime)
            let escapedData = escapeCSVField(fileData)
            let escapedTemp1 = escapeCSVField(temp1)
            let escapedTemp2 = escapeCSVField(temp2)
            
            csvContent += "\(escapedTime),\(escapedData),\(escapedTemp1),\(escapedTemp2)\n"
        }
        
        // 写入文件
        do {
            try csvContent.write(to: fileURL, atomically: true, encoding: .utf8)
            print("CSV file created at: \(fileURL.path)")
            return fileURL
        } catch {
            print("Failed to write CSV file: \(error)")
            WHToast.showMessage("Failed to create CSV file: \(error.localizedDescription)", originY: 500, duration: 2, finishHandler: nil)
            return nil
        }
    }
    
    // 转义CSV字段中的特殊字符
    private func escapeCSVField(_ field: String) -> String {
        // 如果字段包含逗号、双引号或换行符，需要用双引号包裹并转义双引号
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            let escaped = field.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }
        return field
    }
    
    // 失去界面的回调生命周期
    // 界面消失的时候
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SwiftEventBus.unregister(self)
    }
    
    // 视图将要显示
    override func viewWillAppear(_ animated: Bool) {
        sendBleProment(bleOne: 3, bleTwo: 4)
        // 读取csv文件数据
        sendGetCSVfileData(inssub: 0x05)
        csvUnit = CommonDefaults.shared.getValue(UNIT)
    }
    
    // 初始化View
    override func initView() {
        let view = UIView()
        csvTextView.tableView?.delegate = self
        csvTextView.tableView?.dataSource = self
        csvTextView.tableView?.tableFooterView = view
        csvTextView.frame = self.view.bounds
        self.view.addSubview(csvTextView)
    }
    
    override func initData() {
        // 接收到APP发送读取CSV文件数据的设备，设备返回过来的通知数据，进行解析
        SwiftEventBus.onMainThread(self, name: CSVFILEPARAMES) { result in
            // 此处的接收是关键
            
            if let readModel = result?.object as? ReadModel {
                self.read = readModel
                
                if self.read.list.count > 0 {
                    for (index, m) in self.read.list.enumerated() {
                        if let fileTime = m.fileTime {
                            let key = "\(fileTime)#\(index)"
                            self.dataList.put(key: key, value: m)
                        }
                    }
                }
                self.sendBleProment(bleOne: 40, bleTwo: 80)
                // 刷新数据
                self.csvTextView.tableView?.reloadData()
            } else {
                // result为nil的处理逻辑
                // 可以输出日志或进行其他操作
                print("csv nil result.")
                WHToast.showMessage("csv nil result!", originY: 500, duration: 2, finishHandler: {
                })
                self.progressView?.hide()
            }
            //            self.sendBleProment(bleOne: 40, bleTwo: 80)
            //            SwiftEventBus.unregister(self)
            self.progressView?.hide()
        }
        
        // 进度条功能
        SwiftEventBus.onMainThread(self, name: PROGRESS_INT) { [self] result in
            if let data = result?.object as? Int {
                DispatchQueue.main.async { [self] in
                    // 回主线程更新 UI
                    //print("part \(part),totalPart \(totalParts), progress \(progress)")
                    progressView!.downView?.musicalProgress = CGFloat(Double(data) / 100.0)
                    // 隐藏
                    if data == 100 {
                        self.sendBleProment(bleOne: 40, bleTwo: 80)
                        //SwiftEventBus.unregister(self)
                        progressView?.hide()
                    }
                }
            }
        }
    }
    
    func openShowWindow() {
        progressView = ProgressView()
        progressView?.delegate = self
        progressView?.downView?.totalLoadLb.isHidden = true
        progressView?.downView?.currentLoadLb.isHidden = true
        //progressView?.show()
    }
    
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
    
    // 发送蓝牙参数信息3，1，3，4 or 3，1，40，80
    func sendBleProment(bleOne: UInt8, bleTwo: UInt8) {
        let ins: UInt8 = 0x07
        let len: UInt8 = 4
        
        // 创建 data 数组，存储 aValue 和 bValue
        let data: [UInt8] = [3, 1, bleOne, bleTwo]
        
        let packet = self.allExpanded.buildInstructionPacket(ins: ins, len: len, data: data)
        let hexString = self.allExpanded.hexadecimalString(from: packet)
        print(hexString)
        
        BleManager.shared.writeValue(packet, self.bleModel.mSendotacharater, self.bleModel.mPeripheral)
    }
    
    // 发送读取csv文件名文件数据块
    func sendGetCSVfileData(inssub: UInt8) {
        // 打开加载窗口
        openShowWindow()
        
        let ins: UInt8 = 0x03
        let inssub: UInt8 = inssub
        let fsnn: UInt8 = 0x00
        
        let file16Name = self.allExpanded.hexadecimalString(from: (readCsvFileName?.data(using: .utf8))!)
        
        // let hexString = self.allExpanded.hexadecimalString(from: packet)
        
        // 计算文件的长度
        let length = Int(file16Name.count / 2) + 2
        
        // 计算文件名长度
        var uint8Array = [UInt8]()
        for char in readCsvFileName!.utf8 {
            uint8Array.append(char)
        }
        
        let packet = self.allExpanded.combineData(ins: ins, len: UInt8(length), inssub: inssub, data: uint8Array)
        
        let hexString = self.allExpanded.hexadecimalString(from: packet)
        
        print(hexString)
        
        // 得到大小
        BleManager.shared.fileSize = Int(csvRead.fileSize)
        
        BleManager.shared.writeValue(packet, self.bleModel.mSendotacharater, self.bleModel.mPeripheral)
    }
    
    // MARK: UITableView Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.size()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: CsvTextCell? = tableView.dequeueReusableCell(withIdentifier: CELLCSVTEXTDATACONTROLLER) as? CsvTextCell
        if cell == nil {
            cell = CsvTextCell(style: .default, reuseIdentifier: CELLCSVTEXTDATACONTROLLER)
            cell!.selectionStyle = .none
        }
        
        if dataList.size() > 0 {
            let model = dataList.get(index: indexPath.row)
            
            if let fileData = model.fileData {
                let trimmedFileData = fileData.trimmingCharacters(in: .whitespacesAndNewlines)
                cell?.mFileDataLb?.text = trimmedFileData
            }
            if let fileTime = model.fileTime {
                let trimmedFileTime = fileTime.trimmingCharacters(in: .whitespacesAndNewlines)
                cell?.mFileTimeLb?.text = trimmedFileTime
            }
            if let fileP1 = model.fileTemp1 {
                var trimmedFileTemp1 = fileP1
                if let firstCharacter = fileP1.first, firstCharacter == "0" {
                    trimmedFileTemp1.removeFirst()
                }
                
                // 去掉括号内的内容
                if let leftBracketIndex = trimmedFileTemp1.firstIndex(of: "("),
                   let rightBracketIndex = trimmedFileTemp1.firstIndex(of: ")") {
                    let rangeToRemove = leftBracketIndex...rightBracketIndex
                    trimmedFileTemp1.removeSubrange(rangeToRemove)
                }
                
                // 判断是否只包含数字
                if Float(trimmedFileTemp1) != nil {
                    let temp1 = communit.isTempScope(temp: trimmedFileTemp1, unit: csvUnit!)
                    
                    cell!.mFileTemp1Lb?.text = temp1! + csvUnit!
                } else {
                    // trimmedFileTemp1 包含字母或其他非数字字符
                    // 处理无法将字符串转换为浮点数的情况
                    cell!.mFileTemp1Lb?.text = trimmedFileTemp1
                }
            }
            if let fileP2 = model.fileTemp2 {
                var trimmedFileTemp2 = fileP2
                if let firstCharacter = fileP2.first, firstCharacter == "0" {
                    trimmedFileTemp2.removeFirst()
                }
                
                // 去掉括号内的内容
                if let leftBracketIndex = trimmedFileTemp2.firstIndex(of: "("),
                   let rightBracketIndex = trimmedFileTemp2.firstIndex(of: ")") {
                    let rangeToRemove = leftBracketIndex...rightBracketIndex
                    trimmedFileTemp2.removeSubrange(rangeToRemove)
                }
                
                // 判断是否只包含数字
                if Float(trimmedFileTemp2) != nil {
                    let temp2 = communit.isTempScope(temp: trimmedFileTemp2, unit: csvUnit!)
                    
                    cell!.mFileTemp2Lb?.text = temp2! + csvUnit!
                } else {
                    // trimmedFileTemp2 包含字母或其他非数字字符
                    // 处理无法将字符串转换为浮点数的情况
                    cell!.mFileTemp2Lb?.text = trimmedFileTemp2
                }
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    // 添加表格点击事件
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 显示操作选项
        let alertController = UIAlertController(title: "Export Options", message: "Choose export format", preferredStyle: .actionSheet)
        
        // CSV导出选项
        let csvAction = UIAlertAction(title: "Export as CSV", style: .default) { _ in
            self.shareCSVFile()
        }
        
        // 取消选项
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(csvAction)
        alertController.addAction(cancelAction)
        
        // 适配iPad
        if let popoverController = alertController.popoverPresentationController {
            if let cell = tableView.cellForRow(at: indexPath) {
                popoverController.sourceView = cell
                popoverController.sourceRect = cell.bounds
            }
        }
        
        present(alertController, animated: true, completion: nil)
    }
}
