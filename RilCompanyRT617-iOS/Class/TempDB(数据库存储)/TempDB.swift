//
//  TempDB.swift
//  RilCompanyRT617-iOS
//
//  Created by RND on 2023/7/3.
//

import UIKit
import FMDB

class TempDB: NSObject {
    
    private var db: FMDatabase!
    
    private let cmUtil = CommonUtil()
    
    static let shared = TempDB()
    
    override init() {
        super.init()
        
        let fileURL = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("rt617.sqlite")
        
        db = FMDatabase(url: fileURL)
        // 创建数据库
        initializeDatabase()
    }
    
    func copy() -> Any? {
        return self
    }
    
    override func mutableCopy() -> Any {
        return self
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
    
    func mutableCopy(with zone: NSZone? = nil) -> Any {
        return self
    }
    
    func initializeDatabase() {
        guard db.open() else {
            print("Unable to open database")
            return
        }
        
        // 重新创建数据库的表
        let wtSql = "CREATE TABLE IF NOT EXISTS RT617(_id integer primary key autoincrement,tmp text,max text,unit text,mac text,bat text,time double);"
        
        do {
            try db.executeUpdate(wtSql, values: nil)
            db.close()
        } catch {
            print("数据库出现了错误，请仔细检查！")
        }
    }
    
    // 存储数据
    func saveTemp(_ tp: TempModel) {
        db.open()
        do {
            let sql = "INSERT INTO RT617(tmp, max, unit, mac, bat, time) VALUES (?, ?, ?, ?, ?, ?)"
            let values: [Any] = [tp.tmp, tp.max, tp.unit, tp.mac, tp.bat, NSNumber(value: tp.time)]
            try db.executeUpdate(sql, values: values)
            db.close()
        } catch {
            print("存储数据出现错误！")
        }
    }
    
    func getFirst50TempList(mac: String?, getBeginTime bg: Int, getEndTime ed: Int) -> [TempModel]? {
        var array: [TempModel] = []
        db.open()
        do {
            let sql = "SELECT * FROM RT617 WHERE time >= ? AND time <= ? AND mac = ? AND time IN (SELECT time FROM RT617 ORDER BY time DESC LIMIT 50)"
            let values: [Any] = [bg, ed, mac]
            let rs = try db.executeQuery(sql, values: values)
            while rs.next() {
                let model = TempModel()
                model.time = Int(rs.double(forColumn: "time"))
                model.mac = rs.string(forColumn: "mac")
                model.max = rs.string(forColumn: "max")
                model.tmp = rs.string(forColumn: "tmp")
                model.unit = rs.string(forColumn: "unit")
                array.append(model)
            }
        } catch {
            print("Failed: \(error.localizedDescription)")
        }
        db.close()
        return array
    }
    
    // 查询所有的数据
    func queryAllData() -> [TempModel] {
        var array: [TempModel] = []
        db.open()
        do {
            let sql = "SELECT * FROM RT617 ORDER BY _id DESC"
            let rs = try db.executeQuery(sql, values: nil)
            while rs.next() {
                let model = TempModel()
                model.time = Int(rs.double(forColumn: "time"))
                model.mac = rs.string(forColumn: "mac")
                model.max = rs.string(forColumn: "max")
                model.tmp = rs.string(forColumn: "tmp")
                model.unit = rs.string(forColumn: "unit")
                array.append(model)
            }
        } catch {
            print("Failed: \(error.localizedDescription)")
        }
        db.close()
        return array
    }
    
    // 更新数据
    func updateData(id: Int, name: String?, value: String?) {
        if id != 0 {
            db.open()
            do {
                let sql = "UPDATE RT617 SET name = ?, value = ? WHERE _id = ?"
                let values: [Any] = [name, value, id]
                try db.executeUpdate(sql, values: values)
                db.close()
            } catch {
                print("Failed: \(error.localizedDescription)")
            }
        }
    }
    
    // 删除数据
    func deleteData(mac: String?) {
        if let mac = mac {
            db.open()
            do {
                let sql = "DELETE FROM RT617 WHERE mac = ?"
                let values: [Any] = [mac]
                try db.executeUpdate(sql, values: values)
                db.close()
            } catch {
                print("Failed: \(error.localizedDescription)")
            }
        }
    }
    
    func getbeginTmpList(beginTime: Int, getendTmpList endTime: Int, getTmpMac tmpMac: String?) -> [TempModel]? {
        var array: [TempModel] = []
        db.open()
        do {
            let sql = "SELECT * FROM RT617 WHERE time <= ? AND time >= ? AND mac = ? ORDER BY time ASC"
            let values: [Any] = [endTime, beginTime, tmpMac]
            let res = try db.executeQuery(sql, values: values)
            while res.next() {
                let tp = TempModel()
                tp.tmp = res.string(forColumn: "tmp")
                tp.max = res.string(forColumn: "max")
                tp.unit = res.string(forColumn: "unit")
                tp.mac = res.string(forColumn: "mac")
                tp.bat = res.string(forColumn: "bat")
                tp.time = Int(res.double(forColumn: "time"))
                array.append(tp)
            }
        } catch {
            print("Failed: \(error.localizedDescription)")
        }
        db.close()
        return array
    }
    
    func getAndTmpList(beginTime: Int, getAndTmpList endTime: Int, getAndMac tmpMac: String?) -> [TempModel]? {
        var array: [TempModel] = []
        db.open()
        do {
            let sql = "SELECT * FROM RT617 WHERE time <= ? AND time >= ? AND mac = ? ORDER BY time DESC"
            let values: [Any] = [endTime, beginTime, tmpMac]
            let res = try db.executeQuery(sql, values: values)
            while res.next() {
                let tp = TempModel()
                tp.tmp = res.string(forColumn: "tmp")
                tp.max = res.string(forColumn: "max")
                tp.unit = res.string(forColumn: "unit")
                tp.mac = res.string(forColumn: "mac")
                tp.bat = res.string(forColumn: "bat")
                tp.time = Int(res.double(forColumn: "time"))
                array.append(tp)
            }
        } catch {
            print("Failed: \(error.localizedDescription)")
        }
        db.close()
        return array
    }
}
