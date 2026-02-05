//
//  SelectTimeView.swift
//  RilCompanyRT617-iOS
//
//  Created by RND on 2023/8/25.
//

import UIKit
import SnapKit
import WHToast

class SelectTimeView: UIView {
    
    let WIDTH = UIScreen.main.bounds.size.width - 50
    
    var selectButtonCallBack:((_ model: Any)-> Void)?
   
    //默认选中第一个
    var indexPath:Int = 0
    
    var array = [Any]()
    
    var model:Any = ()
    
    var contenView:UIView?
       
       {
           didSet{
               setUpContent()
           }
       }
       
       init(frame: CGRect, list:[Any]) {
           array = list
           super.init(frame: frame)
       }
       
       required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
       
       func setUpContent(){
           if self.contenView != nil {
               self.contenView?.frame.origin.y = UIScreen.main.bounds.size.height - 200
               self.addSubview(self.contenView!)
           }
           self.backgroundColor = UIColor(hexString: "#555555", transparency: 0.5)
           self.isUserInteractionEnabled = true
           self.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(dismissView)))
           //以下为添加内容，可根据需要删除以下部分
           sudokuConstraints()
       }
       
       @objc func dismissView(){
           UIView.animate(withDuration: 0.3, animations: {
               self.alpha = 0
           }) { (true) in
               self.removeFromSuperview()
               self.contenView?.removeFromSuperview()
           }
       }
       
       func showInWindow(){
           UIApplication.shared.keyWindow?.addSubview(self)
           UIView.animate(withDuration: 0.3, animations: {
               self.alpha = 1.0
               self.contenView?.frame.origin.y = UIScreen.main.bounds.size.height - 230
           }, completion: nil)
       }
       
       //MARK: - 布局
       func sudokuConstraints() -> Void {
           
           let mainView = UIView()
           mainView.backgroundColor = UIColor.white
           self.contenView?.addSubview(mainView)
           
           mainView.snp.makeConstraints{(maker) in
               maker.bottom.equalTo(self.contenView!).offset(0)
               maker.left.equalTo(self.contenView!).offset(0)
               maker.right.equalTo(self.contenView!).offset(0)
               maker.height.equalTo(230)
           }
           
           //创建确定按钮
           let confirm = UIButton()
           confirm.setTitle("Confirm", for: .normal)
           confirm.layer.cornerRadius = 10
           confirm.backgroundColor = UIColor.gray
           confirm.titleLabel?.textColor = UIColor.white
           mainView.addSubview(confirm)
           
           confirm.snp.makeConstraints{(maker) in
               maker.top.equalTo(mainView).offset(5)
               maker.right.equalTo(mainView).offset(-10)
               maker.width.equalTo(100)
               maker.height.equalTo(50)
           }
           
           confirm.addTarget(self, action: #selector(buttonClickAction), for: .touchUpInside)
           
           let cancel = UIButton()
           cancel.setTitle("Cancel", for: .normal)
           cancel.layer.cornerRadius = 10
           cancel.backgroundColor = UIColor.gray
           cancel.titleLabel?.textColor = UIColor.white
           mainView.addSubview(cancel)
           
           cancel.snp.makeConstraints{(maker) in
               maker.top.equalTo(mainView).offset(5)
               maker.left.equalTo(mainView).offset(10)
               maker.width.equalTo(100)
               maker.height.equalTo(50)
           }
           
           cancel.addTarget(self, action: #selector(buttonCancel), for: .touchUpInside)
           
           //创建PickView布局
           let pickView = UIPickerView()
           mainView.addSubview(pickView)
           
           pickView.snp.makeConstraints{(maker) in
               maker.bottom.equalTo(mainView).offset(-10)
               maker.left.equalTo(mainView).offset(-10)
               maker.right.equalTo(mainView).offset(10)
               maker.height.equalTo(180)
           }
           
           
           pickView.delegate = self
           pickView.dataSource = self
           
          
        
        if(array.count > 0){
            //默认选中第一个
            pickView.selectedRow(inComponent: 0)
           model = array[0]
        }else{
            WHToast.showMessage("Please import at least one key file!", originY: 500, duration: 2, finishHandler: {
            })
            //toastMessage(mes: "Please import at least one key file!")
            //return
        }
           //第一个选中
           //model = []
           
           //smodel = Single.deserialize(from: tarray[0].value)!
           //第一个选中
           //cmodel = smodel.cooks![0]
       }
       

       func hideView() {
           UIView.animate(withDuration: 0.5, animations: {
               self.transform = self.transform.translatedBy(x: 0, y: -self.frame.maxY)
               self.contenView!.alpha = 0
           }) { isFinished in
               self.contenView!.removeFromSuperview()
               self.removeFromSuperview()
           }
       }

       @objc func buttonClickAction() -> Void {
           if self.selectButtonCallBack != nil {
               self.selectButtonCallBack!(model)
           }
       }
       
       @objc func buttonCancel() -> Void {
           hideView()
       }
    

}


extension SelectTimeView: UIPickerViewDelegate,UIPickerViewDataSource{
    
    // MARK: Picker Delegate 实现代理方法
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        //返回多少列
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        if component == 0 {
//            return array.count
//        }
        return array.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        //每行多高
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        //if component == 0 {
        let model = array[row]
        return (model as! TimeModel).time
        //}
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        if component == 0 {
//            indexPath = pickerView.selectedRow(inComponent: 0)
//            pickerView.reloadComponent(1)
//        }
        indexPath = row
        let title = array[row]
        model = title as Any
    }
}



