//
//  MoreChartView.swift
//  RilCompanyRT617-iOS
//
//  Created by RND on 2023/8/25.
//

import UIKit
import SwiftEventBus
import WHToast
import MBProgressHUD
import Charts


let ALERTVIEW_HEIGHTM = UIScreen.main.bounds.size.height / 1.2
let ALERTVIEW_WIDTHM = UIScreen.main.bounds.size.width - 10
let HEIGHT = UIScreen.main.bounds.size.height
let WIDTH = UIScreen.main.bounds.size.width


protocol MoreChartViewDelegate:NSObjectProtocol {
    func hideAction()
}


class MoreChartView: BaseView,MoreViewDelegate{
    
    weak var delegate: MoreChartViewDelegate?
    
    var moreView: MoreView?
    var cmunitil = CommonUtil()
    var tempUnit: String?
    var cmDefaults: CommonDefaults?
    //private var hud :MBProgressHUD?
    var cmUtil = CommonUtil()
    var mac: String?
    var unit :String?
    var mDataList = [TempModel]()
    var itime = 0
    var dateformatter: DateFormatter?
    var iarray : [String] = Array()
     /*时间格式化 */
    //var iarray: [AnyHashable]?
    var changeDate: String?
    var model:TempModel?
    //获取本地时间
    var locationDate: String?
    var maska: UIView?


    override func initView() {
        show()
        moreView!.delegate = self
        initData()
    }
    
   func initData() {
   
    //mac地址
    mac = CommonDefaults.shared.getValue(MAC)
     
    //CommonDefaults.shared.saveValue(m_unit, forKey: mac!+UNIT)
    //温度符号值
    unit = CommonDefaults.shared.getValue(UNIT)
       
       if unit == "" || unit == nil {
           unit = "°C"
       }
    
     //更新More界面该显示的值
    updateMoreVule(mac: mac,unit: unit)
    
    initLineChart()
    setTime()
    
    }
    
    func updateMoreVule(mac:String?,unit:String?){
        //MAC地址
        if(mac != nil){
            //moreView!.mMaxLb!.text = mac!
        }
        //温度、符号
        if(unit != nil){
            if(unit == "°F"){
               moreView!.mUnitLb!.text = "°F"
            }else{
               moreView!.mUnitLb!.text = "°C"
            }
        }
    }
    
