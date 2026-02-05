//
//  PdfTextView.swift
//  RilCompanyRT617-iOS
//
//  Created by RND on 2023/10/25.
//

import UIKit

protocol PdfTextViewProtocol:NSObjectProtocol {
  
}

class PdfTextView: BaseView {
    
    //判断导航栏的离底部距离
    let TOP_HEIGHT = UIDevice.current.iPhoneXMore ? 108 : 80

    var pdfImage:UIImageView?
    
    override func initView(){
        
        let topView = UIView()
        addSubview(topView)
        
        topView.snp.makeConstraints { (make) ->Void in
            make.top.equalTo(self).offset(TOP_HEIGHT)
            make.left.equalTo(self).offset(5)
            make.right.equalTo(self).offset(-5)
            
        }
        pdfImage = UIImageView()

        topView.addSubview(pdfImage!)
        
        pdfImage!.snp.makeConstraints{(make)->Void in
            make.centerY.equalTo(topView)
            make.left.equalTo(topView).offset(10)
            make.width.equalTo(200)
            make.height.equalTo(200)
        }
    }
}
