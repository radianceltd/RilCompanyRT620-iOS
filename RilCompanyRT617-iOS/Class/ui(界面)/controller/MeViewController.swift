//
//  MeViewController.swift
//  TMW041RT
//
//  Created by RND on 2023/3/22.
//

import UIKit
import WHToast

class MeViewController:NavigationController,MeCellProtocol,UITableViewDelegate,UITableViewDataSource{
    
    let MEVIEWCONTROLLERDATACELL = "MEVIEWCONTROLLERDATACELL"
    
    private var mNames:Array<String>?
    
    private var mImages:Array<String>?
    
    private let meView = MeView()
    
    private let meCell = MeCell()
    
    private let mePresenter = MePresenter()
    
    let networkManager = NetworkManager.shared
    
    var isVersion:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //导航栏部分
        aboutNavigationCenter(title: "Me")
        aboutNavigationLeft(isBack: false)
        
        isVersion = CommonDefaults.shared.getValue(VERSION)

    }
    
    override func initView() {
        
        let view = UIView()
        meCell.delegate = self
        meView.tableView?.delegate = self
        meView.tableView?.dataSource = self
        meView.tableView?.tableFooterView = view
        meView.frame = self.view.bounds
        self.view.addSubview(meView)
        
    }
    
    override func initData() {
        
        mNames = mePresenter.getNames()
        mImages = mePresenter.getImages()
        
    }
    
    func onUnitAction(_ sender: UISwitch?) {
        print("my name is text data")
    }
    
    /// TableView代理模块
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 155
        } else if indexPath.section == 1 {
            return 65
        } else {
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (section==0) {
            return 1
        }else if(section==1){
            return 3
        }
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 尝试从重用池中取出一个MeCell，如果没有则创建一个新的MeCell
        var cell = tableView.dequeueReusableCell(withIdentifier: MEVIEWCONTROLLERDATACELL) as? MeCell
        if cell == nil {
            cell = MeCell(style: .default, reuseIdentifier: MEVIEWCONTROLLERDATACELL)
            cell!.selectionStyle = .none
        }
        
        // 根据indexPath.section的值不同，设置cell的不同属性
        switch indexPath.section {
        case 0:
            cell?.topView?.isHidden = false
            cell?.conView?.isHidden = true
            cell?.conViewSwitch?.isHidden = true
        case 1:
            cell?.topView?.isHidden = true
            cell?.conView?.isHidden = false
            cell?.rightImage?.isHidden = true
            cell?.redImage?.isHidden = true
            
            // 根据indexPath.row的值不同，设置cell的不同属性
            switch indexPath.row {
            case 0:
                cell?.conTimeLb?.isHidden = false
                cell?.conTimeLb?.text = mePresenter.getCurrentVersion()
                if isVersion == "true"{
                    cell?.redImage?.isHidden = false
                }
            case 1:
                cell?.conTimeLb?.isHidden = false
                cell?.conTimeLb?.text = ClearCacheTool.getCacheSize()
                //这里需要注释说明一下含义
            case 2:
                cell?.conTimeLb?.isHidden = false
                cell?.rightImage?.isHidden = false
            default:
                break
            }
            
            cell?.mConImage?.image = UIImage(named: mImages?[indexPath.row] ?? "")
            cell?.mConLb?.text = mNames?[indexPath.row]
        default:
            break
        }
        
        return cell!
    }
    
    // 点击
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                print( "0")
                //判断是否有网络
                isNetWorkState()
            case 1:
                print( "1")
                let tips = "Tips"
                let cancel = "Cancel"
                let ok = "Confirm"
                
                let alertController = CleanAlertController(title: tips, message: "Are you sure to clear all locally stored data?", preferredStyle: .alert)
                
                let noAction = UIAlertAction(title: cancel, style: .cancel, handler: { action in
                })
                
                let yesAction = UIAlertAction(title: ok, style: .default, handler: { action in
                    //清除所有数据
                    ClearCacheTool.clearCaches()
                    //刷新
                    self.meView.tableView?.reloadData()
                    WHToast.showMessage("Clear success!", originY: 500, duration: 2, finishHandler: {
                    })
                })
                
                alertController.addAction(noAction)
                alertController.addAction(yesAction)
                present(alertController, animated: true)
            case 2:
                print( "2")
                let about = AboutViewController()
                self.navigationController?.pushViewController(about, animated:true)
            default : /* 可选 */
                print( "meiyouxuanzhel")
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //section头部高度
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }
    
    /*
     设置头部的距离的颜色
     */
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    /*
     设置底部的距离的颜色
     */
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
    
    // 判断版本号
       func isNetWorkState() {
           if networkManager.isNetworkReachable() {
               networkManager.checkAppStoreVersion(from: self, isVersionBool: true)
           } else {
               WHToast.showMessage("无网络连接!", originY: 500, duration: 2, finishHandler: {})
           }
       }

}
