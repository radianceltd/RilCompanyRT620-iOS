//
//  NavigationController.swift
//  TMW041RT
//
//  Created by RND on 2023/3/22.
//

import UIKit
import SwiftEventBus

class NavigationController:UIViewController{
    
    private var deviceValue = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //改变controller的背景颜色
        view.backgroundColor = UIColor.white
        
        //添加头部导航栏中/左侧/右侧
        aboutNavigationCenter(title:"")
        aboutNavigationLeft(isBack: false)
        aboutNavigationRight(isTure:true,isNameImage:"",isNameText:"")
        
        //初始化的方法调用
        initView()
        initData()
    }
    
    func initData(){
        
    }
    
    func initView(){
        
    }
    
    //关于导航栏中心
    func aboutNavigationCenter(title:String){
        
        let commonBlue = UIColor(hexString: "#353535", transparency: 1.0)
        
        //标题字体
        let attributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        
        //如果是IOS系统15以上
        if #available(iOS 15.0, *) {
            let appperance = UINavigationBarAppearance()
            //添加背景色
            appperance.backgroundColor = commonBlue
            appperance.shadowImage = UIImage()
            appperance.shadowColor = nil
            //设置标题字体颜色大小
            appperance.titleTextAttributes = [
                .foregroundColor: UIColor.white
            ]
            navigationController?.navigationBar.standardAppearance = appperance
            navigationController?.navigationBar.scrollEdgeAppearance = appperance
            navigationController?.navigationBar.compactAppearance = appperance
            navigationController?.navigationBar.compactScrollEdgeAppearance = appperance
            
        }
        
        self.navigationController!.navigationBar.barTintColor =  commonBlue
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationItem.title = title
    }
    
    //左侧
    func aboutNavigationLeft(isBack:Bool){
        
        if isBack{
            let item = UIBarButtonItem(image:UIImage(named: "back"), style: .plain, target: self, action: #selector(onBackClick))
            self.navigationItem.leftBarButtonItem = item
        }else{
            let item = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
            item.tintColor = UIColor.white
            self.navigationItem.backBarButtonItem = item
        }
        
    }
    
    //右侧
    func aboutNavigationRight(isTure:Bool,isNameImage:String,isNameText:String){
        //为真就显示图片
        if(isTure){
            deviceValue = isNameImage
            let item = UIBarButtonItem(image: UIImage(named: isNameImage)?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(onToClick))
            item.tintColor = UIColor.white
            navigationItem.rightBarButtonItem = item
        }else{
            deviceValue = isNameText
            let item = UIBarButtonItem(title: isNameText, style: .plain, target: self, action: #selector(onToClick))
            item.tintColor = UIColor.white
            self.navigationItem.rightBarButtonItem = item
        }
    }
    
    @objc func onToClick(){
        print("S/N:",deviceValue)
        
        if(deviceValue == "me_false"){
            
            let me = MeViewController()
            self.navigationController?.pushViewController(me, animated: true)
            
        }else if deviceValue == "set"{
            
            let set = SetingContrller()
            self.navigationController?.pushViewController(set, animated: true)
            
        }else if deviceValue == "me_true"{
            let me = MeViewController()
            self.navigationController?.pushViewController(me, animated: true)
        }
    }
    
    //返回事件
    @objc func onBackClick(){
        
        let tips = "Tips"
        let cancel = "Cancel"
        let ok = "Confirm"
        
        let alertController = CleanAlertController(title: tips, message: "Are you sure to disconnect bluetooth?", preferredStyle: .alert)
        
        let noAction = UIAlertAction(title: cancel, style: .cancel, handler: { action in
        })
        
        let yesAction = UIAlertAction(title: ok, style: .default, handler: { [self] action in
            
            //断开所有的蓝牙
            BleManager.shared.disConnectBle()
            SwiftEventBus.unregister(self)
            
            self.navigationController?.popViewController(animated: true)
            
        })
        
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        present(alertController, animated: true)
    }
    
    func preferredStatusBarStyle() -> UIStatusBarStyle{
        return .lightContent//白色
    }
    
    /*
     * 禁止页面侧面滑动代码
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 禁用返回手势
        if navigationController?.responds(to: #selector(getter: UINavigationController.interactivePopGestureRecognizer)) ?? false {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
    }
}
