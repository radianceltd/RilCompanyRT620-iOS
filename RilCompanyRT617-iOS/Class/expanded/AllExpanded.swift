//
//  AllExpanded.swift
//  TMW041RT
//
//  Created by RND on 2023/3/22.
//

import UIKit
import SwiftEventBus
import WHToast

struct CommonUtil {
    
    // 摄氏度转为华氏度
    
    func convertCelcius(toFahren celcius: Float) -> Float {
        return celcius * 1.8 + 32
    }
    
    
    // 华氏度转换为摄氏度
    func convertFahrenheit(toCelcius fahrenheit: Float) -> Float {
        return (fahrenheit - 32) / 1.8
    }
    
    //模型数组去重的方法
    func handleFilterArray(arr:[TempModel]) -> [TempModel] {
        var temp = [TempModel]()  //存放符合条件的model
        var idxArr = [Int]()   //存放符合条件model的aID，用来判断是否重复
        for model in arr {
            let index = model.time   //遍历获得model的唯一标识aID
            if !idxArr.contains(index){    //如果该aID已经添加过，则不再添加
                idxArr.append(index)
                temp.append(model)    //如果该aID没有添加过，则添加到temp数组中
            }
        }
        return temp    //最终返回的数组中已经筛选掉重复aID的model
    }
    
    func convertString(to string: String?) -> String? {
        if string == nil || (string?.count ?? 0) == 0 {
            return ""
        }
        let data = string?.components(separatedBy: ":")
        let mop = "\(data?[0] ?? "")\(data?[1] ?? "")\(data?[2] ?? "")\(data?[3] ?? "")\(data?[4] ?? "")\(data?[5] ?? "")"
        let upper = mop.uppercased()
        return "S/N:\(upper)"
    }
    
    //NsNumber转为String类型
    func convertNumberToString(time: NSNumber)->String?{
        let number = NSNumber(value: Int(truncating: time)/1000)
        let date = Date(timeIntervalSince1970: TimeInterval(truncating: number))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/YYYY"
        return dateFormatter.string(from: date)
    }
    
    func date(fromLongLong msSince1970: Int) -> Date? {
        return Date(timeIntervalSince1970: TimeInterval(msSince1970))
    }
    
    //时间的转换
    func string(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter.string(from: date)
    }
    
    //判断温度范围
    func isTempScope(temp: String , unit:String) -> String? {
        var tempv: String?
        if let floatValue = Float(temp) {
            if floatValue > 70.0 {
                tempv = "HHH"
            } else if floatValue < -45.0 {
                tempv = "LLL"
            } else {
                if unit == "°F"{
                    let fahrenheit = convertCelcius(toFahren: floatValue)
                    tempv = String(format: "%.1f", fahrenheit)
                }else{
                    tempv = temp
                }
               
            }
        } else {
            // 处理无法将字符串转换为浮点数的情况
            tempv = nil
        }
        return tempv
    }
    
}

extension UIDevice {
    public var iPhoneXMore: Bool {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.windows[0]
            if window.safeAreaInsets.bottom > 0.0 {
                return true
            }
        }
        return false
    }
}

class AllExpanded{
    
    var model:BleModel?
    
    //查询设备数据
    func queryDeviceData(ins: UInt8, len: UInt8) -> Data{
        
        var packet = Data()
        packet.append(ins)
        packet.append(len)
        let crc = packet.reduce(0, { $0 &+ $1 }) & 0xFF ^ 0xFF
        packet.append(UInt8(crc))
        return packet
        
    }
    
    func queryDeviceData(ins: UInt8, len: UInt8, inssub: UInt8, data: [UInt8] = []) -> Data {
        var packet = Data()
        packet.append(ins)
        packet.append(len)
        packet.append(inssub)
        
        // 如果有数据，添加到包中
        if !data.isEmpty {
            packet.append(contentsOf: data)
        }
        
        // 计算CRC校验
        let crc = packet.reduce(0, { $0 &+ $1 }) & 0xFF ^ 0xFF
        packet.append(UInt8(crc))
        return packet
    }
    
    //查询SD文件
    func queryDeviceData(ins: UInt8, len: UInt8,inssub:UInt8) -> Data{
        
        var packet = Data()
        packet.append(ins)
        packet.append(len)
        packet.append(inssub)
        let crc = packet.reduce(0, { $0 &+ $1 }) & 0xFF ^ 0xFF
        packet.append(UInt8(crc))
        return packet
    }
    
    //无文件通知
    func noFileNotice(ins: UInt8, len: UInt8,inssub:UInt8,fsnn:UInt8) -> Data{
        
        var packet = Data()
        packet.append(ins)
        packet.append(len)
        packet.append(inssub)
        packet.append(fsnn)
        let crc = packet.reduce(0, { $0 &+ $1 }) & 0xFF ^ 0xFF
        packet.append(UInt8(crc))
        return packet
    }
    
