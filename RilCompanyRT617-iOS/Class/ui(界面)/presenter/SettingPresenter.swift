//
//  SettingPresenter.swift
//  RilCompanyRT617-iOS
//
//  Created by RND on 2023/8/25.
//

import UIKit

class SettingPresenter: NSObject {
    
    func getRecordTimes()->[TimeModel]{
        
        var array = [TimeModel]()
        
        var model1 = TimeModel()
        model1.time = "5"
        array.append(model1)
        
       
        var model2 = TimeModel()
        model2.time = "10"
        array.append(model2)
        
        
        var model3 = TimeModel()
        model3.time = "30"
        array.append(model3)
        
        
        var model4 = TimeModel()
        model4.time = "60"
        array.append(model4)
           
        return array
    }
    
    func getSmapleTimes()->[TimeModel]{
        
        var array = [TimeModel]()
        
        var model1 = TimeModel()
        model1.time = "2"
        array.append(model1)
        
       
        var model2 = TimeModel()
        model2.time = "5"
        array.append(model2)
        
        
        var model3 = TimeModel()
        model3.time = "10"
        array.append(model3)
        
        
        var model4 = TimeModel()
        model4.time = "30"
        array.append(model4)
        
        var model5 = TimeModel()
        model4.time = "60"
        array.append(model4)
        
        var model6 = TimeModel()
        model4.time = "600"
        array.append(model4)
           
        return array
    }
    
    
    
}
