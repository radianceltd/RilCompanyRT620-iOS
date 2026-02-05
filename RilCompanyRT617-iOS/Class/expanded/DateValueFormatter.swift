//
//  DateValueFormatter.swift
//  RilCompanyRT617-iOS
//
//  Created by RND on 2023/7/3.
//

import UIKit
import Charts

class DateValueFormatter: NSObject,IAxisValueFormatter {
    
    var array = [String]()
    
    init(arr: [String]) {
        super.init()
        self.array = arr
        for str in self.array {
            if !self.array.contains(str) {
                self.array.append(str)
            }
        }
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if array.count > 1 && Int(value) > array.count {
            let dateStr = array[Int(value)]
            return dateStr
        } else {
            let date = Date()
            var ltime = Int(date.timeIntervalSince1970)
            ltime = ltime + Int(value) - 39
            let jk = Date(timeIntervalSince1970: TimeInterval(ltime))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss"
            return dateFormatter.string(from: jk)
        }
    }
}
