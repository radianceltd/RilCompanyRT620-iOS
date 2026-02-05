//
//  DFUView.swift
//  RilCompanyRT617-iOS
//
//  Created by RND on 2023/7/27.
//

import UIKit


protocol DFUViewProtocol:NSObjectProtocol {
    func onUpdate()
    func onSelect()
    func onCancel()
}

class DFUView: BaseView {

    weak var delegate:DFUViewProtocol?
    
    var updateBtn: UIButton?
    
    var selectBtn: UIButton?
    
    var cancelBtn: UIButton?
    
   var downView: DownLoadView?
    
    override func initView(){
        
        //开始按钮
        updateBtn = UIButton()
        updateBtn?.backgroundColor = UIColor(hexString: "#555555", transparency: 1.0)
        updateBtn?.layer.cornerRadius = 15
        updateBtn?.setTitle("Start Ota", for: .normal)
        self.addSubview(updateBtn!)
        
        updateBtn?.snp.makeConstraints{(make)->Void in
            make.left.equalTo(self).offset(30)
            make.right.equalTo(self).offset(-30)
            make.top.equalTo(self).offset(125)
            make.height.equalTo(55)
        }
        
        //下载View
        downView = DownLoadView()
        downView?.backgroundColor = UIColor.gray
        downView?.musicalColor = UIColor(hexString: "#555555", transparency: 1.0)
        downView?.placeholderBtnFont = UIFont(name: "Helvetica-Bold", size: 14)
        downView?.placeholderFont = UIFont(name: "Helvetica", size: 14)
        downView?.musicDownLoadLab.text = "Please select your upgrade file"
        self.addSubview(downView!)

        downView!.snp.makeConstraints{(make)->Void in
            make.left.equalTo(self).offset(20)
            make.right.equalTo(self).offset(-20)
            make.top.equalTo(self).offset(250)
            make.height.equalTo(55)
        }
        
        selectBtn = UIButton()
        selectBtn?.backgroundColor = UIColor(hexString: "#555555", transparency: 1.0)
        selectBtn?.layer.cornerRadius = 0
        selectBtn?.setTitle("Select File", for: .normal)
        self.addSubview(selectBtn!)
        
        selectBtn?.snp.makeConstraints{(make)->Void in
            make.left.equalTo(self).offset(0)
            make.right.equalTo(self).offset(0)
            make.bottom.equalTo(self).offset(0)
            make.height.equalTo(55);
        }
        
        cancelBtn = UIButton()
        cancelBtn?.backgroundColor = UIColor(hexString: "#353535", transparency: 1.0)
        cancelBtn?.layer.cornerRadius = 0
        cancelBtn?.setTitle("Cancel Upgrade", for: .normal)
        self.addSubview(cancelBtn!)
        
        cancelBtn?.snp.makeConstraints{(make)->Void in
            make.left.equalTo(self).offset(0)
            make.right.equalTo(self).offset(0)
            make.bottom.equalTo(self).offset(0)
            make.height.equalTo(55);
        }
        
        
        //按钮事件
        updateBtn!.addTarget(self, action: #selector(onUpdate), for: .touchUpInside)
        selectBtn!.addTarget(self, action: #selector(onSelect), for: .touchUpInside)
        cancelBtn!.addTarget(self, action: #selector(onCancel), for: .touchUpInside)
        
    }
    
    
    @objc func onUpdate(){
        if delegate != nil {
            delegate?.onUpdate()
        }
    }
    
    @objc func onSelect(){
        if delegate != nil {
            delegate?.onSelect()
        }
    }
    
    @objc func onCancel(){
        if delegate != nil {
            delegate?.onCancel()
        }
    }


}
