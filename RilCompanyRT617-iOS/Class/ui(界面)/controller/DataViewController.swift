//
//  DataViewController.swift
//  RilCompanyRT617-iOS
//
//  Created by RND on 2023/7/3.
//

import UIKit
import WMPageController
import SwiftEventBus
import WHToast

enum SDFileViewPosition : Int {
    case `default`
    case bottom
}

class DataViewController:WMPageController{
    var menuViewPosition: SDFileViewPosition?
    
    var redViewx: UIView?
    
    var position:Int = 0
    
    var tempUnit:String?
    
    var addre:String = "1111"
    
    var model : BleModel?
    
    override func viewDidLoad() { // 600- 92 = 508 + 8*2+3*2+3*8 = 16+6+24
        super.viewDidLoad()
        initView()
        customNavigationLeftItem()
        //customNavigationRightItem()
    }
    
     func initView() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = UIColor.systemBackground
        } else {
            // Fallback on earlier versions
            view.backgroundColor = UIColor.white
        }
        
        progressHeight = 3 //下划线的高度，需要WMMenuViewStyleLine样式
        progressWidth = 35
        menuItemWidth = 25
        menuViewContentMargin = 10
        
        progressViewIsNaughty = true
        menuViewStyle = .line
        titleColorNormal = UIColor.white
        titleColorSelected = UIColor.white //设置选中文字颜色
        progressColor = UIColor.white
        titleSizeSelected = 18 //设置选中文字大小
        titleSizeNormal = 16
        titleFontName = "Helvetica-Bold"
        showOnNavigationBar = true
        scrollEnable = false
        super.viewDidLoad()
        
        if menuViewStyle == .triangle {
            view.addSubview(redView()!)
        }
        
        
        //disconnectEvent 断开蓝牙数据的时候
//        SwiftEventBus.onMainThread(self, name: "disconnectEvent"){
//            result in
//            let modelx = result?.object as! BleModel
//            //类型相当 用 === 去判断
//            if modelx === self.model {
//                //断开返回界面
//                WHToast.showMessage("Device \(modelx.deviceMAC!) disconnect!", originY: 500, duration: 2, finishHandler: nil)
//                //断开界面
//                self.navigationController?.popViewController(animated: true)
//            }else{
//                WHToast.showMessage("Device is disconnect!", originY: 500, duration: 2, finishHandler: nil)
//            }
//        }
    }
    
    //左边
    func customNavigationLeftItem() {
        let item = UIBarButtonItem(image:UIImage(named: "back"), style: .plain, target: self, action: #selector(onBackClick))
        self.navigationItem.leftBarButtonItem = item
    }
    
    //右边
//    func customNavigationRightItem(){
//        let item = UIBarButtonItem(image: UIImage(named: "set"), style: .plain, target: self, action: #selector(onSetClick))
//        item.tintColor = UIColor.white
//        navigationItem.rightBarButtonItem = item
//    }
    
    //返回事件
    @objc func onBackClick(){
        
//        let tips = "Tips"
//        let cancel = "Cancel"
//        let ok = "Confirm"
//
//        let alertController = CleanAlertController(title: tips, message: "Are you sure to disconnect bluetooth?", preferredStyle: .alert)
//
//        let noAction = UIAlertAction(title: cancel, style: .cancel, handler: { action in
//        })
//
//        let yesAction = UIAlertAction(title: ok, style: .default, handler: { [self] action in
//
//            //断开所有的蓝牙
//            //BleManager.shared.disConnectBle()
//           // SwiftEventBus.unregister(self)
//
//            self.navigationController?.popViewController(animated: true)
//            
//        })
//
//        alertController.addAction(noAction)
//        alertController.addAction(yesAction)
//        present(alertController, animated: true)
        SwiftEventBus.unregister(self)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func onSetClick(){
        print("进入设置界面...SetViewController")
        let set = SetingContrller()
        set.model = model;
        set.mac = model?.deviceMAC;
        self.navigationController?.pushViewController(set, animated:true)
    }
    
    func redView() -> UIView? {
        if !(redViewx != nil) {
            redViewx = UIView(frame: CGRect.zero)
            redViewx?.backgroundColor = UIColor(red: 168.0 / 255.0, green: 20.0 / 255.0, blue: 4 / 255.0, alpha: 1)
        }
        return redViewx
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        redView()!.frame = CGRect(x: 0, y: menuView!.frame.maxY, width: view.frame.size.width, height: 2.0)
    }
    
    override func numbersOfChildControllers(in pageController: WMPageController?) -> Int {
        switch menuViewStyle {
        case .flood:
            return 2
        case .segmented:
            return 2
        default:
            return 2
        }
    }
    
    override func pageController(_ pageController: WMPageController?, titleAt index: Int) -> String {
        switch index {
        case 0:
            return "Temp"
        case 1:
            return "Graph"
        default:
            break
        }
        return "NONE"
    }
    
    override func pageController(_ pageController: WMPageController?, viewControllerAt index: Int) -> UIViewController {
        switch index {
        case 0:
            let temp = TempViewController()
            temp.model = model!
            temp.index = position
            temp.tempUnit = tempUnit!
            return temp
        case 1:
            let chart = ChartViewController()
            chart.model = model!
            chart.index = position
            chart.unit = tempUnit!
            return chart
        default:
            break
        }
        return UIViewController()
    }
    
    override func menuView(_ menu: WMMenuView?, widthForItemAt index: Int) -> CGFloat {
        let width = super.menuView(menu, widthForItemAt: index)
        return width + 30
    }
    
    override func pageController(_ pageController: WMPageController?, preferredFrameFor menuView: WMMenuView?) -> CGRect {
        if menuViewPosition == .bottom {
            menuView?.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
            return CGRect(x: 0, y: view.frame.size.height, width: view.frame.size.width, height: 44)
        }
        let leftMargin: CGFloat = showOnNavigationBar ? 50 : 0
        let originY: CGFloat = showOnNavigationBar ? 0 : (navigationController?.navigationBar.frame.maxY)!
        return CGRect(x: leftMargin, y: originY, width: view.frame.size.width - 2 * leftMargin, height: 44)
    }
    
    override func pageController(_ pageController: WMPageController?, preferredFrameForContentView contentView: WMScrollView?) -> CGRect {
        if menuViewPosition == .bottom {
            return CGRect(x: 0, y: 64, width: view.frame.size.width, height: view.frame.size.height)
        }
        var originY = self.pageController(pageController, preferredFrameFor: menuView).maxY
        if menuViewStyle == .triangle {
            originY += redView()!.frame.size.height
        }
        return CGRect(x: 0, y: originY, width: view.frame.size.width, height: view.frame.size.height - originY)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 禁用返回手势
        if navigationController?.responds(to: #selector(getter: UINavigationController.interactivePopGestureRecognizer)) ?? false {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
    }
    
}
