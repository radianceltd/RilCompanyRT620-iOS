//
//  MeCell.swift
//  TMW041RT
//
//  Created by RND on 2023/3/22.
//

import UIKit

protocol MeCellProtocol:NSObjectProtocol{
    
    func onUnitAction(_ sender: UISwitch?)

}

class MeCell:BaseCell{
    
    weak var delegate:MeCellProtocol?
    
    var topView : UIView?
    var conView:UIView?
    var btmView:UIView?
    
    var mFirstNameLb:UILabel?
    var mNameLb:UILabel?
    var mEmailLb:UILabel?
    var mConLb:UILabel?
    
    var mConImage:UIImageView?
    var rightImage:UIImageView?
    var redImage:UIImageView?
    
    var conViewSwitch:UISwitch?
    var conTimeLb:UILabel?
    var conUnitText:UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // 布局
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        topView = UIView()
        self.addSubview(topView!)
        
        topView!.snp.makeConstraints{
            (make)->Void in
            make.top.equalTo(self).offset(0)
            make.left.equalTo(self).offset(5)
            make.right.equalTo(self).offset(-5)
            make.height.equalTo(150)
        }
      
       let imageView = UIImageView()
       imageView.image = UIImage(named: "temp")
       topView!.addSubview(imageView)
        
       imageView.snp.makeConstraints{
            (make)->Void in
           make.centerX.equalTo(self);
           make.centerY.equalTo(80);
           make.width.equalTo(90);
           make.height.equalTo(90);
        }
        
        //第二段布局
        conView = UIView()
        self.addSubview(conView!)
        
        conView!.snp.makeConstraints{
            (make)->Void in
            make.top.equalTo(self).offset(0)
            make.left.equalTo(self).offset(0)
            make.right.equalTo(self).offset(0)
            make.height.equalTo(60)
        }
        
        mConImage = UIImageView()
        conView?.addSubview(mConImage!)
        
        mConImage!.snp.makeConstraints{
            (make)->Void in
            make.left.equalTo(conView!).offset(15)
            make.centerY.equalTo(conView!)
            make.width.equalTo(25)
            make.height.equalTo(25)
        }
        
        mConLb = UILabel()
        mConLb?.font = UIFont(name: "Helvetica", size: 18)
        conView?.addSubview(mConLb!)
        
        mConLb!.snp.makeConstraints{
            (make)->Void in
            make.centerY.equalTo(conView!)
            make.left.equalTo(conView!).offset(60)
            make.right.equalTo(conView!).offset(-20)
            make.height.equalTo(25)
        }
        
        //列表里的按钮
        conViewSwitch = UISwitch()
        conView!.addSubview(conViewSwitch!)
        
        conViewSwitch!.snp.makeConstraints{
            (make)->Void in
            make.centerY.equalTo(conView!)
            make.top.equalTo(conView!).offset(20)
            make.right.equalTo(conView!).offset(-65)
            make.width.equalTo(50)
            make.height.equalTo(30)
        }
        
        conViewSwitch!.isHidden = true
        
        //列表里后面的文本
        conTimeLb = UILabel()
        conView!.addSubview(conTimeLb!)
        
        conTimeLb!.snp.makeConstraints{
            (make)->Void in
            make.centerY.equalTo(conView!)
            make.top.equalTo(conView!).offset(20)
            make.right.equalTo(conView!).offset(-35)
            make.height.equalTo(30)
        }
        
        conTimeLb?.isHidden = true
        
        
        //列表
        conUnitText = UILabel()
        conView!.addSubview(conUnitText!)
        
        conUnitText!.snp.makeConstraints { (make) ->Void in
           make.centerY.equalTo(conView!)
           make.top.equalTo(conView!).offset(20)
           make.right.equalTo(conView!).offset(-35)
           make.height.equalTo(30)
        }
        
        //右边小图片
        rightImage = UIImageView()
        rightImage!.image = UIImage(named: "right")
        conView!.addSubview(rightImage!)
        
        rightImage!.snp.makeConstraints{
            (make)->Void in
            make.centerY.equalTo(conView!)
            make.right.equalTo(conView!).offset(-10)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        
        //右边红点
        redImage = UIImageView()
        redImage!.image = UIImage(named: "red")
        conView!.addSubview(redImage!)
        
        redImage!.snp.makeConstraints{
            (make)->Void in
            make.centerY.equalTo(conView!)
            make.right.equalTo(conView!).offset(-10)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        
       // conViewSwitch!.addTarget(self, action: #selector(conViewSc), for: .valueChanged)
        conViewSwitch!.addTarget(self, action: #selector(onUnitAction(_:)), for: .valueChanged)

    }
    
    @objc func onUnitAction(_ sender: UISwitch?) {
     if (delegate != nil) {
         delegate!.onUnitAction(sender)
         }
     }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
