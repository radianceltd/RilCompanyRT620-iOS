//
//  SetingView.swift
//  TMW041RT
//
//  Created by RND on 2023/5/18.
//

import UIKit

protocol SettingViewProtocol:NSObjectProtocol{
    func onSetChangEvent(withRow row:Int)
}

protocol SettingCellDelegate:NSObjectProtocol{
    func onTempRecordSwClick(sender:UISwitch)
    func onTempUnitRecordSwClick(sender:UISwitch)
    func didTapRightUnitButton()
}


class SettingView: BaseView {

    weak var delegate:SettingViewProtocol?
    
    var allExpanded = AllExpanded()
    
    var tableView: UITableView?
    
    override func initView() {
        setupSubviews()
    }
    
    func setupSubviews() {
        
        //TableView
        tableView = UITableView()
        tableView!.separatorStyle = .none
        //tableView!.backgroundColor = UIColor(hexString: "#EFEFEF", transparency: 1.0)
        tableView!.backgroundColor = allExpanded.nightModelAdaptation()
        addSubview(tableView!)
        
        tableView!.snp.makeConstraints{(make)->Void in
            make.top.equalTo(self)
            make.left.right.bottom.equalToSuperview()
        }
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        tableView!.addGestureRecognizer(longPressRecognizer)
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let location = gestureRecognizer.location(in: tableView)
            if let indexPath = tableView!.indexPathForRow(at: location) {
                // 处理长按事件
                if delegate != nil {
                    delegate!.onSetChangEvent(withRow: indexPath.row)
                }
            }
        }
    }
}

class SettingCell: UITableViewCell {
    
    weak var delegate:SettingCellDelegate?
    
    var mConLb: UILabel?
    var topView: UIView?
    var conView: UIView?
    var tempText: UILabel?
    var mConImage:UIImageView?
    var mRightTextLb:UILabel?
    var mRightSwitch:UISwitch?
    var mRightUnitSwitch:UISwitch?
    //温度符号的按钮图片
    var mRightUnitButton:UIButton?
    
    var mSettingBattery:UILabel?
    var mSettingBatteryLb:UILabel?
    var mSettingBatteryImage:UIImageView?
    var mSettingMac:UILabel?
    var mSettingName:UILabel?
    var mSettingUnit:UILabel?
    var mSettingUnitLift:UILabel?
    
    var mRightSwitchText:UILabel?
    
