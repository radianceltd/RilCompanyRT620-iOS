//
//  BleDeviceCell.swift
//  TMW041RT
//
//  Created by RND on 2023/3/27.
//

import UIKit


class BleDeviceCell: BaseCell {
    
    var mMainVw: UIView?
    
    var mTempLb:UILabel?
    
    var mTempUnitLb:UILabel?
    
    //名称
    var mNameLb: UILabel?
    
    //信号Wi-Fi
    var mSignalIm: UIImageView?
    
    //信号值
    var mSignalLb: UILabel?
    
    //是否离线
    var mOnlineLb: UILabel?
    
    //地址
    var mAddressLb: UILabel?
    
    var mBattery:UILabel?
    
    var mBatteryLb:UILabel?
    
    var mBatteryImage:UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        mMainVw = UIView()
        mMainVw!.backgroundColor = UIColor(hexString: "#EAEAEA", transparency: 1.0)
        mMainVw!.layer.cornerRadius = 5.0
        mMainVw!.clipsToBounds = true
        mMainVw!.layer.shadowColor = UIColor.black.cgColor
        mMainVw!.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        mMainVw!.layer.shadowOpacity = 0.5
        mMainVw!.layer.shadowRadius = 5
        self.addSubview(mMainVw!)
        
        mMainVw!.snp.makeConstraints{(make)->Void in
            make.top.equalTo(self).offset(5)
            make.left.equalTo(self).offset(10)
            make.right.equalTo(self).offset(-10)
            make.bottom.equalTo(self).offset(0)
        }
        
        mBattery = UILabel()
        mBattery?.textColor = UIColor.black
        mBattery?.text = "Battery:"
        mBattery?.font = UIFont(name: "Helvetica-Bold", size: 13)
        mBattery?.textAlignment = .left
        mMainVw!.addSubview(mBattery!)
        
        mBattery!.snp.makeConstraints{(make)->Void in
            make.top.equalTo(mMainVw!).offset(6)
            make.left.equalTo(mMainVw!).offset(10)
            make.height.equalTo(30)
        }
        
        mBatteryLb = UILabel()
        mBatteryLb?.textColor = UIColor.black
        mBatteryLb?.text = ""
        mBatteryLb?.isHidden = true
        mBatteryLb?.font = UIFont(name: "Helvetica-Bold", size: 13)
        mBatteryLb?.textAlignment = .left
        mMainVw!.addSubview(mBatteryLb!)
        
        mBatteryLb!.snp.makeConstraints{(make)->Void in
            make.top.equalTo(mMainVw!).offset(6)
            make.left.equalTo(mBattery!).offset(50)
            make.height.equalTo(30)
        }
        
        //电池电量外部电源图片
        mBatteryImage = UIImageView(image: UIImage(named: "battery"))
        mBatteryImage?.isHidden = true
        self.addSubview(mBatteryImage!)
        
        mBatteryImage!.snp.makeConstraints{(make)->Void in
            make.top.equalTo(mMainVw!).offset(6)
            make.left.equalTo(mBattery!).offset(50)
            make.height.equalTo(30)
            make.width.equalTo(30)
        }
        
        //添加图片第一步
        mSignalIm = UIImageView(image: UIImage(named: "signal1"))
        self.addSubview(mSignalIm!)
        
        mSignalIm!.snp.makeConstraints{(make)->Void in
            make.centerY.equalTo(mMainVw!)
            make.left.equalTo(mMainVw!).offset(10)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
        
        // 信号值显示
        mSignalLb = UILabel()
        mSignalLb?.textColor = UIColor.black
        mSignalLb?.font = UIFont(name: "Helvetica-Bold", size: 30)
        mSignalLb?.textAlignment = .left
        mMainVw!.addSubview(mSignalLb!)
        
        mSignalLb!.snp.makeConstraints{(make)->Void in
            make.top.equalTo(mSignalIm!).offset(-15)
            make.left.equalTo(mSignalIm!).offset(40)
            make.width.equalTo(80)
            make.height.equalTo(30)
        }
        
        //在线显示
        mOnlineLb = UILabel()
        mOnlineLb?.textColor = UIColor.black
        mOnlineLb?.font = UIFont(name: "Helvetica-Bold", size: 18)
        mOnlineLb?.textAlignment = .left
        mMainVw!.addSubview(mOnlineLb!)
        
        mOnlineLb!.snp.makeConstraints{(make)->Void in
            make.top.equalTo(mSignalLb!).offset(30)
            make.left.equalTo(mSignalIm!).offset(40)
            make.width.equalTo(120)
            make.height.equalTo(30)
        }
        
        
        
        
        //        let txtBrand = UILabel()
        //        txtBrand.textColor = UIColor.red
        //        txtBrand.font = UIFont(name: "Helvetica", size: 30)
        //        txtBrand.text = "DT"
        //        txtBrand.textAlignment = .center
        //        addSubview(txtBrand)
        //
        //        txtBrand.snp.makeConstraints{(make)->Void in
        //            make.centerY.equalTo(mMainVw!)
        //            make.left.equalTo(mMainVw!).offset(10)
        //            make.width.equalTo(50)
        //            make.height.equalTo(30)
        //        }
        
        //名称显示
        mNameLb = UILabel()
        mNameLb?.textColor = UIColor.black
        mNameLb?.font = UIFont(name: "Helvetica-Bold", size: 18)
        mNameLb?.textAlignment = .left
        mMainVw!.addSubview(mNameLb!)
        
        mNameLb!.snp.makeConstraints{(make)->Void in
            make.top.equalTo(mMainVw!).offset(12)
            make.left.equalTo(mSignalIm!).offset(121)
            make.height.equalTo(30)
        }
        
        //地址显示
        mAddressLb = UILabel()
        mAddressLb?.textColor = UIColor.black
        mAddressLb?.font = UIFont(name: "Helvetica", size: 18)
        mAddressLb?.text = "S/N:000000000"
        mAddressLb?.textAlignment = .left
        
        mMainVw?.addSubview(mAddressLb!)
        
        mAddressLb!.snp.makeConstraints{(make)->Void in
            make.top.equalTo(mNameLb!).offset(100)
            make.left.equalTo(mSignalIm!).offset(20)
        }
        
        mTempLb = UILabel()
        mTempLb?.textColor = UIColor.black
        mTempLb?.font = UIFont(name: "Helvetica-Bold", size:39)
        mTempLb?.text = "66"
        mTempLb?.textAlignment = .left
        
        mMainVw?.addSubview(mTempLb!)
        
        mTempLb!.snp.makeConstraints{(make)->Void in
            make.top.equalTo(mNameLb!).offset(39)
            make.right.equalTo(mMainVw!).offset(-50)
        }
        
        mTempUnitLb = UILabel()
        mTempUnitLb?.textColor = UIColor.black
        mTempUnitLb?.font = UIFont(name: "Helvetica-Bold", size:27)
        mTempUnitLb?.text = "°C"
        mTempUnitLb?.textAlignment = .left
        
        mMainVw?.addSubview(mTempUnitLb!)
        
        mTempUnitLb!.snp.makeConstraints{(make)->Void in
            make.top.equalTo(mNameLb!).offset(66)
            make.right.equalTo(mMainVw!).offset(-10)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
        
    }
    
}
