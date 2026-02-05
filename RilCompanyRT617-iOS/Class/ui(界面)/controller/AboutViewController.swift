//
//  AboutViewController.swift
//  TMW041RT
//
//  Created by RND on 2023/3/22.
//

import UIKit

class AboutViewController:NavigationController{
    
    private var aboutView = AboutView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        aboutNavigationLeft(isBack: false)
        aboutNavigationCenter(title: "About")
    }
    
    override func initView() {
        super.initView()
        
        aboutView.frame = self.view.bounds
        self.view.addSubview(aboutView)
        
    }
    
    override func initData() {
        super.initData()
        //调用当前版本
        currentVersion()
    }
    
    func currentVersion(){
        //获取当前的版本
        let infoDictionary = Bundle.main.infoDictionary
        let app_Version = infoDictionary?["CFBundleShortVersionString"] as? String
        let appCurVersionNum = infoDictionary?["CFBundleVersion"] as? String
        let all = "\(app_Version ?? "") \(appCurVersionNum ?? "")"
         
        aboutView.mTopImage?.image = UIImage(named: "temp")
        aboutView.mTopLb?.text = "RT620"
        aboutView.mCompanyLb?.text = "Radiance Instruments Ltd"
        aboutView.mEmailLb?.text = "E-mail:  mkt@radiance-ind.com"
        aboutView.mPhoneLb?.text = "Phone: +852 2466-8608"
        aboutView.mFaxLb?.text = "Fax: +852 8343-1627"
        aboutView.mAddressLb?.text = "Address:  Flat 2002, 20/F, CEO Tower, 77 Wing Hong Street Lai Chi Kok, Kowloon, Hong Kong, China."
        aboutView.mVersionLb?.text = "Current version: \(all)"
    }
    
}
