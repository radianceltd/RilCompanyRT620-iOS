//
//  AboutView.swift
//  TMW041RT
//
//  Created by RND on 2023/6/25.
//

import UIKit

class AboutView:BaseView{
    
    //判断导航栏的离底部距离
    let TOP_HEIGHT = UIDevice.current.iPhoneXMore ? 120 : 88
    
    var mTopImage:UIImageView?
    
    var mTopLb:UILabel?
    
    var mCompanyLb:UILabel?
    
    var mEmailLb:UILabel?
    
    var mPhoneLb:UILabel?
    
    var mFaxLb:UILabel?
    
    var mAddressLb:UILabel?
    
    var mVersionLb:UILabel?
    
    override func initView() {
        
        let mainView = UIView()
        self.addSubview(mainView)
        
        mainView.snp.makeConstraints{(make)->Void in
            make.top.equalTo(self).offset(0)
            make.left.equalTo(self).offset(5)
            make.right.equalTo(self).offset(-5)
            make.bottom.equalTo(self).offset(0)
        }
        
        //顶部View
        let topView = UIView()
        topView.backgroundColor = UIColor.white
        mainView.addSubview(topView)
        
        topView.snp.makeConstraints{(make)->Void in
            make.top.equalTo(mainView).offset(TOP_HEIGHT)
            make.left.equalTo(self).offset(0)
            make.right.equalTo(self).offset(0)
            make.height.equalTo(130)
        }
        
        //顶部View里面的内容
        mTopImage = UIImageView()
        topView.addSubview(mTopImage!)
        
        mTopImage!.snp.makeConstraints{(make)->Void in
            make.centerX.equalTo(topView)
            make.top.equalTo(topView).offset(0)
            make.width.equalTo(80)
            make.height.equalTo(80)
        }
        
        mTopLb = UILabel()
        mTopLb?.textColor = UIColor.gray
        mTopLb?.text = "RilBleWeight"
        topView.addSubview(mTopLb!)
        
        mTopLb!.snp.makeConstraints{(make)->Void in
            make.centerX.equalTo(topView)
            make.top.equalTo(topView).offset(TOP_HEIGHT)
            make.height.equalTo(20)
        }
        
        
        //底部控件
        let bottomView = UIView()
        bottomView.backgroundColor = UIColor.white
        mainView.addSubview(bottomView)
        
        bottomView.snp.makeConstraints{(make)->Void in
            make.left.equalTo(mainView).offset(0)
            make.right.equalTo(mainView).offset(0)
            make.bottom.equalTo(mainView).offset(-10)
            make.height.equalTo(220)
        }
        
        //公司名称
        mCompanyLb = UILabel()
        mCompanyLb?.textColor = UIColor.gray
        bottomView.addSubview(mCompanyLb!)
        
        mCompanyLb!.snp.makeConstraints{(make)->Void in
            make.left.equalTo(bottomView).offset(10)
            make.top.equalTo(bottomView).offset(0)
            make.right.equalTo(bottomView).offset(-10)
            make.height.equalTo(25)
        }
        
        //Email的显示
        mEmailLb = UILabel()
        mEmailLb?.textColor = UIColor.gray
        bottomView.addSubview(mEmailLb!)
        
        mEmailLb!.snp.makeConstraints{(make)->Void in
            make.left.equalTo(bottomView).offset(10)
            make.top.equalTo(mCompanyLb!).offset(25)
            make.right.equalTo(bottomView).offset(-10)
            make.height.equalTo(25)
        }
        
        //显示电话号码
        mPhoneLb = UILabel()
        mPhoneLb?.textColor = UIColor.gray
        bottomView.addSubview(mPhoneLb!)
        
        mPhoneLb!.snp.makeConstraints{(make)->Void in
            make.left.equalTo(bottomView).offset(10)
            make.top.equalTo(mEmailLb!).offset(25)
            make.right.equalTo(bottomView).offset(-10)
            make.height.equalTo(25)
        }
        
        // 显示传真
        mFaxLb = UILabel()
        mFaxLb?.textColor = UIColor.gray
        bottomView.addSubview(mFaxLb!)
        
        mFaxLb!.snp.makeConstraints{(make)->Void in
            make.left.equalTo(bottomView).offset(10)
            make.top.equalTo(mPhoneLb!).offset(25)
            make.right.equalTo(bottomView).offset(-10)
            make.height.equalTo(25)
        }
        
        // 显示地址
        mAddressLb = UILabel()
        mAddressLb?.textColor = UIColor.gray
        mAddressLb?.lineBreakMode = .byWordWrapping
        mAddressLb?.numberOfLines = 0
        bottomView.addSubview(mAddressLb!)
        
        mAddressLb!.snp.makeConstraints{(make)->Void in
            make.left.equalTo(bottomView).offset(10)
            make.top.equalTo(mFaxLb!).offset(20)
            make.right.equalTo(bottomView).offset(-10)
            make.height.equalTo(75)
        }
        
        //版本号
        mVersionLb = UILabel()
        mVersionLb?.textColor = UIColor.gray
        bottomView.addSubview(mVersionLb!)
        
        mVersionLb!.snp.makeConstraints{(make)->Void in
            make.left.equalTo(bottomView).offset(10)
            make.top.equalTo(mAddressLb!).offset(70)
            make.right.equalTo(bottomView).offset(-10)
            make.height.equalTo(25)
        }

    }

    
}
