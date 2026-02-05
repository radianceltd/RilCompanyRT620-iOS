//
//  ProgressView.swift
//  RilCompanyRT617-iOS
//
//  Created by RND on 2023/11/30.
//

import UIKit
import WHToast
import MBProgressHUD
import Charts


let ALERTVIEW_HEIGHTM1 = UIScreen.main.bounds.size.height / 3.8
let ALERTVIEW_WIDTHM1 = UIScreen.main.bounds.size.width - 40
let HEIGHT1 = UIScreen.main.bounds.size.height
let WIDTH1 = UIScreen.main.bounds.size.width

protocol ProgressViewDelegate: NSObjectProtocol {
    //func hideAction()
    func closeAction()
}



class ProgressView: BaseView {

    weak var delegate: ProgressViewDelegate?
    
    var closeBtn: UIButton?
    
    //var moreView: MoreView?
    
    var downView: DownLoadView?
    
    var maska: UIView?
    
    
    override func initView() {
        
        show()
    }
    
    
    func show() {
        frame = UIScreen.main.bounds
        maska = UIView(frame: CGRect(x: 20, y: HEIGHT1 / 2 - ALERTVIEW_HEIGHTM1 / 2, width: ALERTVIEW_WIDTHM1, height: ALERTVIEW_HEIGHTM1))
        maska!.backgroundColor = UIColor.white
        maska!.layer.cornerRadius = 8.0
        maska!.layer.masksToBounds = true
        maska!.isUserInteractionEnabled = true
        self.addSubview(maska!)

        
        let updateLb = UILabel()
        updateLb.text = "Loading"
        updateLb.textColor = UIColor.red
        updateLb.font = UIFont(name: "Helvetica-Bold", size: 22)
        updateLb.textAlignment = .left
        maska!.addSubview(updateLb)
        
        updateLb.snp.makeConstraints{(make)->Void in
            make.top.equalTo(maska!).offset(10);
            make.left.equalTo(maska!).offset(10);
            make.right.equalTo(maska!).offset(-10);
            make.height.equalTo(30);
        }
        
        
        //下载View
        downView = DownLoadView()
        downView?.backgroundColor = UIColor.gray
        downView?.musicalColor = UIColor(hexString: "#555555", transparency: 1.0)
        downView?.placeholderBtnFont = UIFont(name: "Helvetica-Bold", size: 14)
        downView?.placeholderFont = UIFont(name: "Helvetica", size: 14)
        downView?.musicDownLoadLab.text = ""
        maska!.addSubview(downView!)

        downView!.snp.makeConstraints{(make)->Void in
            make.left.equalTo(maska!).offset(30)
            make.right.equalTo(maska!).offset(-30)
            make.top.equalTo(updateLb).offset(45)
            make.height.equalTo(50)
        }
        
        
        closeBtn = UIButton()
        let cancelImageView = UIImageView()
        cancelImageView.image = UIImage(named: "clear")
        closeBtn!.addSubview(cancelImageView)
        maska!.addSubview(closeBtn!)
        
        cancelImageView.snp.makeConstraints{(make)->Void in
            make.top.equalTo(closeBtn!).offset(0);
            make.left.equalTo(closeBtn!).offset(0);
            make.right.equalTo(closeBtn!).offset(0);
            make.bottom.equalTo(closeBtn!).offset(0);
        }
        
        closeBtn!.snp.makeConstraints{(make)->Void in
            make.top.equalTo(maska!).offset(10);
            make.right.equalTo(maska!).offset(-10);
            make.width.equalTo(30);
            make.height.equalTo(30);
        }
        
        //按钮点击事件
        closeBtn!.addTarget(self, action: #selector(closeAction), for: .touchUpInside)

        

        UIApplication.shared.keyWindow?.addSubview(self)
        let transform: CGAffineTransform = CGAffineTransform(scaleX: 1.0,y: 1.0)
        maska!.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        maska!.alpha = 0

        UIView.animate(withDuration: 0.3, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: .curveLinear, animations: {
            self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            self.maska!.transform = transform
            self.maska!.alpha = 1
        }) { finished in

        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.5, animations: {
            self.transform = self.transform.translatedBy(x: 0, y: -self.frame.maxY)
            self.maska!.alpha = 0
        }) { isFinished in
            self.maska!.removeFromSuperview()
            self.removeFromSuperview()
        }

        //触发事件
        //hideAction()
    }
    
    //点击按钮事件触发
//    func hideAction(){
//        //停止扫描
//        if (delegate != nil) {
//            delegate!.closeAction()
//        }
//    }
//
    @objc func closeAction(){
        print("closeAction")
        hide()

        if (delegate != nil) {
            delegate!.closeAction()
        }
    }
    
    
    

}
