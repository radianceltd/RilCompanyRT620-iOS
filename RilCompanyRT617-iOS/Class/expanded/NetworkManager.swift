//
//  NetworkManager.swift
//  RilCompanyRT617-iOS
//
//  Created by RND on 2023/12/13.
//

import Alamofire
import WHToast

class NetworkManager{
    
    static let shared = NetworkManager()
    
    private var reachabilityManager: NetworkReachabilityManager?
    
    private init() {
        self.reachabilityManager = NetworkReachabilityManager()
        self.reachabilityManager?.startListening(onUpdatePerforming: { status in
            // 处理网络状态的变化
            // 示例：self.handleNetworkStatus(status)
        })
    }
    
    func isNetworkReachable() -> Bool {
        return reachabilityManager?.isReachable ?? false
    }
    
    func checkAppStoreVersion(from viewController: UIViewController,isVersionBool:Bool) {
        if isNetworkReachable() {
            // 进行版本号检测
            appStoreCheck(from: viewController, versionBool: isVersionBool)
        } else {
            WHToast.showMessage("无网络连接!", originY: 500, duration: 2, finishHandler: {})
        }
    }
    
    func appStoreCheck(from viewController: UIViewController,versionBool:Bool) {
        let dict = ["id": "6473766555"]
        let session = Session.default
        
        session.request("http://itunes.apple.com/cn/lookup?", method: .get, parameters: dict)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any],
                       let results = json["results"] as? [[String: Any]],
                       let version = results[0]["version"] as? String {
                        print("请求成功---\(version)")
                        
                        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
                        let arr = appVersion.components(separatedBy: ".")
                        print("获取app的版本号：\(arr[2])")
                        
                        let newString = "\(version)"
                        let arr1 = newString.components(separatedBy: ".")
                        print("获取appstore的版本号：\(arr1[2])")
                        
                        UserDefaults.standard.set(newString, forKey: "name")
                        UserDefaults.standard.synchronize()
                        
                        if arr[2] != arr1[2] || arr[1] != arr1[1] || arr[0] != arr1[0] {
                            CommonDefaults.shared.saveValue("true", forKey: VERSION)
                            //有更新的版本
                            if versionBool{
                                let alert = UIAlertController(title: "Version update", message: "With the latest version of APP released, please go to the Apple App store for updates.!", preferredStyle: .alert)
                                
                                let defaultAction = UIAlertAction(title: "Update", style: .default) { action in
                                    let str = "itms-apps://itunes.apple.com/cn/app/id6473766555?mt=8"
                                    if let url = URL(string: str) {
                                        UIApplication.shared.open(url)
                                    }
                                }
                                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                                
                                alert.addAction(defaultAction)
                                alert.addAction(cancelAction)
                                
                                // 弹出UIAlertController
                                viewController.present(alert, animated: true, completion: nil)
                                
                            }else{
                                // 这个判断arr和arr之间的差数是奇数还是偶数
                                //APP的版本
                                let compactedAppVersion = Int(appVersion.replacingOccurrences(of: ".", with: "")) ?? 0
                                //APP Store中心发布成功的版本
                                let compactedNewString = Int(newString.replacingOccurrences(of: ".", with: "")) ?? 0
                                
                                let diff = abs(compactedNewString - compactedAppVersion)
                                
                                if diff % 2 == 0 {
                                    CommonDefaults.shared.saveValue("EVEN", forKey: BLE_EVEN_ODD)
                                } else {
                                    CommonDefaults.shared.saveValue("ODD", forKey: BLE_EVEN_ODD)
                                }
                                
                            }
                            
                        } else {
                            CommonDefaults.shared.saveValue("false", forKey: VERSION)
                            if versionBool{
                                WHToast.showMessage("It's the latest version.", originY: 500, duration: 2, finishHandler: {
                                })
                            }
                            
                        }
                    }
                case .failure(let error):
                    print("请求失败,服务器返回的错误信息\(error)")
                }
            }
    }
    
}
