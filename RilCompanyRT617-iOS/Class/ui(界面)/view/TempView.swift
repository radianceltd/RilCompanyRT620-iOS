//
//  TempView.swift
//  TMW041RT
//
//  Created by RND on 2023/6/26.
//

import UIKit

class TempView:BaseView{
    
    //判断导航栏的离底部距离
    let TOP_HEIGHT = UIDevice.current.iPhoneXMore ? 60 : 20
    
    // Mac地址显示
    var mMacLb: UILabel!
    
    //电池电量
    var mBatLb: UILabel!
    
    //显示名称
    var mNameLb: UILabel!
    
    var mOffLineLb:UILabel!
    
    var mDeviceStateSw:UISwitch!
    
    //外部电源
    var mExternalPower: UIImageView?
    
    //圆形显示View
    public var mCircleVw: CircleView!
    
    //信号图片
    var signalImage:UIImageView?
    
    
    override func initView() {
        
        //名称显示
        mNameLb = UILabel()
        mNameLb.textColor = UIColor.gray
        mNameLb.font = UIFont(name: "Helvetica-bold", size: 29)
        mNameLb.textAlignment = .left
        self.addSubview(mNameLb)
        
        mNameLb.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(TOP_HEIGHT)
            make.left.equalTo(self).offset(10)
            make.right.equalTo(self).offset(-10)
            make.height.equalTo(70)
        }
        
        //地址显示
        mMacLb = UILabel()
        mMacLb.textColor = UIColor.gray
        mMacLb.font = UIFont(name: "Helvetica-Bold", size: 18)
        mMacLb.textAlignment = .left
        self.addSubview(mMacLb)
        
        mMacLb.snp.makeConstraints { (make) in
            make.top.equalTo(mNameLb).offset(60)
            make.left.equalTo(self).offset(20)
            make.height.equalTo(40)
        }
        
        //设备状态开关
        mDeviceStateSw = UISwitch()
        mDeviceStateSw.isHidden = true
        self.addSubview(mDeviceStateSw!)
        
        mDeviceStateSw!.snp.makeConstraints{
            (make)->Void in
            make.top.equalTo(mNameLb).offset(70)
            make.right.equalTo(self).offset(-30)
            make.height.equalTo(40)
        }
        
        mOffLineLb = UILabel()
        mOffLineLb.textColor = UIColor.red
        mOffLineLb.text = "OFF-Line"
        mOffLineLb.isHidden = true
        mOffLineLb.font = UIFont(name: "Helvetica-Bold", size: 18)
        mOffLineLb.textAlignment = .left
        self.addSubview(mOffLineLb)
        
        mOffLineLb.snp.makeConstraints { (make) in
            make.top.equalTo(mMacLb).offset(60)
            make.left.equalTo(self).offset(20)
            make.height.equalTo(40)
        }
        
        
        //显示圆形温度
        mCircleVw = CircleView()
        self.addSubview(mCircleVw)
        
        mCircleVw.snp.makeConstraints { (make) in
            make.top.equalTo(mMacLb).offset(60)
            make.left.equalTo(self).offset(10)
            make.right.equalTo(self).offset(-10)
            make.height.equalTo(120)
        }
        

        
        //电池电量显示
        mBatLb = UILabel()
        mBatLb.textColor = UIColor.gray
        mBatLb.font = UIFont(name: "Helvetica-bold", size: 28)
        mBatLb.textAlignment = .center
        mBatLb.isHidden = true
        self.addSubview(mBatLb)
        
        mBatLb.snp.makeConstraints { (make) in
            make.bottom.equalTo(self).offset(-60)
            make.left.equalTo(self).offset(40)
            make.right.equalTo(self).offset(-40)
            make.height.equalTo(60)
        }
        
        //添加信号图片
        signalImage = UIImageView(image: UIImage(named: "signal0"))
        signalImage!.isHidden = true
        self.addSubview(signalImage!)
        
        signalImage!.snp.makeConstraints{(make)->Void in
            make.bottom.equalTo(self.mBatLb).offset(-66)
            make.left.equalTo(self).offset(50)
          
            make.width.equalTo(39)
            make.height.equalTo(39)
        }
        
        mExternalPower = UIImageView(image: UIImage(named: "battery"))
        mExternalPower!.isHidden = true
        self.addSubview(mExternalPower!)
        
        mExternalPower!.snp.makeConstraints{(make)->Void in
            make.bottom.equalTo(self).offset(-50)
            make.left.equalTo(self).offset(screenWidth/2.2)
          
            make.width.equalTo(39)
            make.height.equalTo(39)
        }
        
    }
}
