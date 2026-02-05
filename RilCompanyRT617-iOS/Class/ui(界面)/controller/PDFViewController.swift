import UIKit
import WHToast
import SwiftEventBus
import MBProgressHUD

class PDFViewController: NavigationController, UITableViewDelegate, UITableViewDataSource {
 
  var index: Int?
  var model = BleModel()
  var allExpanded = AllExpanded()
  var read = ReadModel()
  var dataList = LinkedHashMap<String, Read>()
  var pdfView = PdfView()
 
  // 启动菊花弹窗
  private var hud: MBProgressHUD?
  let CELLIDENTIFITER = "PDFLISTTABLEVIEWCELL"
 
  override func viewDidLoad() {
      super.viewDidLoad()
      aboutNavigationLeft(isBack: false)
      aboutNavigationCenter(title: "PDF")
      // 设置右侧菜单按钮
      aboutNavigationRight(isTure: true, isNameImage: "removerSet", isNameText: "")
  }
 
  // 视图将要显示
  override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      // 先发送蓝牙参数3，1，3，4
      sendBleProment(bleOne: 3, bleTwo: 4)
      sendGetPDFfile(inssub: 0x02)
      
  }
 
  // 重写右侧按钮点击事件
  override func onToClick() {
      showActionSheet()
  }
 
  // 显示下拉操作菜单
  func showActionSheet() {
      let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
     
      // 删除所有PDF文件选项
      let deleteAllPDFAction = UIAlertAction(title: "Delete All PDF", style: .destructive) { [weak self] _ in
          self?.showDeleteConfirmationAlert(title: "Delete All PDF Files",
                                          message: "Are you sure you want to delete all PDF files? This action cannot be undone.",
                                          deleteMode: 2) // DELMD=2: Delete all PDF files
      }
     
      // 删除所有文件选项
      let deleteAllFilesAction = UIAlertAction(title: "Delete All Files", style: .destructive) { [weak self] _ in
          self?.showDeleteConfirmationAlert(title: "Delete All Files",
                                          message: "Are you sure you want to delete all files? This action cannot be undone.",
                                          deleteMode: 4) // DELMD=4: Delete all files
      }
     
      // 取消选项
      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
     
      actionSheet.addAction(deleteAllPDFAction)
      actionSheet.addAction(deleteAllFilesAction)
      actionSheet.addAction(cancelAction)
     
      // 在iPad上需要使用popoverPresentationController
      if let popoverController = actionSheet.popoverPresentationController {
          popoverController.barButtonItem = navigationItem.rightBarButtonItem
          popoverController.permittedArrowDirections = .any
      }
     
      present(actionSheet, animated: true, completion: nil)
  }
 
  // MARK: - 发送蓝牙参数
  func sendBleProment(bleOne: UInt8, bleTwo: UInt8) {
      let ins: UInt8 = 0x07
      let len: UInt8 = 4
     
      // 创建 data 数组，存储 aValue 和 bValue
      let data: [UInt8] = [3, 1, bleOne, bleTwo]
     
      let packet = self.allExpanded.buildInstructionPacket(ins: ins, len: len, data: data)
      let hexString = self.allExpanded.hexadecimalString(from: packet)
      print(hexString)
      self.hidHud()
      BleManager.shared.writeValue(packet, self.model.mSendotacharater, self.model.mPeripheral)
     
  }
 
  // MARK: - 读取PDF文件名列表
  func sendGetPDFfile(inssub: UInt8) {
      let ins: UInt8 = 0x03
      let len: UInt8 = 0x01
      let inssub: UInt8 = inssub
     
      let packet = self.allExpanded.queryDeviceData(ins: ins, len: len, inssub: inssub)
     
      let hexString = self.allExpanded.hexadecimalString(from: packet)
      print("文件名：", hexString)
      self.hidHud()
      BleManager.shared.writeValue(packet, self.model.mSendotacharater, self.model.mPeripheral)
   
  }
 
  // MARK: - 删除文件协议
  func sendDeleteFile(delMode: UInt8, fileName: String? = nil) {
      let ins: UInt8 = 0x03
      var data: [UInt8] = []
     
      // 添加删除模式
      data.append(delMode)
     
      // 如果是删除单个文件，添加文件名
//      if delMode == 0 && fileName != nil {
//          // 将文件名转换为ASCII码
//          if let fileNameData = fileName?.data(using: .ascii) {
//              data.append(contentsOf: fileNameData.map { UInt8($0) })
//          }
//      }
     
      let len: UInt8 = UInt8(data.count)
      let inssub: UInt8 = 0x09
     
      // 直接调用 queryDeviceData 方法，因为它总是返回 Data
      let packet = self.allExpanded.queryDeviceData(ins: ins, len: len, inssub: inssub, data: data)
     
      let hexString = self.allExpanded.hexadecimalString(from: packet)
      print("Delete file instruction：", hexString)
     
      BleManager.shared.writeValue(packet, self.model.mSendotacharater, self.model.mPeripheral)
  }
 
    // MARK: - initData
  override func initData() {
      showHud()
      // 获取model数据
      SwiftEventBus.onMainThread(self, name: FILEPARAMES) { result in
          self.read = result?.object as! ReadModel
         
          if self.read.list.count > 0 {
              self.dataList.clear()
              for m in self.read.list {
                  self.dataList.put(key: m.fileName!, value: m)
              }
          }
         
          // 返回发送蓝牙参数3，1，40，80
          self.sendBleProment(bleOne: 40, bleTwo: 80)
          self.hidHud()
          // 刷新数据
          self.pdfView.tableView?.reloadData()
      }
     
      // 监听删除成功事件
      SwiftEventBus.onMainThread(self, name: "DELETE_SUCCESS") { [weak self] _ in
          guard let self = self else { return }
          // 重新获取文件列表
          self.sendGetPDFfile(inssub: 0x02)
          self.showHud()
      }
  }
 
    // MARK: - initView
  override func initView() {
      let view = UIView()
      pdfView.tableView?.delegate = self
      pdfView.tableView?.dataSource = self
      pdfView.tableView?.tableFooterView = view
      pdfView.frame = self.view.bounds
      self.view.addSubview(pdfView)
     
      // 注册单元格
      pdfView.tableView?.register(PDFCell.self, forCellReuseIdentifier: CELLIDENTIFITER)
  }
 
  // 显示加载提示
  func showHud() {
      hud = MBProgressHUD.showAdded(to: view, animated: true)
      hud?.bezelView.style = .solidColor
      hud?.bezelView.color = UIColor.black.withAlphaComponent(0.7)
      hud?.label.text = NSLocalizedString("File Reading...", comment: "HUD loading title")
      hud?.contentColor = UIColor.white
  }
 
  // 隐藏加载提示
  func hidHud() {
      hud?.hide(animated: true, afterDelay: 0.5)
  }
 
  // MARK: - 删除确认弹窗
 
  func showDeleteConfirmationAlert(title: String, message: String, deleteMode: UInt8, fileName: String? = nil) {
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
     
      // Cancel button
      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
      alert.addAction(cancelAction)
     
      // Confirm delete button
      let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
          guard let self = self else { return }
         
          // Show deleting progress
          let deletingHud = MBProgressHUD.showAdded(to: self.view, animated: true)
          deletingHud.label.text = "Deleting..."
          deletingHud.mode = .indeterminate
         
          // Send delete command
          self.sendDeleteFile(delMode: deleteMode, fileName: fileName)
         
          // If deleting single file, remove from data source
          if deleteMode == 0, let fileName = fileName {
              self.removeFileFromDataList(fileName: fileName)
          }
         
          // If deleting all, clear data source
          if deleteMode == 2 || deleteMode == 4 {
              self.dataList.clear()
              self.pdfView.tableView?.reloadData()
          }
         
          // Hide progress after 2 seconds
          DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
              deletingHud.hide(animated: true)
              WHToast.showMessage("Deleted successfully!", originY: 500, duration: 2, finishHandler: nil)
          }
      }
      alert.addAction(deleteAction)
     
      present(alert, animated: true, completion: nil)
  }
 
  // MARK: - 从数据源中移除文件
 
  private func removeFileFromDataList(fileName: String) {
      // 方法1：尝试使用可能的方法名
      if let _ = dataList.remove(key: fileName) {
          // 如果 remove 方法存在
      } else {
          // 方法2：创建新的 LinkedHashMap 排除要删除的文件
          let newDataList = LinkedHashMap<String, Read>()
          //            for i in 0..<dataList.size() {
          //                let currentKey = dataList.getKey(index: i)
          //                if currentKey != fileName {
          //                    if let value = dataList.get(index: i) {
          //                        newDataList.put(key: currentKey, value: value)
          //                    }
          //                }
          //            }
          dataList = newDataList
      }
     
      // 刷新表格
      self.pdfView.tableView?.reloadData()
  }
 
  // MARK: - UITableView Delegate & DataSource
 
  func numberOfSections(in tableView: UITableView) -> Int {
      return 1
  }
 
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return dataList.size()
  }
 
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      var cell: PDFCell? = tableView.dequeueReusableCell(withIdentifier: CELLIDENTIFITER) as? PDFCell
     
      if cell == nil {
          cell = PDFCell(style: .default, reuseIdentifier: CELLIDENTIFITER)
          cell!.selectionStyle = .none
      }
     
      if dataList.size() > 0 {
          let model = dataList.get(index: indexPath.row)
         
          // 使用新的配置方法
          cell!.configure(with: model.fileName, fileSize: Int(model.fileSize))
      }
     
      return cell!
  }
 
  // 启用左滑动删除功能
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
      return true
  }
 
  // 设置左滑动操作按钮
  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
      let delete = UITableViewRowAction(style: .destructive, title: "Delete") { [weak self] action, indexPath in
          guard let self = self else { return }
         
          let model = self.dataList.get(index: indexPath.row)
          if let fileName = model.fileName {
              // 显示确认弹窗
              self.showDeleteConfirmationAlert(title: "Delete File",
                                             message: "Are you sure you want to delete file \(fileName)?",
                                             deleteMode: 0,
                                             fileName: fileName)
          }
      }
     
      // 设置删除按钮背景色
      delete.backgroundColor = .red
     
      return [delete]
  }
 
  // 兼容 iOS 11+ 的滑动删除方式
  @available(iOS 11.0, *)
  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
      let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, view, completionHandler in
          guard let self = self else { return }
         
          let model = self.dataList.get(index: indexPath.row)
          if let fileName = model.fileName {
              // 显示确认弹窗
              self.showDeleteConfirmationAlert(title: "Delete File",
                                             message: "Are you sure you want to delete file \(fileName)?",
                                             deleteMode: 0,
                                             fileName: fileName)
          }
          completionHandler(true)
      }
     
      // 设置删除按钮图标
      if #available(iOS 13.0, *) {
          deleteAction.image = UIImage(systemName: "trash")
      }
      deleteAction.backgroundColor = .red
     
      let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
      configuration.performsFirstActionWithFullSwipe = false // 完全滑动时不自动执行
     
      return configuration
  }
 
  // 点击列表的事件方法
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      tableView.deselectRow(at: indexPath, animated: true)
     
      if dataList.size() > 0 {
          let readmodel = dataList.get(index: indexPath.row)
         
          let pdfdata = PDFTextDataController()
          pdfdata.bleModel = model
          pdfdata.read = readmodel
          pdfdata.readPdfName = readmodel.fileName
          self.navigationController?.pushViewController(pdfdata, animated: true)
      }
  }
 
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return 90.0
  }
 
  // 界面消失的时候
  override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      // 清理事件总线监听
      SwiftEventBus.unregister(self)
  }
}
