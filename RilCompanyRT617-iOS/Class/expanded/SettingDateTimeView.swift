//
//  SettingDateTime.swift
//  RilCompanyRT617-iOS
//
//  Created by RND on 2023/7/28.
//

import UIKit
import SnapKit

typealias sureSetDateTimeClick = (_ select:Bool) -> Void

class SettingDateTimeView: UIView,UITextFieldDelegate {
    
    var commonView:UIView?
    
    var commonTf_y:UITextField?
    var commonTf_m:UITextField?
    var commonTf_d:UITextField?
    var commonTf_h:UITextField?
    var commonTf_s:UITextField?
    
    var sureBtn:UIButton?
    var cancelBtn:UIButton?
    var commonViewCloseBlock: (() -> Void)?
    var sureBolck:sureSetDateTimeClick?
    
    //静态常量
    let ALERTVIEW_HEIGHT = UIScreen.main.bounds.size.height / 1.2
    let ALERTVIEW_WIDTH = UIScreen.main.bounds.size.width - 50
    let HEIGHT = UIScreen.main.bounds.size.height
    let WIDTH = UIScreen.main.bounds.size.width
    
    init(title: String?, p_name name: String?, p_tf tf: String?) {
        let frame = CGRect(x: 0, y: 0,
        width: UIScreen.main.bounds.size.width,
        height: UIScreen.main.bounds.size.height)
        super.init(frame:frame)
        initView(title: title, p_name: name, p_tf: tf)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initView(title: String?, p_name name: String?, p_tf tf: String?) {
        frame = UIScreen.main.bounds
        commonView = UIView(frame: CGRect(x: 25, y: HEIGHT / 2 - ALERTVIEW_HEIGHT / 2, width: ALERTVIEW_WIDTH, height: ALERTVIEW_HEIGHT))
        commonView!.backgroundColor = UIColor.white
        commonView!.layer.cornerRadius = 8.0
        commonView!.layer.masksToBounds = true
        commonView!.isUserInteractionEnabled = true
        addSubview(commonView!)

        let backImage = UIImageView(frame: CGRect(x: 0, y: 0, width: ALERTVIEW_WIDTH, height: ALERTVIEW_HEIGHT))
        backImage.image = UIImage(named: "beijingkuang_tuan")
        commonView!.addSubview(backImage)
        
        let setLb = UILabel()
        setLb.textColor = UIColor.red
        setLb.font = UIFont(name: "Helvetica-Bold", size: 22)
        setLb.textAlignment = .left
        commonView!.addSubview(setLb)

        setLb.snp.makeConstraints{(make)->Void in
            make.top.equalTo(commonView!).offset(10)
            make.left.equalTo(commonView!).offset(10)
            make.right.equalTo(commonView!).offset(-10)
            make.height.equalTo(30)
        }

        if (title != nil) {
            setLb.text = title
        }
        
        let nameLb = UILabel()
        nameLb.textColor = UIColor.gray
        nameLb.font = UIFont(name: "Helvetica-Bold", size: 16)
        commonView!.addSubview(nameLb)
        
        nameLb.snp.makeConstraints{(make)->Void in
            make.top.equalTo(setLb).offset(60)
            make.left.equalTo(commonView!).offset(10)
            make.width.equalTo(70)
            make.height.equalTo(30)
        }
        
        if name != nil{
            nameLb.text = name
        }
        
        //年份
        commonTf_y = UITextField()
        commonTf_y!.textColor = UIColor.gray
        commonTf_y!.font = UIFont(name: "Helvetica-Bold", size: 20)
        commonTf_y!.placeholder = tf
        commonTf_y?.keyboardType = .numberPad
        commonView!.addSubview(commonTf_y!)
        
        commonTf_y!.snp.makeConstraints{(make)->Void in
            make.top.equalTo(setLb).offset(48)
            make.left.equalTo(nameLb).offset(75)
            make.width.equalTo(commonView!).offset(-10)
            make.height.equalTo(54)
        }
        
        let lineView = UIView()
        lineView.backgroundColor = UIColor.gray
        commonView!.addSubview(lineView)
        
        lineView.snp.makeConstraints{(make)->Void in
            make.top.equalTo(commonTf_y!).offset(55)
            make.left.equalTo(commonView!).offset(10)
            make.right.equalTo(commonView!).offset(-10)
            make.height.equalTo(0.5)
        }
        
        //月份
        let commonLbTwo = UILabel()
        commonLbTwo.text = "Month:"
        commonLbTwo.font = UIFont(name: "Helvetica-Bold", size: 16)
        commonLbTwo.textColor = UIColor.gray
        commonView!.addSubview(commonLbTwo)
        
        commonLbTwo.snp.makeConstraints{(make)->Void in
            make.top.equalTo(lineView).offset(20)
            make.left.equalTo(commonView!).offset(10)
            make.width.equalTo(82)
            make.height.equalTo(30)
        }
        
        commonTf_m = UITextField()
        commonTf_m!.font = UIFont(name: "Helvetica-Bold", size: 20)
        commonTf_m!.textColor = UIColor.gray
        commonTf_m!.placeholder = tf
        commonTf_m?.keyboardType = .numberPad
        commonView!.addSubview(commonTf_m!)
        
        commonTf_m!.snp.makeConstraints{(make)->Void in
            make.top.equalTo(lineView).offset(10)
            make.left.equalTo(commonLbTwo).offset(85)
            make.width.equalTo(commonView!).offset(-10)
            make.height.equalTo(54)
        }
        
        let lineViewTwo = UIView()
        lineViewTwo.backgroundColor = UIColor.gray
        commonView!.addSubview(lineViewTwo)
        
        lineViewTwo.snp.makeConstraints{(make)->Void in
            make.top.equalTo(commonTf_m!).offset(55)
            make.left.equalTo(commonView!).offset(10)
            make.right.equalTo(commonView!).offset(-10)
            make.height.equalTo(0.5)
        }
        
        
        //日份
        let commonLb_d = UILabel()
        commonLb_d.text = "Day:"
        commonLb_d.font = UIFont(name: "Helvetica-Bold", size: 16)
        commonLb_d.textColor = UIColor.gray
        commonView!.addSubview(commonLb_d)
        
        commonLb_d.snp.makeConstraints{(make)->Void in
            make.top.equalTo(lineViewTwo).offset(20)
            make.left.equalTo(commonView!).offset(10)
            make.width.equalTo(82)
            make.height.equalTo(30)
        }
        
        commonTf_d = UITextField()
        commonTf_d!.font = UIFont(name: "Helvetica-Bold", size: 20)
        commonTf_d!.textColor = UIColor.gray
        commonTf_d!.placeholder = tf
        commonTf_d?.keyboardType = .numberPad
        commonView!.addSubview(commonTf_d!)
        
        commonTf_d!.snp.makeConstraints{(make)->Void in
            make.top.equalTo(lineViewTwo).offset(10)
            make.left.equalTo(commonLb_d).offset(85)
            make.width.equalTo(commonView!).offset(-10)
            make.height.equalTo(54)
        }
        
        let lineViewThree = UIView()
        lineViewThree.backgroundColor = UIColor.gray
        commonView!.addSubview(lineViewThree)
        
        lineViewThree.snp.makeConstraints{(make)->Void in
            make.top.equalTo(commonTf_d!).offset(55)
            make.left.equalTo(commonView!).offset(10)
            make.right.equalTo(commonView!).offset(-10)
            make.height.equalTo(0.5)
        }
        
        //时
        let commonLb_h = UILabel()
        commonLb_h.text = "Hour:"
        commonLb_h.font = UIFont(name: "Helvetica-Bold", size: 16)
        commonLb_h.textColor = UIColor.gray
        commonView!.addSubview(commonLb_h)
        
        commonLb_h.snp.makeConstraints{(make)->Void in
            make.top.equalTo(lineViewThree).offset(20)
            make.left.equalTo(commonView!).offset(10)
            make.width.equalTo(82)
            make.height.equalTo(30)
        }
        
        commonTf_h = UITextField()
        commonTf_h!.font = UIFont(name: "Helvetica-Bold", size: 20)
        commonTf_h!.textColor = UIColor.gray
        commonTf_h!.placeholder = tf
        commonTf_h?.keyboardType = .numberPad
        commonView!.addSubview(commonTf_h!)
        
        commonTf_h!.snp.makeConstraints{(make)->Void in
            make.top.equalTo(lineViewThree).offset(10)
            make.left.equalTo(commonLb_h).offset(85)
            make.width.equalTo(commonView!).offset(-10)
            make.height.equalTo(54)
        }
        
        let lineViewFour = UIView()
        lineViewFour.backgroundColor = UIColor.gray
        commonView!.addSubview(lineViewFour)
        
        lineViewFour.snp.makeConstraints{(make)->Void in
            make.top.equalTo(commonTf_h!).offset(55)
            make.left.equalTo(commonView!).offset(10)
            make.right.equalTo(commonView!).offset(-10)
            make.height.equalTo(0.5)
        }
        
        //分
        let commonLb_s = UILabel()
        commonLb_s.text = "Minute:"
        commonLb_s.font = UIFont(name: "Helvetica-Bold", size: 16)
        commonLb_s.textColor = UIColor.gray
        commonView!.addSubview(commonLb_s)
        
        commonLb_s.snp.makeConstraints{(make)->Void in
            make.top.equalTo(lineViewFour).offset(20)
            make.left.equalTo(commonView!).offset(10)
            make.width.equalTo(82)
            make.height.equalTo(30)
        }
        
        commonTf_s = UITextField()
        commonTf_s!.font = UIFont(name: "Helvetica-Bold", size: 20)
        commonTf_s!.textColor = UIColor.gray
        commonTf_s!.placeholder = tf
        commonTf_s?.keyboardType = .numberPad
        commonView!.addSubview(commonTf_s!)
        
        commonTf_s!.snp.makeConstraints{(make)->Void in
            make.top.equalTo(lineViewFour).offset(10)
            make.left.equalTo(commonLb_s).offset(85)
            make.width.equalTo(commonView!).offset(-10)
            make.height.equalTo(54)
        }
        
        let lineViewFive = UIView()
        lineViewFive.backgroundColor = UIColor.gray
        commonView!.addSubview(lineViewFive)
        
        lineViewFive.snp.makeConstraints{(make)->Void in
            make.top.equalTo(commonTf_s!).offset(55)
            make.left.equalTo(commonView!).offset(10)
            make.right.equalTo(commonView!).offset(-10)
            make.height.equalTo(0.5)
        }
        
        sureBtn = UIButton()
        sureBtn?.backgroundColor = UIColor(hexString: "#999999", transparency: 1.0)
        sureBtn?.layer.cornerRadius = 15
        sureBtn?.setTitle("Confirm", for: .normal)
        commonView!.addSubview(sureBtn!)
        
        sureBtn!.snp.makeConstraints{(make)->Void in
            make.left.equalTo(commonView!).offset(10)
            make.width.equalTo(commonView!).multipliedBy(0.4)
            make.bottom.equalTo(commonView!).offset(-10)
            make.height.equalTo(55)
        }
        
        cancelBtn = UIButton()
        cancelBtn?.backgroundColor = UIColor(hexString: "#999999", transparency: 1.0)
        cancelBtn?.layer.cornerRadius = 15
        cancelBtn?.setTitle("Cancel", for: .normal)
        commonView!.addSubview(cancelBtn!)
        
        cancelBtn!.snp.makeConstraints{(make)->Void in
            make.right.equalTo(commonView!).offset(-10)
            make.width.equalTo(commonView!).multipliedBy(0.4)
            make.bottom.equalTo(commonView!).offset(-10)
            make.height.equalTo(55)
        }
        
        commonTf_y?.delegate = self
        commonTf_m?.delegate = self
        commonTf_d?.delegate = self
        commonTf_h?.delegate = self
        commonTf_s?.delegate = self
        
        sureBtn!.addTarget(self, action: #selector(sureOnClick(sender:)), for: .touchUpInside)

        cancelBtn!.addTarget(self, action: #selector(cancelOnClick(sender:)), for: .touchUpInside)
 
        showView()
    }
    
    @objc func sureOnClick(sender:UIButton){
        if sureBolck != nil{
            sureBolck!(true)
        }
        hideView()
    }
    
    @objc func cancelOnClick(sender:UIButton){
        hideView()
    }
    
    func clickSureBtn(_ block: @escaping sureSetDateTimeClick) {
        sureBolck = block
    }
    
    func showView() {
        backgroundColor = UIColor.clear
        UIApplication.shared.keyWindow?.addSubview(self)
        
        //let identity = CGAffineTransform.identity
        //identity.scaledBy(x: 1.0, y: 1.0)
        
        let transform: CGAffineTransform = CGAffineTransform(scaleX: 1.0,y: 1.0)
        commonView!.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        commonView!.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: .curveLinear, animations: {
            self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            self.commonView!.transform = transform
            self.commonView!.alpha = 1
        }) { finished in
        }
    }
    
    func hideView() {
        UIView.animate(withDuration: 0.5, animations: {
            self.transform = self.transform.translatedBy(x: 0, y: -self.frame.maxY)
            self.commonView!.alpha = 0
        }) { isFinished in
            self.commonView!.removeFromSuperview()
            self.removeFromSuperview()
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        commonTf_y?.resignFirstResponder()
        commonTf_m?.resignFirstResponder()
        commonTf_d?.resignFirstResponder()
        commonTf_h?.resignFirstResponder()
        commonTf_s?.resignFirstResponder()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        commonTf_y?.resignFirstResponder()
        commonTf_m?.resignFirstResponder()
        commonTf_d?.resignFirstResponder()
        commonTf_h?.resignFirstResponder()
        commonTf_s?.resignFirstResponder()
        return true
    }
}
