//
//  FilelistViewCell.swift
//  RilCompanyRT617-iOS
//
//  Created by RND on 2023/6/30.
//

import UIKit


protocol FilelistViewCellProtocol:NSObjectProtocol {
    
    func onClick(sender:UIButton)
 
}


class FilelistViewCell: BaseCell {
    
    weak var delegate:FilelistViewCellProtocol?
    
    var mMainVw:UIView?
    
    var mCheckBtn:UIButton?
    
    var mFileNameLb:UILabel?
    
    var mFileSizeLb: UILabel?
    
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
            make.left.equalTo(self).offset(5)
            make.right.equalTo(self).offset(-5)
            make.bottom.equalTo(self).offset(0)
        }
        
        mCheckBtn = UIButton()
        mCheckBtn?.setImage(UIImage(named: "check"), for: .normal)
        mMainVw?.addSubview(mCheckBtn!)
        
        mCheckBtn!.snp.makeConstraints{(make)->Void in
            make.centerY.equalTo(mMainVw!)
            make.left.equalTo(mMainVw!).offset(10)
            make.width.equalTo(35)
            make.height.equalTo(35)
        }
        
        mFileNameLb = UILabel()
        mFileNameLb?.textColor = UIColor.gray
        mFileNameLb?.font = UIFont(name: "Helvetica", size: 14)
        mMainVw?.addSubview(mFileNameLb!)
        
        mFileNameLb!.snp.makeConstraints{(make)->Void in
            make.centerY.equalTo(mMainVw!)
            make.left.equalTo(mCheckBtn!).offset(40)
            make.right.equalTo(mMainVw!).offset(-10)
            make.height.equalTo(30)
        }
        
        mFileSizeLb = UILabel()
        mFileSizeLb?.textColor = UIColor.gray
        mFileSizeLb?.font = UIFont(name: "Helvetica", size: 14)
        mFileSizeLb?.textAlignment = .right
        
        mMainVw?.addSubview(mFileSizeLb!)
        
        mFileSizeLb!.snp.makeConstraints{(make)->Void in
            make.centerY.equalTo(mMainVw!)
            make.width.equalTo(100)
            make.right.equalTo(mMainVw!).offset(-10)
            make.height.equalTo(30)
        }
        
        
        
        mCheckBtn!.addTarget(self, action: #selector(onClick(sender:)), for: .touchUpInside)
        
    }
    
    @objc func onClick(sender:UIButton){
        if delegate != nil {
            delegate?.onClick(sender: sender)
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
