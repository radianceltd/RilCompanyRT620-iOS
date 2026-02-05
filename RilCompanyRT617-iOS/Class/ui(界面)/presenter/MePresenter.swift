//
//  MePresenter.swift
//  TMW041RT
//
//  Created by RND on 2023/3/22.
//

import UIKit

struct MePresenter {
    
    func getNames()->Array<String>{
        return ["Version","Clean cach","About me"]
    }
    
    func getImages()->Array<String>{
        return ["update","clear","about"]
    }
    
    func getCurrentVersion() -> String? {
        var version: String? = nil
        //得到当前的版本
        let infoDictionary = Bundle.main.infoDictionary
        let app_Version = infoDictionary?["CFBundleShortVersionString"] as? String
        version = app_Version
        let appCurVersionNum = infoDictionary?["CFBundleVersion"] as? String
        let all = "\(app_Version ?? "") \(appCurVersionNum ?? "")"
        version = all
        return version
    }
}
