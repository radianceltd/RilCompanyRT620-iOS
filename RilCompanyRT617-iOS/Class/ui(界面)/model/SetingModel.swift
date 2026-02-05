//
//  SetingModel.swift
//  TMW041RT
//
//  Created by RND on 2023/5/17.
//

import UIKit

struct SetingModel {
    
//    func getNames()->Array<String>{
//        return ["Temp Sampling","Temp Record","Temp Record Switch","SD-File Instruct","Set DateTime","Query DeviceState","Query Application Version","OTA Upgrade","Ble Instruct","Interval Parameter"]
//    }
//
//
//    func getImages()->Array<String>{
//        return ["tempSampling","tempRecord","fileTime","fileTime","dateTime","queryDevice","queryDeviceVersion","fileCodeUpdate","ble_instruct","interval_parameter"]
//    }
    
    func getNames()->Array<String>{
        return ["Temp sampling","Temp record","Temp record switch","Set °C/°F","PDF-File","CSV-File","Set datetime","Ota upgrade"]
    }
    
    
    func getImages()->Array<String>{
        return ["tempSampling","tempRecord","fileTime","tempCF","pdf","csv","dateTime","fileCodeUpdate"]
    }
    
    func getMinute()->Array<String> {
        return ["2",
                "5",
                "10",
                "30",
                "60",
                "600"]
    }
    
    func getRecord()->Array<String> {
        return ["5",
                "10",
                "30",
                "60"]
    }
    
    
    func getRecordTimes()->[TimeModel]{
        
        var array = [TimeModel]()
        
        var model1 = TimeModel()
        model1.time = "5"
        model1.index = 0x00
        array.append(model1)
        
       
        var model2 = TimeModel()
        model2.time = "10"
        model2.index = 0x01
        array.append(model2)
        
        
        var model3 = TimeModel()
        model3.time = "30"
        model3.index = 0x02
        array.append(model3)
        
        
        var model4 = TimeModel()
        model4.time = "60"
        model4.index = 0x03
        array.append(model4)
           
        return array
    }
    
    func getSmapleTimes()->[TimeModel]{
        
        var array = [TimeModel]()
        
        var model1 = TimeModel()
        model1.time = "2"
        model1.index = 0x00
        array.append(model1)
        
       
        var model2 = TimeModel()
        model2.time = "5"
        model2.index = 0x01
        array.append(model2)
        
        
        var model3 = TimeModel()
        model3.time = "10"
        model3.index = 0x02
        array.append(model3)
        
        
        var model4 = TimeModel()
        model4.time = "30"
        model4.index = 0x03
        array.append(model4)
        
        var model5 = TimeModel()
        model5.time = "60"
        model5.index = 0x04
        array.append(model5)
        
        var model6 = TimeModel()
        model6.time = "600"
        model6.index = 0x05
        array.append(model6)
           
        return array
    }
    
}
