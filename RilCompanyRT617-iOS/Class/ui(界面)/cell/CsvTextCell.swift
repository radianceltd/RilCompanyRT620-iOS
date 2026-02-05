//
//  CsvTextCell.swift
//  RilCompanyRT617-iOS
//
//  Created by RND on 2023/9/28.
//

import UIKit

class CsvTextCell: BaseCell {
    
    var mMainVw:UIView?
    
    
    var mFileDataLb:UILabel?
    var mFileTimeLb:UILabel?
    var mFileTemp1Lb:UILabel?
    var mFileTemp2Lb:UILabel?
    
    
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
            make.left.equalTo(self).offset(5)
            make.right.equalTo(self).offset(-5)
            make.bottom.equalTo(self).offset(0)
        }
        
        //DATA
        mFileDataLb = UILabel()
        mFileDataLb?.textColor = UIColor.gray
        mFileDataLb?.textAlignment = .center
        mFileDataLb?.font = UIFont(name: "Helvetica", size: 14)
        mMainVw?.addSubview(mFileDataLb!)
        
        mFileDataLb!.snp.makeConstraints { (make) in
            make.centerY.equalTo(mMainVw!)
            make.left.equalTo(mMainVw!).offset(5)
            make.width.equalTo(80)
            make.height.equalTo(30)
        }
        
        //VIEW线条
        let verticalLineView = UIView()
        verticalLineView.backgroundColor = UIColor(hexString: "#c0c0c0", transparency: 1.0)
        mMainVw?.addSubview(verticalLineView)
        
        verticalLineView.snp.makeConstraints { (make) in
            make.centerY.equalTo(mMainVw!)
            make.left.equalTo(mFileDataLb!).offset(82)
            make.width.equalTo(1)
            make.height.equalTo(90)
        }
        
        //TIME
        mFileTimeLb = UILabel()
        mFileTimeLb?.textColor = UIColor.gray
        mFileTimeLb?.textAlignment = .center
        mFileTimeLb?.font = UIFont(name: "Helvetica", size: 14)
        mMainVw?.addSubview(mFileTimeLb!)
        
        mFileTimeLb!.snp.makeConstraints{(make)->Void in
            make.centerY.equalTo(mMainVw!)
            make.left.equalTo(verticalLineView).offset(2)
            make.width.equalTo(80)
            make.height.equalTo(30)
        }
        
        //VIEW线条
        let verticalLineView2 = UIView()
        verticalLineView2.backgroundColor = UIColor(hexString: "#c0c0c0", transparency: 1.0)
        mMainVw?.addSubview(verticalLineView2)

        verticalLineView2.snp.makeConstraints { (make) in
            make.centerY.equalTo(mMainVw!)
            make.left.equalTo(mFileTimeLb!).offset(82)
            make.width.equalTo(1)
            make.height.equalTo(90)
        }
        
        //TEMP1
        mFileTemp1Lb = UILabel()
        mFileTemp1Lb?.textColor = UIColor.gray
        mFileTemp1Lb?.textAlignment = .center
        mFileTemp1Lb?.font = UIFont(name: "Helvetica", size: 14)
        mMainVw?.addSubview(mFileTemp1Lb!)
        
        mFileTemp1Lb!.snp.makeConstraints{(make)->Void in
            make.centerY.equalTo(mMainVw!)
            make.left.equalTo(verticalLineView2).offset(2)
            make.width.equalTo(70)
            make.height.equalTo(30)
        }
        
        //VIEW线条
        let verticalLineView3 = UIView()
        verticalLineView3.backgroundColor = UIColor(hexString: "#c0c0c0", transparency: 1.0)
        mMainVw?.addSubview(verticalLineView3)
        
        verticalLineView3.snp.makeConstraints { (make) in
            make.centerY.equalTo(mMainVw!)
            make.right.equalTo(mFileTemp1Lb!).offset(2)
            make.width.equalTo(1)
            make.height.equalTo(90)
        }
        
        //TEMP2
        mFileTemp2Lb = UILabel()
        mFileTemp2Lb?.textColor = UIColor.gray
        mFileTemp2Lb?.textAlignment = .center
        mFileTemp2Lb?.font = UIFont(name: "Helvetica", size: 14)
        mMainVw?.addSubview(mFileTemp2Lb!)
        
        mFileTemp2Lb!.snp.makeConstraints{(make)->Void in
            make.centerY.equalTo(mMainVw!)
            make.left.equalTo(mFileTemp1Lb!).offset(65)
            make.height.equalTo(30)
            make.width.equalTo(70)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