    var allExpanded = AllExpanded()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // 初始化UI
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupUI() {
        // 初始化各个子视图
        // ...
        //第一段
        topView = UIView()
        self.addSubview(topView!)
        
        topView!.snp.makeConstraints{
            (make)->Void in
            make.top.equalTo(self).offset(0)
            make.left.equalTo(self).offset(5)
            make.right.equalTo(self).offset(-5)
            make.height.equalTo(150)
        }
        
        let viewa = UIView()
        viewa.backgroundColor = allExpanded.listLineAdaptation()
        topView!.addSubview(viewa)
        
        viewa.snp.makeConstraints{
            (make)->Void in
            make.top.equalTo(self).offset(151)
            make.left.equalTo(self).offset(5)
            make.right.equalTo(self).offset(-5)
            make.height.equalTo(1)
        }
        
        //电池电量
        mSettingBattery = UILabel()
        mSettingBattery!.text = "Battery:"
        //mSettingBattery!.font = UIFont(name: "Helvetica", size:20)
        topView!.addSubview(mSettingBattery!)
        
        mSettingBattery!.snp.makeConstraints{
            (make)->Void in
            make.top.equalTo(topView!).offset(10)
            make.left.equalTo(topView!).offset(10)
        }
        
        mSettingBatteryLb = UILabel()
        mSettingBatteryLb!.text = ""
        mSettingBatteryLb!.isHidden = true
        //mSettingBattery!.font = UIFont(name: "Helvetica", size:20)
        topView!.addSubview(mSettingBatteryLb!)
        
        mSettingBatteryLb!.snp.makeConstraints{
            (make)->Void in
            make.top.equalTo(topView!).offset(10)
            make.left.equalTo(mSettingBattery!).offset(60)
        }
        
        mSettingBatteryImage = UIImageView(image: UIImage(named: "battery"))
        mSettingBatteryImage!.isHidden = true
        topView?.addSubview(mSettingBatteryImage!)
        
        mSettingBatteryImage!.snp.makeConstraints{
            (make)->Void in
            make.top.equalTo(topView!).offset(10)
            make.left.equalTo(mSettingBattery!).offset(60)
            make.height.equalTo(30)
            make.width.equalTo(30)
        }
        
        //设备名
        mSettingName = UILabel()
        mSettingName!.text = ""
        mSettingName!.font = UIFont(name: "Helvetica", size: 20)
        topView!.addSubview(mSettingName!)
        
        mSettingName!.snp.makeConstraints{
            (make)->Void in
            make.top.equalTo(topView!).offset(20)
            make.right.equalTo(topView!).offset(-20)
        }

        //温度
        tempText = UILabel()
        tempText!.text = "xxx"
        tempText?.font = UIFont(name: "Helvetica-Bold", size:39)
        
        topView!.addSubview(tempText!)
        
        tempText!.snp.makeConstraints{
            (make)->Void in
            make.center.equalTo(topView!)
       
        }
        
        //符号
        mSettingUnit = UILabel()
        mSettingUnit!.text = "°C"
        mSettingUnit!.font = UIFont(name: "Helvetica-Bold", size: 20)
        
        topView!.addSubview(mSettingUnit!)
        
        mSettingUnit!.snp.makeConstraints{
            (make)->Void in
            make.left.equalTo(tempText!).offset(90)
            make.top.equalTo(tempText!).offset(28)
        }
  
        //mac
        mSettingMac = UILabel()
        mSettingMac!.text = "336636"
        mSettingMac!.font = UIFont(name: "Helvetica", size: 18)
        
        topView!.addSubview(mSettingMac!)
        
        mSettingMac!.snp.makeConstraints{
            (make)->Void in
            make.bottom.equalTo(topView!).offset(-10)
            make.left.equalTo(topView!).offset(30)
       
        }
        
        
        //第二段布局
        conView = UIView()
        contentView.addSubview(conView!)
        
        conView!.snp.makeConstraints{
            (make)->Void in
            make.top.equalTo(self).offset(0)
            make.left.equalTo(self).offset(0)
            make.right.equalTo(self).offset(0)
            make.height.equalTo(60)
        }
        
        let viewb = UIView()
        viewb.backgroundColor = allExpanded.listLineAdaptation()
        conView!.addSubview(viewb)
        
        viewb.snp.makeConstraints{
            (make)->Void in
            make.top.equalTo(conView!).offset(61)
            make.left.equalTo(self).offset(5)
            make.right.equalTo(self).offset(-5)
            make.height.equalTo(1)
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
        
        mRightTextLb = UILabel()
        mRightTextLb?.font = UIFont(name: "Helvetica", size: 18)
        mRightTextLb?.isHidden = true
        conView?.addSubview(mRightTextLb!)
        
        mRightTextLb!.snp.makeConstraints { make in
            make.centerY.equalTo(conView!)
            make.right.equalTo(conView!).offset(-20)
            make.height.equalTo(25)
        }
        
        mRightSwitch = UISwitch()
        mRightSwitch?.isHidden = true
        conView?.addSubview(mRightSwitch!)
        mRightSwitch!.snp.makeConstraints { make in
            make.centerY.equalTo(conView!)
            make.right.equalTo(conView!).offset(-36)
            make.height.equalTo(25)
        }
        
        mRightUnitSwitch = UISwitch()
        mRightUnitSwitch?.isHidden = true
        conView?.addSubview(mRightUnitSwitch!)
        mRightUnitSwitch!.snp.makeConstraints { make in
            make.centerY.equalTo(conView!)
            make.right.equalTo(conView!).offset(-36)
            make.height.equalTo(25)
        }
        
        mRightUnitButton = UIButton()
        mRightUnitButton!.isHidden = true
        mRightUnitButton?.setImage(UIImage(named: "off"), for: .normal)
        conView?.addSubview(mRightUnitButton!)
        
        mRightUnitButton!.snp.makeConstraints{
            (make)->Void in
            make.centerY.equalTo(conView!)
            make.right.equalTo(conView!).offset(-28)
           
        }
        
        mSettingUnitLift = UILabel()
        mSettingUnitLift = UILabel()
        mSettingUnitLift!.text = "°C"
        mSettingUnitLift?.font = UIFont(name: "Helvetica", size: 13)
        conView?.addSubview(mSettingUnitLift!)
        mSettingUnitLift!.snp.makeConstraints { make in
            make.centerY.equalTo(conView!)
             make.right.equalTo(mRightUnitSwitch!.snp.left).offset(-10) // 设置右侧边缘与开关左侧边缘之间的间距
             make.height.equalTo(25)
        }
        
        mRightSwitchText = UILabel()
        mRightSwitchText!.text = "°F"
        mRightSwitchText?.isHidden = true
        mRightSwitchText?.font = UIFont(name: "Helvetica", size: 13)
        conView?.addSubview(mRightSwitchText!)
        mRightSwitchText!.snp.makeConstraints { make in
            make.centerY.equalTo(conView!)
            make.right.equalTo(conView!).offset(-5)
            make.height.equalTo(25)
        }
        

        
        mRightSwitch!.addTarget(self, action: #selector(onTempSwitchAction(_:)), for: .valueChanged)
        mRightUnitSwitch!.addTarget(self, action: #selector(onTempUnitSwitchAction(_:)), for: .valueChanged)
        
       
        //创建点击图片
        mRightUnitButton!.addTarget(self, action: #selector(handleRightUnitButtonTap), for: .touchUpInside)
    }
    
    @objc func onTempSwitchAction(_ sender:UISwitch){
        if delegate != nil {
            delegate!.onTempRecordSwClick(sender: sender)
        }
    }
    
    // 在图片按钮的点击事件处理方法中调用代理方法
    @objc func handleRightUnitButtonTap() {
        if delegate != nil {
            delegate?.didTapRightUnitButton()
        }
    }
    
    @objc func onTempUnitSwitchAction(_ sender:UISwitch){
        if delegate != nil {
            delegate!.onTempUnitRecordSwClick(sender: sender)
        }
    }
    
    // 更新Cell的数据
    func updateData(_ data: Any) {
        // 更新各个子视图的数据
        // ...
    }
    
}
