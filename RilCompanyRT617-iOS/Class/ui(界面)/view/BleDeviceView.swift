//
//  BleDeviceView.swift
//  TMW041RT
//
//  Created by RND on 2023/3/27.
//

import UIKit

class BleDeviceView : BaseView{
    
    var tableView : UITableView?
    
    override func initView() {
        
        tableView = UITableView()
        tableView!.separatorStyle = .none
        self.addSubview(tableView!)
        
        tableView!.snp.makeConstraints{(make)->Void in
            
            make.top.equalTo(self).offset(0)
            make.left.equalTo(self).offset(0)
            make.right.equalTo(self).offset(0)
            make.bottom.equalTo(self).offset(0)
            
        }
        
    }
    
}