    func combineData(ins: UInt8, len: UInt8, inssub: UInt8, data: [UInt8]) -> Data {
        var packet = Data()
        packet.append(ins)
        packet.append(len)
        packet.append(inssub)
        packet.append(0x00)
        packet.append(contentsOf: data)
        let crc = packet.reduce(0, { $0 &+ $1 }) & 0xFF ^ 0xFF
        packet.append(UInt8(crc))
        return packet
    }
    
    //    func buildInstructIntPacket(ins: UInt8, len: UInt8, data: [Int]) -> Data {
    //        var packet = Data()
    //        packet.append(ins)
    //        packet.append(len)
    //       // packet.append(contentsOf: data)
    //        let crc = packet.reduce(0, { $0 &+ $1 }) & 0xFF ^ 0xFF
    //        packet.append(UInt8(crc))
    //        return packet
    //    }
    // 根据指令格式构建数据包
    func buildInstructionPacket(ins: UInt8, len: UInt8, data: [UInt8]) -> Data {
        var packet = Data()
        packet.append(ins)
        packet.append(len)
        packet.append(contentsOf: data)
        let crc = packet.reduce(0, { $0 &+ $1 }) & 0xFF ^ 0xFF
        packet.append(UInt8(crc))
        return packet
    }
    
    // 将 Data 转换为十六进制字符串
    func hexadecimalString(from data: Data) -> String {
        return data.map { String(format: "%02X", $0) }.joined()
    }
    
    //设定时间
    func setDateTime(minute: UInt8, hour: UInt8, day: UInt8, month: UInt8, year: UInt8){
        let INS: UInt8 = 0x04
        let LEN: UInt8 = 5
        
        var data: [UInt8] = [minute,hour]
        data.append(minute)
        data.append(hour)
        data.append(day)
        data.append(month)
        data.append(year)
        
        let command = [INS, LEN] + data
        
        //转换为int类型数值
        let intValue = command.reduce(0, { $0 << 8 + UInt32($1) })
        // 将command发送给设备
        //        var packet = Data()
        //        packet.append(ins)
        //        packet.append(len)
        //        packet.append(contentsOf: data)
        //        let crc = packet.reduce(0, { $0 &+ $1 }) & 0xFF ^ 0xFF
        //        packet.append(UInt8(crc))
        //        return packet
        // return Int(intValue)
        //sendCommandToDevice(command)
        //BleManager.shared.writeData("lb", for: model?.sendTimeDataCharater, periperalData: model?.mPeripheral)
    }
    
