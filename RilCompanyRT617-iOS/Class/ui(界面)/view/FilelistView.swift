//
//  FilelistView.swift
//  RilCompanyRT617-iOS
//
//  Created by RND on 2023/6/30.
//

import UIKit

protocol FilelistViewProtocol:NSObjectProtocol {
    func onUpdateClick()
}


class FilelistView: BaseView {
    
    weak var delegate:FilelistViewProtocol?

    var tableView:UITableView?
    
    var updateButton:UIButton?
    
    override func initView(){
        
        tableView = UITableView()
        tableView!.separatorStyle = .none
        self.addSubview(tableView!)
        
        tableView!.snp.makeConstraints{(make)->Void in
            make.top.equalTo(self).offset(0)
            make.left.equalTo(self).offset(0)
            make.right.equalTo(self).offset(0)
            make.bottom.equalTo(self).offset(-55)
        }
        
        updateButton = UIButton()
        updateButton?.setTitle("CONFIRM", for: .normal)
        updateButton?.backgroundColor = UIColor(hexString: "#777777", transparency: 1.0)
        self.addSubview(updateButton!)
        
        updateButton?.snp.makeConstraints{(make)->Void in
            make.bottom.equalTo(self).offset(0)
            make.left.equalTo(self).offset(0)
            make.right.equalTo(self).offset(0)
            make.height.equalTo(55)
        }
        
        updateButton!.addTarget(self, action: #selector(onUpdateClick), for: .touchUpInside)
        
    }
    
    
    @objc func onUpdateClick(){
        if delegate != nil {
            delegate!.onUpdateClick()
        }
    }

}
