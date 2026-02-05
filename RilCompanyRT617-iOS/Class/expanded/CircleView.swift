//
//  CircleView.swift
//  TMW041RT
//
//  Created by RND on 2023/6/26.
//

import UIKit
import SnapKit

class CircleView: BaseView {
    
    var mCircleView: UIView!
    var mCurrent: UILabel!
    
    public var mTmpLb: UILabel!
    public var mUnitLb: UILabel!
    public var mTmpOnlineLb: UILabel!
    
    override func initView() {
        let radius = UIScreen.main.bounds.size.width / 2.8
        
        let circleFrame = CGRect(x: UIScreen.main.bounds.size.width/2 - radius, y: UIScreen.main.bounds.size.height/3.9 - radius, width: radius*2, height: radius*2)
        
        self.mCircleView = UIView(frame: circleFrame)
        self.mCircleView.backgroundColor = UIColor.gray
        self.mCircleView.layer.cornerRadius = radius
        
        self.addSubview(self.mCircleView)
        
        self.mCurrent = UILabel()
        self.mCurrent.textColor = UIColor.white
        self.mCurrent.font = UIFont(name: "Helvetica-Bold", size: 22)
        self.mCurrent.text = "CURRENT"
        self.mCurrent.textAlignment = NSTextAlignment.center
        self.mCircleView.addSubview(self.mCurrent)
        self.mCurrent.snp.makeConstraints { make in
            make.centerX.equalTo(self.mCircleView)
            make.top.equalTo(self.mCircleView).offset(40)
            make.width.equalTo(150)
            make.height.equalTo(35)
        }
        
        self.mTmpLb = UILabel()
        self.mTmpLb.textColor = UIColor.white
        self.mTmpLb.font = UIFont(name: "Helvetica-Bold", size: 65)
        self.mTmpLb.text = "---"
        self.mTmpLb.textAlignment = NSTextAlignment.center
        self.mCircleView.addSubview(self.mTmpLb)
        self.mTmpLb.snp.makeConstraints { make in
            make.centerX.equalTo(self.mCircleView)
            make.centerY.equalTo(self.mCircleView)
            make.width.equalTo(165)
            make.height.equalTo(80)
        }
        
        self.mTmpOnlineLb = UILabel()
        self.mTmpOnlineLb.textColor = UIColor.white
        self.mTmpOnlineLb.font = UIFont(name: "Helvetica-Bold", size: 30)
        self.mTmpOnlineLb.text = "OFFLINE"
        self.mTmpOnlineLb.isHidden = true
        self.mTmpOnlineLb.textAlignment = NSTextAlignment.center
        self.mCircleView.addSubview(self.mTmpOnlineLb)
        self.mTmpOnlineLb.snp.makeConstraints { make in
            make.centerX.equalTo(self.mCircleView)
            make.centerY.equalTo(self.mCircleView)
            make.width.equalTo(165)
            make.height.equalTo(80)
        }
        
        self.mUnitLb = UILabel()
        self.mUnitLb.textColor = UIColor.white
        self.mUnitLb.font = UIFont(name: "Helvetica-Bold", size: 22)
        self.mUnitLb.text = "°C"
        self.mUnitLb.textAlignment = NSTextAlignment.center
        self.mCircleView.addSubview(self.mUnitLb)
        self.mUnitLb.snp.makeConstraints { make in
            make.centerX.equalTo(self.mCircleView)
            make.bottom.equalTo(self.mCircleView).offset(-35)
            make.width.equalTo(40)
            make.height.equalTo(20)
        }
    }
}
