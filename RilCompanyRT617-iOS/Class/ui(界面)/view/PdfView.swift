// PdfView.swift
import UIKit

class PdfView: BaseView {
 
  var tableView: UITableView?
  // 移除 deleteAllButton 和 selectAllButton
 
  override func initView() {
      // 创建表格视图
      tableView = UITableView()
      tableView!.separatorStyle = .none
      tableView!.allowsSelection = true
      self.addSubview(tableView!)
     
      // 设置约束 - 移除底部容器，让tableView占据整个视图
      tableView!.snp.makeConstraints { make in
          make.top.equalTo(self).offset(0)
          make.left.equalTo(self).offset(0)
          make.right.equalTo(self).offset(0)
          make.bottom.equalTo(self).offset(0)
      }
  }
}