    //深夜暗黑模式适配方法(背景颜色)
    func nightModelAdaptation() -> UIColor{
        if #available(iOS 13.0, *) {
            let nightColor = UIColor.init { (trainCollection) -> UIColor in
                if trainCollection.userInterfaceStyle == .dark {
                    return UIColor(hexString: "#130c0e", transparency: 1.0)
                }else{
                    return UIColor(hexString: "#F5F5F5", transparency: 1.0)
                }
            }
            return nightColor
        } else {
            return UIColor(hexString: "#F5F5F5", transparency: 1.0)
        }
    }
    
    //白天暗黑模式适配方法(文本颜色)
    func dayTimeModelAdaptation() -> UIColor{
        if #available(iOS 13.0, *) {
            let dayTimeColor = UIColor.init { (trainCollection) -> UIColor in
                if trainCollection.userInterfaceStyle == .light {
                    return UIColor(hexString: "#130c0e", transparency: 1.0)
                }else{
                    return UIColor(hexString: "#F5F5F5", transparency: 1.0)
                }
            }
            return dayTimeColor
        } else {
            return UIColor(hexString: "#130c0e", transparency: 1.0)
        }
    }
    
    //列表的线条颜色判断
    func listLineAdaptation() -> UIColor{
        if #available(iOS 13.0, *) {
            let dayTimeColor = UIColor.init { (trainCollection) -> UIColor in
                if trainCollection.userInterfaceStyle == .light {
                    return UIColor(hexString: "#efefef", transparency: 1.0)
                }else{
                    return UIColor(hexString: "#dcdcdc", transparency: 1.0)
                }
            }
            return dayTimeColor
        } else {
            return UIColor(hexString: "#efefef", transparency: 1.0)
        }
    }
    
    
    /**
     自己写的解析文件名称的数据方法
     @author Ardwang
     @date 2023/8/21
     
     数据格式如下：
     
     [3, 177, 0, 0, 6, 207, 0, 0, 48, 49, 45, 48, 49, 45, 50, 51, 68, 80, 50, 51, 56, 56, 57, 54, 51, 40, 48, 41, 46, 112, 100, 102, 0, 6, 207, 0, 0, 48, 49, 45, 48, 49, 45, 50, 51, 68, 80, 50, 51, 56, 56, 57, 54, 51, 40, 49, 41, 46, 112, 100, 102, 0, 6, 207, 0, 0, 48, 49, 45, 48, 49, 45, 50, 51, 68, 80, 50, 51, 56, 56, 57, 54, 51, 40, 49, 48, 41, 46, 112, 100, 102, 0, 6, 207, 0, 0, 48, 49, 45, 48, 49, 45, 50, 51, 68, 80, 50, 51, 56, 56, 57, 54, 51, 40, 49, 49, 41, 46, 112, 100, 102, 0, 6, 207, 0, 0, 48, 49, 45, 48, 49, 45, 50, 51, 68, 80, 50, 51, 56, 56, 57, 54, 51, 40, 50, 41, 46, 112, 100, 102, 0, 157, 207, 0, 0, 48, 49, 45, 48, 49, 45, 50, 51, 68, 80, 50, 51, 56, 56, 57, 54, 51, 40, 51, 41, 46, 112, 100, 102]
     
     */
    
    //文件数据块解析
    func parseFileData(data: [UInt8]) -> ReadModel? {
        guard data.count > 0 else {
            return nil
        }
        
        let model = ReadModel()
        
        var charData: [[String]] = []
        var currentData: [UInt8] = []
        
        for num in data {
            if num == 44 || num == 13{ // ASCII码为逗号 ","
                let char = String(bytes: currentData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
                if let char = char {
                    currentData = []
                    charData.append([char])
                }
            } else {
                currentData.append(num)
            }
        }
        
        if charData.count < 4 {
            return nil
        }
        
        var result: [Read] = []

        for index in stride(from: 0, to: charData.count / 4, by: 1) {
            let read = Read()
            read.fileData = charData[index * 4][0]
            read.fileTime = charData[(index * 4) + 1][0]
            read.fileTemp1 = charData[(index * 4) + 2][0]
            read.fileTemp2 = charData[(index * 4) + 3][0]
            
            result.append(read)
        }
        
        model.list = result
        
        return model
    }
    
    
    //            let startIndex = i == 0 ? 3 : indexArray[i - 1] + subArray.count
    //            let endIndex = indexArray[i] + subArray.count - 1
    //            //print("start:\(startIndex) end:\(endIndex)")
    //
    //            let temps = [UInt8](data[startIndex...endIndex])
    //            return temps
    func parseFileData(_ data: [UInt8],_ subArray:[UInt8]) -> ReadModel {
        
        let model = ReadModel()
        
        // 数据类型如 0x03
        let dataType = Int(data[0])
        let len = Int(data[1])
      
        model.type = Int(dataType)
        model.legth = Int(len)
        
        let subArray: [UInt8] = subArray // ".pdf"
        
        let indexArray = data.indices(of: subArray)
        
        let newArray: [[UInt8]] = indexArray.indices.map { i in
            let startIndex = i == 0 ? 3 : indexArray[i - 1] + subArray.count
            let endIndex = indexArray[i] + subArray.count - 1
            let temps = [UInt8](data[startIndex...endIndex])
            return temps
        }
        
        // 截取的字段 末位
        for (i, item) in newArray.enumerated() {
            var suffixLength = 4 // 默认截取长度为4
            if i == 0 {
                suffixLength = 5 // 第一组文件名截取长度为5
            }
            
            let remaining = Array(item.suffix(from: suffixLength))
            let asciiString = String(decoding: remaining, as: UTF8.self)
            //let fileSizeBytes = data[startIndex-4..<startIndex]
            
            
            // 去除开头的 "._"
            if !asciiString.hasPrefix("._") {
                let read = Read()
                read.fileName = asciiString
                model.list.append(read)
            }
        }
        
        
        return model
    }
    
    
    func parseFileData1(_ data: [UInt8], _ subArray: [UInt8]) -> ReadModel {
        let model = ReadModel()
        
        // 解析数据类型和长度
        let dataType = Int(data[0])
        let len = Int(data[1])
        model.type = dataType
        //model.length = len
        
        let subArray: [UInt8] = subArray // 文件名后缀，例如 ".pdf"
        
        let indexArray = data.indices(of: subArray)
        
        let newArray: [[UInt8]] = indexArray.indices.map { i in
            let startIndex = i == 0 ? 3 : indexArray[i - 1] + subArray.count
            let endIndex = indexArray[i] + subArray.count - 1
            let temps = data[startIndex...endIndex]
            return Array(temps)
        }
        
        // 解析文件名和文件大小
        for (i, item) in newArray.enumerated() {
            var suffixLength = 4 // 默认截取长度为4
            if i == 0 {
                suffixLength = 5 // 第一组文件名截取长度为5
            }
            
            let remaining = Array(item.suffix(from: suffixLength))
            let asciiString = String(bytes: remaining, encoding: .utf8)
            
            // 去除开头的 "._"
            if !asciiString!.hasPrefix("._") {
                //let fileNameBytes = Array(item[0..<suffixLength])
                let fileSizeBytes = Array(item[(suffixLength-4)..<suffixLength])
                
                let fileName = asciiString
                let fileSize = byteArrayToLong(fileSizeBytes)
                
                let read = Read()
                read.fileName = fileName
                read.fileSize = UInt64(Int(fileSize))
                
                model.list.append(read)
            }
        }
        
        return model
    }
    
    //解析pdf文件和csv列表
    func parseFileNameData2(data: [UInt8], subArray: [UInt8]) -> ReadModel {
        let model = ReadModel()
        var indexArray = [Int]()
        var currentIndex = 0

        while currentIndex <= data.count - subArray.count {
            var isMatched = true
            for i in 0..<subArray.count {
                if subArray[i] != data[currentIndex + i] {
                    isMatched = false
                    break
                }
            }
            if isMatched {
                indexArray.append(currentIndex)
                currentIndex += subArray.count
            } else {
                currentIndex += 1
            }
        }

        for i in 0..<indexArray.count {
            let startIndex = (i == 0) ? 4 : indexArray[i - 1] + subArray.count + 4
            let endIndex = indexArray[i] + subArray.count - 1
            let temps = Array(data[startIndex...endIndex])
            if let asciiString = String(bytes: temps, encoding: .utf8) {
                let fileSizeBytes = Array(data[startIndex-4..<startIndex])
                
                if !asciiString.contains("._") {
                    let hidden = hideSpecialCharacters(input: asciiString)
                    let read = Read()
                    read.fileName = hidden
                    let fileSize = byteArrayToLong(fileSizeBytes)
                    read.fileSize = fileSize
                    model.list.append(read)
                }
            }
        }

        return model
    }
    
    private func hideSpecialCharacters(input: String) -> String {
        let regex = try! NSRegularExpression(pattern: "[^\\p{ASCII}]", options: [])
        let range = NSRange(location: 0, length: input.utf16.count)
        return regex.stringByReplacingMatches(in: input, options: [], range: range, withTemplate: "")
    }

    /// 获取fileSize大小
    func byteArrayToLong(_ bytes: [UInt8]) -> UInt64 {
        var value: UInt64 = 0
        for (i, byte) in bytes.enumerated() {
            value |= UInt64(byte) << (8 * i)
        }
        return value
    }

    // 创建文件夹并将数据写入 CSV 文件
    func createCSVAndWriteData(data: [UInt8], fileName: String) -> String?{
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let folderURL = documentsURL.appendingPathComponent("CSV")
        let fileURL = folderURL.appendingPathComponent(fileName)
        
        let csvString = String(data: Data(data), encoding: .utf8)
        
        // 将 UInt8 数据转换为 Base64 编码的字符串
        //let base64String = Data(data).base64EncodedString()
        //let csvString = "\(base64String)\n"
        if csvString != ""{
            do {
                try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
                try csvString?.write(to: fileURL, atomically: true, encoding: .utf8)
                print("CSV 文件夹创建成功，并成功将数据写入 CSV 文件")
                return csvString
            } catch {
                print("创建 CSV 文件夹失败或将数据写入 CSV 文件失败：\(error)")
                return nil
            }
        }else{
            print("创建 CSV 文件夹失败或将数据写入 CSV 文件失败")
            return nil
        }
        
    }
}


extension UIColor{
    
    convenience init(hexString: String,transparency: CGFloat = 1.0) {
        let hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        var trans = transparency
        if trans < 0.0 { trans = 0.0 }
        if trans > 1.0 { trans = 1.0 }
        
        self.init(red: red, green: green, blue: blue, alpha: trans)
    }
    
    // UIColor -> Hex String
    var hexString: String? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        let multiplier = CGFloat(255.999999)
        
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
        
        if alpha == 1.0 {
            return String(
                format: "#%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier)
            )
        }
        else {
            return String(
                format: "#%02lX%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier),
                Int(alpha * multiplier)
            )
        }
    }
    
    
}


extension Array where Element: Equatable {
    func indices(of subArray: [Element]) -> [Int] {
        var indices: [Int] = []
        var currentIndex = 0
        
        while currentIndex < count {
            if self[currentIndex] == subArray.first {
                var found = true
                
                for i in 0..<subArray.count {
                    if currentIndex + i >= count || self[currentIndex + i] != subArray[i] {
                        found = false
                        break
                    }
                }
                
                if found {
                    indices.append(currentIndex)
                    currentIndex += subArray.count
                    continue
                }
            }
            
            currentIndex += 1
        }
        
        return indices
    }
}