    func initLineChart(){
        
        /*
         chartView.leftAxis!.axisMaximum = 70
         chartView.leftAxis!.axisMinimum = -50
     } else {
         chartView.leftAxis!.axisMaximum = 150
         chartView.leftAxis!.axisMinimum = -55
         */
        
        if (unit == UNITC) {
            moreView!.leftAxis!.axisMaximum = 70
            moreView!.leftAxis!.axisMinimum = -50
        }
        else {
            moreView!.leftAxis!.axisMaximum = 150
            moreView!.leftAxis!.axisMinimum = -55
        }
        

        moreView!.leftAxis!.drawLimitLinesBehindDataEnabled = true
        let marker = BalloonMarker(color: UIColor(white: 180/255, alpha: 0.8),
        font: .systemFont(ofSize: 12),
        textColor: .white,
        insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        marker.chartView = moreView!.lineChart
        marker.minimumSize = CGSize(width: 60.0, height: 40.0)
        moreView!.lineChart!.marker = marker
        moreView!.lineChart!.chartDescription?.enabled = false
        
        moreView!.lineChart!.legend.formSize = 8
        moreView!.lineChart!.legend.textColor = UIColor.gray
        moreView!.lineChart!.legend.form = .line
    }
    
    func setTime() {
        dateformatter = DateFormatter()
        //时间格式国外的格式
        dateformatter!.dateFormat = "YYYY/MM/dd HH:mm:ss"
        //获取当前的数据
        let senddate = Date()
        let time = dateformatter!.string(from: senddate)
        //分解空号
        iarray = time.components(separatedBy: " ")
        //继续分解
        let b = iarray[1].components(separatedBy: ":")
        itime = Int(b[0]) ?? 0
        let bt = "\(b[0]):00:00"
        let et = "\(b[0]):59:59"
        let btime = "\(iarray[0]) \(bt)"
        let etime = "\(iarray[0]) \(et)"
        let aatime = dateformatter!.date(from: btime)
        let bbtime = dateformatter!.date(from: etime)
        let bTime = Int(aatime?.timeIntervalSince1970 ?? 0)
        let eTime = Int(bbtime?.timeIntervalSince1970 ?? 0)

        getTempListData(bTime, endTime: eTime)

    }
    
    func getTempListData(_ btime: Int, endTime etime: Int) {
        print("azmmmmmm",btime,etime)
        
        //创建对话框
        let hud = MBProgressHUD.showAdded(to: moreView!, animated: true)
        hud.bezelView.style = .solidColor
        hud.bezelView.color = UIColor.black.withAlphaComponent(0.7)
        hud.label.text = NSLocalizedString("Loading...", comment: "HUD loading title")
        hud.contentColor = UIColor.white

        if mac != nil {
            //数据太多了加载图表很慢
            mDataList = TempDB.shared.getFirst50TempList(mac: mac, getBeginTime: btime, getEndTime: etime)!
            //mDataList = TmpDB.shared.getbeginTmpList(btime, getendTmpList: etime, getTmpMac:mac)!
        }
        
        //必须要大于1位数 必须是2个 总数必须是2点才能成一条线
        if mDataList.count < 2 {
            let b = cmunitil.date(fromLongLong: btime)
            let bb = cmunitil.string(from: b!)
            let e = cmunitil.date(fromLongLong: etime)
            let ee = cmunitil.string(from: e!)
            let message = "\(bb)~\(ee) \(" No data.")"
            
            hud.mode = MBProgressHUDMode.text
            hud.label.text = message
            hud.minSize = CGSize(width: 200.0, height: 80.0)
            hud.hide(animated: true, afterDelay: 2.0)
        }else{
            hud.hide(animated: true, afterDelay: 2.0)
            listMax()
            setTempData()
        }
    }

    //最大值最小值处理方法
    func listMax(){
        var max: Float = 0
        var min: Float = 0
       for i in 0..<mDataList.count {
           let tp = mDataList[i]
           //let nsstringStr = tp.max! as NSString
           let floatValue = Float(tp.tmp!)
           let tmax = floatValue!
           
           if tmax < 999 && tmax > -999 {
               if (unit == UNITC) {
                   //let aa = cmUtil.convertFahrenheit(toCelcius: tmax)
                   if i == 0 {
                       max = tmax
                       min = tmax
                   }
                   
                   if tmax > max {
                       max = tmax
                   }
                   
                   if tmax < min {
                       min = tmax
                   }
                   
               } else {
                   //func convertCelcius(toFahren celcius: Float) -> Float {
                   let aa = cmUtil.convertCelcius(toFahren: tmax)
                   if i == 0 {
                       max = aa
                       min = aa
                   }
                   
                   if aa > max {
                       max = aa
                   }
                   
                   if aa < min {
                       min = aa
                   }
                   
               }
           }
       }
        moreView!.mMaxLb!.text = "Max:" + String(format: "%.1f", max)+unit!
        moreView!.mMinLb!.text = "Min:" + String(format: "%.1f", min)+unit!
    }
    
    //图表的温度数据方法
    func setTempData(){
       var xVals: [String] = []
       var yVals: [Any] = []
      
      for i in 0..<mDataList.count {
          
          let model = mDataList[i]
          
          if !(model.tmp == "999") && !(model.tmp == "-999") && !(model.tmp == "1111") {
            let time = cmUtil.date(fromLongLong: model.time)
              let stime = cmUtil.string(from: time!)
              //添加字符串时间
              xVals.append(stime)
              
              if unit == UNITC {
                  let fstr = Float(model.tmp!)!
                  yVals.append(ChartDataEntry(x: Double(i), y: Double(fstr)))
              }else{
                  let fstr = Float(model.tmp!)!
                  //print("a-tmp",model.tmp!)
                  let y = cmUtil.convertCelcius(toFahren: fstr)
                  yVals.append(ChartDataEntry(x: Double(i), y: Double(y)))
              
              }
          }
          
          moreView!.lineChart!.xAxis.valueFormatter = IndexAxisValueFormatter(values: xVals)
          var set1: LineChartDataSet? = nil
          
//          if moreView!.lineChart?.data?.dataSetCount != nil {
//              set1 = moreView!.lineChart?.data?.dataSets[0] as? LineChartDataSet
//              set1?.replaceEntries(yVals as! [ChartDataEntry])
//              moreView!.lineChart?.data?.notifyDataChanged()
//              moreView!.lineChart?.notifyDataSetChanged()
//          }else{
              let senddate = Date()
              let dateformatters = DateFormatter()
              dateformatters.dateFormat = "MM/dd/YYYY"
              changeDate = dateformatters.string(from: senddate)
              //[self loadChartData];/
              let dailyDegree = "Chart (degree / time)"
              locationDate = changeDate
              
              let dd = "\(dailyDegree)  \(locationDate!)"
              //set1 = [[LineChartDataSet alloc] initWithValues:yVals label:dd];
              //Version 3.3.0版本
              set1 = LineChartDataSet(entries: (yVals as! [ChartDataEntry]), label: dd)
              set1?.axisDependency = .left
              
              set1?.setColor(UIColor.blue)
              set1?.valueTextColor = UIColor(red: 51 / 255.0, green: 181 / 255.0, blue: 229 / 255.0, alpha: 1.0)
              
              set1?.lineWidth = 2.0
              set1?.circleRadius = 0.1
              set1?.drawCirclesEnabled = false
              set1?.drawValuesEnabled = false
              set1?.drawCircleHoleEnabled = false
              
              //老项目1.0.2版本
              set1?.fillColor = UIColor.blue
              set1?.highlightColor = UIColor.blue
              set1?.fillAlpha = 65 / 255.0
              set1?.fillColor = UIColor.red
              set1?.highlightColor = UIColor.red
              
              var dataSets: [Any] = []
              dataSets.append(set1!)
              let data = LineChartData(dataSets: [set1] as? [IChartDataSet])
              data.setValueFont(.systemFont(ofSize: 9.0))
              data.setValueTextColor(.white)
              moreView!.lineChart?.data = data
         // }
       }
    }

    func show() {
        frame = UIScreen.main.bounds
        maska = UIView(frame: CGRect(x: 5, y: HEIGHT / 2 - ALERTVIEW_HEIGHTM / 2, width: ALERTVIEW_WIDTHM, height: ALERTVIEW_HEIGHTM))
        maska!.backgroundColor = UIColor.white
        maska!.layer.cornerRadius = 8.0
        maska!.layer.masksToBounds = true
        maska!.isUserInteractionEnabled = true
        self.addSubview(maska!)


        moreView = MoreView()
        maska!.addSubview(moreView!)

        moreView!.snp.makeConstraints({ (make) in
            make.top.equalTo(maska!).offset(0);
            make.left.equalTo(maska!).offset(0);
            make.right.equalTo(maska!).offset(0);
            make.height.equalTo(maska!).offset(0);
        })

        UIApplication.shared.keyWindow?.addSubview(self)
        let transform: CGAffineTransform = CGAffineTransform(scaleX: 1.0,y: 1.0)
        maska!.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        maska!.alpha = 0

        UIView.animate(withDuration: 0.3, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: .curveLinear, animations: {
            self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            self.maska!.transform = transform
            self.maska!.alpha = 1
        }) { finished in

        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.5, animations: {
            self.transform = self.transform.translatedBy(x: 0, y: -self.frame.maxY)
            self.maska!.alpha = 0
        }) { isFinished in
            self.maska!.removeFromSuperview()
            self.removeFromSuperview()
        }

        //触发事件
        hideAction()
    }

    //点击按钮事件触发
    func hideAction(){
        //停止扫描
        if (delegate != nil) {
            delegate!.hideAction()
        }
    }
    
    //右上角关闭按钮
    func closeAction(){
        print("closeAction")
        hide()
    }

    //左边查询数据
    func leftAction(){
        //停止扫描
        print("leftAction")
        
        var qtime = itime - 1
        if itime == 0 {
            qtime = 0
        }else{
            itime = qtime
        }
        //开始时间
        let begintime = "\(qtime):00:00"
        //结束时间
        let endtime = "\(qtime):59:59"
        let allbtime = "\(iarray[0]) \(begintime)"
        let alletime = "\(iarray[0]) \(endtime)"
        let aatime = dateformatter!.date(from: allbtime)
        let bbtime = dateformatter!.date(from: alletime)
        let bTime = Int(aatime?.timeIntervalSince1970 ?? 0);
        let eTime = Int(bbtime?.timeIntervalSince1970 ?? 0)
        getTempListData(bTime, endTime: eTime)
    }
    
    //右边查询数据
    func rightAction(){
        //停止扫描
        print("rightAction")
        
        var htime = itime + 1
        if itime == 23 {
            htime = 23
        }else{
            itime = htime
        }
        //开始时间
        let begintime = "\(htime):00:00"
        //结束时间
        let endtime = "\(htime):59:59"
        let allbtime = "\(iarray[0]) \(begintime)"
        let alletime = "\(iarray[0]) \(endtime)"
        let aatime = dateformatter!.date(from: allbtime)
        let bbtime = dateformatter!.date(from: alletime)
        let bTime = Int(aatime?.timeIntervalSince1970 ?? 0)
        let eTime = Int(bbtime?.timeIntervalSince1970 ?? 0)
        getTempListData(bTime, endTime: eTime)
    }
    
    func hideView(){
        print("hideView")
    }
    
}

