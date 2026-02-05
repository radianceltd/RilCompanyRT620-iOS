//
//  AppDelegate.swift
//  RilCompanyRT617-iOS
//
//  Created by RND on 2023/6/27.
//

import UIKit
import CoreData
import WHToast

protocol AppDelegateDelegate: AnyObject {
    func applicationWillResignActive()
    func applicationDidBecomeActive()
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let networkManager = NetworkManager.shared
    weak var delegate: AppDelegateDelegate?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // 判断版本号
         isNetWorkState()
        // 从初始化跳转界面到蓝牙设备
        window = UIWindow(frame: UIScreen.main.bounds)
        let device = BleDeviceController()

        let navigation = UINavigationController(rootViewController: device)
        self.window?.rootViewController = navigation
 
        Thread.sleep(forTimeInterval: 3.0)
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        delegate?.applicationWillResignActive()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        delegate?.applicationDidBecomeActive()
    }
    
    // 判断版本号
        func isNetWorkState() {
            //判断是否有网
            if networkManager.isNetworkReachable() {
                // Pass the root view controller of the navigation controller
                networkManager.checkAppStoreVersion(from: (window?.rootViewController)!, isVersionBool: false)
            } else {
                WHToast.showMessage("无网络连接!", originY: 500, duration: 2, finishHandler: {})
            }
        }
}
