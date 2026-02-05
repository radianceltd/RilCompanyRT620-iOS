//
//  DatePickerView.swift
//  RilCompanyRT617-iOS
//
//  Created by RND on 2023/11/28.
//

import UIKit
import WHToast


class DatePickerView: BaseView {
    
    ///获取当前日期
    private var currentDateCom: DateComponents = Calendar.current.dateComponents([.year, .month, .day],   from: Date())    //日期
    
    let WIDTH = UIScreen.main.bounds.size.width - 50
    
    var selectButtonCallBack:((_ model: Any)-> Void)?
    
    //默认选中第一个
    //var indexPath:Int = 0
    
    //var array = [Any]()
    
    //var model:Any = ()
    
    var picker: UIPickerView?
    
    var contenView:UIView?
    {
        didSet{
            setUpContent()
        }
    }
    
    init(frame: CGRect, name: String) {
        //array = list
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
        self.picker = UIPickerView()
        mainView.addSubview(self.picker!)
        
        self.picker!.snp.makeConstraints{(maker) in
            maker.bottom.equalTo(mainView).offset(-5)
            maker.left.equalTo(mainView).offset(-0)
            maker.right.equalTo(mainView).offset(0)
            maker.height.equalTo(180)
        }
        
        self.picker!.delegate = self
        self.picker!.dataSource = self
        
        // 获取当前系统的年月日时分
        let currentDate = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: currentDate)
        let month = calendar.component(.month, from: currentDate)
        let day = calendar.component(.day, from: currentDate)
        let hour = calendar.component(.hour, from: currentDate)
        let minute = calendar.component(.minute, from: currentDate)
//        print("333===",picker?.selectedRow(inComponent: 1) as Any)
        // 设置picker的初始选中行
        picker?.selectRow(year - (currentDateCom.year!), inComponent: 0, animated: false)
        picker?.selectRow(month - 1, inComponent: 1, animated: false)
        picker?.selectRow(day - 1, inComponent: 2, animated: false)
        picker?.selectRow(hour, inComponent: 3, animated: false)
        picker?.selectRow(minute, inComponent: 4, animated: false)
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
            
            let dateString = String(format: "%04ld-%02ld-%02ld %02ld:%02ld", self.picker!.selectedRow(inComponent: 0) + (self.currentDateCom.year!), self.picker!.selectedRow(inComponent: 1) + 1,
                                    self.picker!.selectedRow(inComponent: 2) + 1,
                                    self.picker!.selectedRow(inComponent: 3),
                                    self.picker!.selectedRow(inComponent: 4))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            let date = dateFormatter.date(from: dateString) ?? Date()
            /// 直接回调显示 显示日期
            self.selectButtonCallBack!(date)
            
        }
    }
    
    @objc func buttonCancel() -> Void {
        hideView()
    }
}


extension DatePickerView: UIPickerViewDelegate,UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 5
    }
    //每列的个数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 72
        } else if component == 1 {
            return 12
        }else if component == 2{
            let year: Int = pickerView.selectedRow(inComponent: 0) + currentDateCom.year!
           print("pickerView.selectedRow(inComponent: 1)==",pickerView.selectedRow(inComponent: 1))
            let month: Int = pickerView.selectedRow(inComponent: 1) + 1
            let days: Int = howManyDays(inThisYear: year, withMonth: month)
            return days
        }else if component == 3{
            return 24
        }else if component == 4{
            return 60
        }else{
            return 60
        }
    }
    
    //月份的判断，不同的月份，显示不同的日期
    private func howManyDays(inThisYear year: Int, withMonth month: Int) -> Int {
        if (month == 1) || (month == 3) || (month == 5) || (month == 7) || (month == 8) || (month == 10) || (month == 12) {
            return 31
        }
        if (month == 4) || (month == 6) || (month == 9) || (month == 11) {
            return 30
        }
        if (year % 4 == 1) || (year % 4 == 2) || (year % 4 == 3) {
            return 28
        }
        if year % 400 == 0 {
            return 29
        }
        if year % 100 == 0 {
            return 28
        }
        return 29
    }
    
    //每个列的宽度
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if component == 0 {
            return 80 // 第一个数据的宽度为 90px
        } else if component == 1 {
            return 50 // 第二个数据的宽度为 60px
        }else if component == 2 {
            return 50 // 第三个数据的宽度为 60px
        }else if component == 3 {
            return 50 // 第四个数据的宽度为 60px
        }else if component == 4 {
            return 50 // 第五个数据的宽度为 60px
        }
        return 50 // 默认宽度为 50px
        //        let screenWidth = UIScreen.main.bounds.width
        //        return screenWidth / 5
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 20
    }
    
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        if component == 0 {
//            let year = currentDateCom.year! + row
//            return "\(year)\("Y")"
//        } else if component == 1 {
//            print("int==",row)
//            return "\(row + 1)\("M")"
//        } else if component == 2{
//            return "\(row + 1)\("D")"
//        } else if component == 3 {
//            return "\(row)\("H")"
//        }else if component == 4{
//            return "\(row)\("m")"
//        }else{
//            return "\(row)\("m")"
//        }
//    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
                if component == 1 {
                    pickerView.reloadComponent(2)
                }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20) // 设置字体大小为 14，可以根据需要进行调整
        label.textAlignment = .center // 设置文本居中对齐

        // 根据不同的列，设置不同的文本内容
        if component == 0 {
            let year = currentDateCom.year! + row
            label.text = "\(year)\("Y")"
        } else if component == 1 {
            label.text = "\(row + 1)\("M")"
        } else if component == 2 {
            label.text = "\(row + 1)\("D")"
        } else if component == 3 {
            label.text = "\(row)\("H")"
        } else if component == 4 {
            label.text = "\(row)\("m")"
        }

        return label
    }
}

