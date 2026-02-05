//
//  UpdateTimeView.swift
//  TMW041RT
//
//  Created by RND on 2023/6/5.
//

import UIKit
import SnapKit

let ALERTVIEW_HEIGHT = UIScreen.main.bounds.size.height / 2.1
let ALERTVIEW_WIDTH = UIScreen.main.bounds.size.width - 50


typealias sureDeviceBtnClick = (_ select:Bool) -> Void

@objc protocol UpdateViewProtocol:NSObjectProtocol {

    //func scanOnClick()

}

class UpdateTimeView: BaseView {
    
    weak var delegate:UpdateViewProtocol?
    
    var mUpdateView: UIView?
    var mMinutePicker: UIPickerView?
    //var mSecondPicker: UIPickerView?
    var sureBtn: UIButton?
    var cancelBtn: UIButton?
    var commonViewCloseBlock: (() -> Void)?
    var sureBolck:sureDeviceBtnClick?
    //var cmUtil: CommonUtil?
    
    let HEIGHT = UIScreen.main.bounds.size.height
    let WIDTH = UIScreen.main.bounds.size.width
    
    init(title: String?, p_name name: String?, p_tf tf: String?,view:UIView) {
        let frame = CGRect(x: 0, y: 0,
        width: UIScreen.main.bounds.size.width,
        height: UIScreen.main.bounds.size.height)
        super.init(frame:frame)
        initView(title: title, p_name: name, p_tf: tf,view: view)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func initView(title: String?, p_name name: String?, p_tf tf: String?, view:UIView) {
        
        mUpdateView = UIView(frame: CGRect(x:25, y: HEIGHT/2-ALERTVIEW_HEIGHT/2, width: ALERTVIEW_WIDTH, height: ALERTVIEW_HEIGHT))
        mUpdateView!.backgroundColor = UIColor.white
        mUpdateView!.layer.cornerRadius = 8.0
        mUpdateView!.layer.masksToBounds = true
        mUpdateView!.isUserInteractionEnabled = true

        self.addSubview(mUpdateView!)
        self.frame = UIScreen.main.bounds
        
        self.isUserInteractionEnabled = true;
        self.layer.masksToBounds    = true;
        self.layer.shadowOpacity    = 2;
        self.layer.shadowOffset = CGSize.init(width: 0, height: 2.5)
        
        let updateLb = UILabel()
        updateLb.text = title
        updateLb.textColor = UIColor.red
        updateLb.font = UIFont(name: "Helvetica-Bold", size: 22)
        updateLb.textAlignment = .left
        mUpdateView!.addSubview(updateLb)
        
        updateLb.snp.makeConstraints{(make)->Void in
            make.top.equalTo(mUpdateView!).offset(10);
            make.left.equalTo(mUpdateView!).offset(10);
            make.right.equalTo(mUpdateView!).offset(-10);
            make.height.equalTo(30);
        }
        
        mMinutePicker = UIPickerView()
        mMinutePicker!.backgroundColor = UIColor.clear
        mMinutePicker!.layer.cornerRadius = 10
        mMinutePicker!.layer.masksToBounds = true
        mMinutePicker!.layer.borderWidth = 3
        mMinutePicker!.layer.borderColor = UIColor(white: 0.4, alpha: 0.5).cgColor
        mUpdateView!.addSubview(mMinutePicker!)
        
        mMinutePicker!.snp.makeConstraints{(make)->Void in
           make.top.equalTo(updateLb).offset(40);
            //make.centerX.equalTo(mUpdateView!)
            make.left.equalTo(mUpdateView!).offset(ALERTVIEW_WIDTH/2.5);
            make.width.equalTo(70)
            make.height.equalTo(130);
        }
//
//        mSecondPicker = UIPickerView()
//        mSecondPicker!.backgroundColor = UIColor.clear
//        mSecondPicker!.layer.cornerRadius = 10
//        mSecondPicker!.layer.masksToBounds = true
//        mSecondPicker!.layer.borderWidth = 3
//        mSecondPicker!.layer.borderColor = UIColor(white: 0.4, alpha: 0.5).cgColor
//        mUpdateView!.addSubview(mSecondPicker!)
//
//        mSecondPicker!.snp.makeConstraints{(make)->Void in
//            make.top.equalTo(updateLb).offset(40);
//            make.right.equalTo(mUpdateView!).offset(-35);
//            make.width.equalTo(70)
//            make.height.equalTo(130);
//        }
        
        sureBtn = UIButton()
        sureBtn!.backgroundColor = UIColor.gray
        sureBtn!.layer.cornerRadius = 15
        let network = "Confirm"
        sureBtn!.setTitle(network, for: .normal)
        mUpdateView!.addSubview(sureBtn!)
        
        sureBtn!.snp.makeConstraints{(make)->Void in
            make.left.equalTo(mUpdateView!).offset(10);
            make.width.equalTo(mUpdateView!).multipliedBy(0.4)
            make.height.equalTo(55);
            make.bottom.equalTo(mUpdateView!).offset(-10)
        }
        
        cancelBtn = UIButton()
        cancelBtn!.backgroundColor = UIColor.gray
        cancelBtn!.layer.cornerRadius = 15
        let cancel = "Cancel"
        cancelBtn!.setTitle(cancel, for: .normal)
        mUpdateView!.addSubview(cancelBtn!)
        
        cancelBtn!.snp.makeConstraints{(make)->Void in
            make.right.equalTo(self.mUpdateView!).offset(-10);
            make.width.equalTo(self.mUpdateView!).multipliedBy(0.4);
            make.bottom.equalTo(self.mUpdateView!).offset(-10);
            make.height.equalTo(55);
        }
        
        //取消点击事件
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
    
    func clickSureBtn(_ block: @escaping sureDeviceBtnClick) {
        sureBolck = block
    }
    
    func showView() {
        //self.backgroundColor = [UIColor clearColor];
            backgroundColor = UIColor.clear
              
              UIApplication.shared.keyWindow?.addSubview(self)
              //view.addSubview(self)

              let transform: CGAffineTransform = CGAffineTransform(scaleX: 1.0,y: 1.0)
              mUpdateView!.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
              mUpdateView!.alpha = 0
              UIView.animate(withDuration: 0.3, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: .curveLinear, animations: {
                  self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
                  self.mUpdateView!.transform = transform
                  self.mUpdateView!.alpha = 1
              }) { finished in
              }
    }
    
        func hideView() {
            UIView.animate(withDuration: 0.5, animations: {
                self.transform = self.transform.translatedBy(x: 0, y: -self.frame.maxY)
                self.mUpdateView!.alpha = 0
            }) { isFinished in
                self.mUpdateView!.removeFromSuperview()
                self.removeFromSuperview()
            }
        }
        
        func hide(){
            UIView.animate(withDuration: 0.5, animations: {
                self.transform = self.transform.translatedBy(x: 0, y: -self.HEIGHT)
                self.mUpdateView!.alpha = 0
            })
        }
        
        func show(){
    //        UIView.animate(withDuration: 0.3, animations: {
    //            self.alertView!.transform = CGAffineTransform(translationX: 100, y: 200)
    //        })
            
            UIView.animate(withDuration: 0.5, animations: {
                self.transform = self.transform.translatedBy(x: 0, y: self.HEIGHT)
                self.mUpdateView!.alpha = 1
            })
        }
}
