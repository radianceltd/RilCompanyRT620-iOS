//
//  SetBleInstructView.swift
//  RilCompanyRT617-iOS
//
//  Created by RND on 2023/9/1.
//

import UIKit
import SnapKit

typealias sureBleInstructClick = (_ select:Bool) -> Void

class SetBleInstructView: UIView,UITextFieldDelegate {
    
    var commonView:UIView?

    var commonTf_intv:UITextField?
    var commonTf_time:UITextField?
    var commonTf_min_intv:UITextField?
    var commonTf_max_intv:UITextField?
    
    var adv_intv_text:UILabel?
    
    var sureBtn:UIButton?
    var cancelBtn:UIButton?
    var commonViewCloseBlock: (() -> Void)?
    var sureBolck:sureBleInstructClick?
    
    //静态常量
    let ALERTVIEW_HEIGHT = UIScreen.main.bounds.size.height / 1.4
    let ALERTVIEW_WIDTH = UIScreen.main.bounds.size.width - 50
    let HEIGHT = UIScreen.main.bounds.size.height
    let WIDTH = UIScreen.main.bounds.size.width
    
    init(title: String?, p_name name: String?,p_name1 name1: String?,p_name2 name2: String?,p_name3 name3: String?, p_tf tf: String?) {
        let frame = CGRect(x: 0, y: 0,
        width: UIScreen.main.bounds.size.width,
        height: UIScreen.main.bounds.size.height)
        super.init(frame:frame)
        initView(title: title, p_name: name,p_name1: name1,p_name2: name2,p_name3: name3, p_tf: tf)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initView(title: String?, p_name name: String?,p_name1 name1: String?,p_name2 name2: String?,p_name3 name3: String?, p_tf tf: String?) {
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
    
            make.height.equalTo(30)
        }
        
        if name != nil{
            nameLb.text = name
        }
        
        //年份
        commonTf_intv = UITextField()
        commonTf_intv!.textColor = UIColor.gray
        commonTf_intv!.font = UIFont(name: "Helvetica-Bold", size: 20)
        commonTf_intv!.placeholder = tf
        commonTf_intv?.keyboardType = .numberPad
        commonView!.addSubview(commonTf_intv!)
        
        commonTf_intv!.snp.makeConstraints{(make)->Void in
            make.top.equalTo(setLb).offset(48)
            make.left.equalTo(nameLb).offset(95)
            make.width.equalTo(commonView!).offset(-10)
            make.height.equalTo(54)
        }
        
        adv_intv_text =  UILabel()
        adv_intv_text!.text = "ms"
        commonView!.addSubview(adv_intv_text!)
        
        adv_intv_text!.snp.makeConstraints{(make)->Void in
            make.top.equalTo(setLb).offset(48)
            make.right.equalTo(commonView!).offset(-15)
            make.height.equalTo(54)
        }
        
        let lineView = UIView()
        lineView.backgroundColor = UIColor.gray
        commonView!.addSubview(lineView)
        
        lineView.snp.makeConstraints{(make)->Void in
            make.top.equalTo(commonTf_intv!).offset(55)
            make.left.equalTo(commonView!).offset(10)
            make.right.equalTo(commonView!).offset(-10)
            make.height.equalTo(0.5)
        }
        
        //月份
        let commonLbTwo = UILabel()
        commonLbTwo.font = UIFont(name: "Helvetica-Bold", size: 16)
        commonLbTwo.textColor = UIColor.gray
        commonView!.addSubview(commonLbTwo)
        
        commonLbTwo.snp.makeConstraints{(make)->Void in
            make.top.equalTo(lineView).offset(20)
            make.left.equalTo(commonView!).offset(10)
            make.height.equalTo(30)
        }
        
        if name1 != nil{
            commonLbTwo.text = name1
        }
        
        commonTf_time = UITextField()
        commonTf_time!.font = UIFont(name: "Helvetica-Bold", size: 20)
        commonTf_time!.textColor = UIColor.gray
        commonTf_time!.placeholder = tf
        commonTf_time?.keyboardType = .numberPad
        commonView!.addSubview(commonTf_time!)
        
        commonTf_time!.snp.makeConstraints{(make)->Void in
            make.top.equalTo(lineView).offset(10)
            make.left.equalTo(commonLbTwo).offset(95)
            make.width.equalTo(commonView!).offset(-10)
            make.height.equalTo(54)
        }
        
        adv_intv_text =  UILabel()
        adv_intv_text!.text = "ms"
        commonView!.addSubview(adv_intv_text!)
        
        adv_intv_text!.snp.makeConstraints{(make)->Void in
            make.top.equalTo(lineView).offset(10)
            make.right.equalTo(commonView!).offset(-15)
            make.height.equalTo(54)
        }
        
        let lineViewTwo = UIView()
        lineViewTwo.backgroundColor = UIColor.gray
        commonView!.addSubview(lineViewTwo)
        
        lineViewTwo.snp.makeConstraints{(make)->Void in
            make.top.equalTo(commonTf_time!).offset(55)
            make.left.equalTo(commonView!).offset(10)
            make.right.equalTo(commonView!).offset(-10)
            make.height.equalTo(0.5)
        }
        
        
        //日份
        let commonLb_d = UILabel()

        commonLb_d.font = UIFont(name: "Helvetica-Bold", size: 16)
        commonLb_d.textColor = UIColor.gray
        commonView!.addSubview(commonLb_d)
        
        commonLb_d.snp.makeConstraints{(make)->Void in
            make.top.equalTo(lineViewTwo).offset(20)
            make.left.equalTo(commonView!).offset(10)
            make.height.equalTo(30)
        }
        
        if name2 != nil{
            commonLb_d.text = name2
        }
        
        commonTf_min_intv = UITextField()
        commonTf_min_intv!.font = UIFont(name: "Helvetica-Bold", size: 20)
        commonTf_min_intv!.textColor = UIColor.gray
        commonTf_min_intv!.placeholder = tf
        commonTf_min_intv?.keyboardType = .numberPad
        commonView!.addSubview(commonTf_min_intv!)
        
        commonTf_min_intv!.snp.makeConstraints{(make)->Void in
            make.top.equalTo(lineViewTwo).offset(10)
            make.left.equalTo(commonLb_d).offset(145)
            make.width.equalTo(commonView!).offset(-10)
            make.height.equalTo(54)
        }
        
        adv_intv_text =  UILabel()
        adv_intv_text!.text = "ms"
        commonView!.addSubview(adv_intv_text!)
        
        adv_intv_text!.snp.makeConstraints{(make)->Void in
            make.top.equalTo(lineViewTwo).offset(10)
            make.right.equalTo(commonView!).offset(-15)
            make.height.equalTo(54)
        }
        
        let lineViewThree = UIView()
        lineViewThree.backgroundColor = UIColor.gray
        commonView!.addSubview(lineViewThree)
        
        lineViewThree.snp.makeConstraints{(make)->Void in
            make.top.equalTo(commonTf_min_intv!).offset(55)
            make.left.equalTo(commonView!).offset(10)
            make.right.equalTo(commonView!).offset(-10)
            make.height.equalTo(0.5)
        }
        
        //分
        let commonLb_h = UILabel()
        commonLb_h.font = UIFont(name: "Helvetica-Bold", size: 16)
        commonLb_h.textColor = UIColor.gray
        commonView!.addSubview(commonLb_h)
        
        commonLb_h.snp.makeConstraints{(make)->Void in
            make.top.equalTo(lineViewThree).offset(20)
            make.left.equalTo(commonView!).offset(10)
            make.height.equalTo(30)
        }
        
        if name3 != nil{
            commonLb_h.text = name3
        }
        
        
        commonTf_max_intv = UITextField()
        commonTf_max_intv!.font = UIFont(name: "Helvetica-Bold", size: 20)
        commonTf_max_intv!.textColor = UIColor.gray
        commonTf_max_intv!.placeholder = tf
        commonTf_max_intv?.keyboardType = .numberPad
        commonView!.addSubview(commonTf_max_intv!)
        
        commonTf_max_intv!.snp.makeConstraints{(make)->Void in
            make.top.equalTo(lineViewThree).offset(10)
            make.left.equalTo(commonLb_h).offset(145)
            make.width.equalTo(commonView!).offset(-10)
            make.height.equalTo(54)
        }
        
        adv_intv_text =  UILabel()
        adv_intv_text!.text = "ms"
        commonView!.addSubview(adv_intv_text!)
        
        adv_intv_text!.snp.makeConstraints{(make)->Void in
            make.top.equalTo(lineViewThree).offset(10)
            make.right.equalTo(commonView!).offset(-15)
            make.height.equalTo(54)
        }
        
        let lineViewFour = UIView()
        lineViewFour.backgroundColor = UIColor.gray
        commonView!.addSubview(lineViewFour)
        
        lineViewFour.snp.makeConstraints{(make)->Void in
            make.top.equalTo(commonTf_max_intv!).offset(55)
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
        
        commonTf_intv?.delegate = self
        commonTf_time?.delegate = self
        commonTf_min_intv?.delegate = self
        commonTf_max_intv?.delegate = self
        
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
        commonTf_intv?.resignFirstResponder()
        commonTf_time?.resignFirstResponder()
        commonTf_min_intv?.resignFirstResponder()
        commonTf_max_intv?.resignFirstResponder()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        commonTf_intv?.resignFirstResponder()
        commonTf_time?.resignFirstResponder()
        commonTf_min_intv?.resignFirstResponder()
        commonTf_max_intv?.resignFirstResponder()
        return true
    }
}
