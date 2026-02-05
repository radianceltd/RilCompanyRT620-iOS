//
//  ChartViewController.swift
//  RilCompanyRT617-iOS
//
//  Created by RND on 2023/6/30.
//

import UIKit
import Charts
import SwiftEventBus

class ChartViewController:NavigationController,ChartViewProtocol,ChartViewDelegate,
                          MoreChartViewDelegate{
    
    var chartView = ChartView()
    
    var model = BleModel()
    
    var cmUtil = CommonUtil()
    
    var selectDate: DateFormatter?
    
    var selectDate1: DateFormatter?
    
    var times : [String] = Array()
    
    private var isRun: Bool = false
    
    var currentDate : String?
    
    var unit:String?
    
    var index:Int?
    
    //每次存储的值
    var mConut:Int = 0
    
    //定义接收数据的列表
    var dataList = [TempModel]()
    
    var scanResultsList: LinkedHashMap<String, BleModel> = LinkedHashMap()
    
    var changeDate : String?
    
    var locationDate : String?
    
    var moreView:MoreChartView?
    
    var mac: String?
    
    var max: Float = 0
    
    var current:Int? = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //每次进来的时候都启动
    override func viewWillAppear(_ animated: Bool) {
        
        initData()
        
        isRun = true;
        
        //温度符号值
        if(unit == "°C"){
            unit = "°C"
        }else{
            unit = "°F"
        }
        
        mac = model.deviceMAC
        
        //温度符号显示
        chartView.mUnitLb!.text = unit
        
        //显示MAC地址的值
        if model.deviceMAC != nil{
            let uppserString = model.deviceMAC!.uppercased()
            chartView.mMacLb?.text = "S/N:\(uppserString)"
            
        }
        
        //初始化图表
        initLineChart()
        
        //读取图表的温度数据
        getCurrentData(mac:model.deviceMAC!)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        isRun = false
        SwiftEventBus.unregister(self)
        
    }
    
    override func initView() {
        
        chartView.delegate = self
        chartView.frame = view.bounds
        self.view.addSubview(chartView)
        chartView.mLowBatt?.isHidden = true
        
    }
    
    override func initData() {
        //加载对话框
        selectDate = DateFormatter()
        selectDate1 = DateFormatter()
        selectDate!.dateFormat = "YYYY/MM/dd"
        //时间显示格式
        selectDate1!.dateFormat = "YYYY/MM/dd HH:mm:ss"
        
        // 存储单位
        CommonDefaults.shared.saveValue(model.deviceMAC, forKey: MAC)
        
        //得到蓝牙列表
        SwiftEventBus.onMainThread(self, name: "scanResults"){
            result in
            
            self.scanResultsList = result?.object as! LinkedHashMap<String, BleModel>
            
            for model in self.scanResultsList.list {
                if model.deviceMAC!.contains(self.model.deviceMAC!){
                    //self.updateTempDate(model: model)
                    self.model = model
                }
            }
        }
        
        SwiftEventBus.onMainThread(self, name: "chartTemp") { result in
            // 处理接收到的事件
            print("aaaaaaazzzzzzyuan")
            //读取图表的温度数据
            self.getCurrentData(mac:self.model.deviceMAC!)
        }
    }
    
    //初始化图表控件
    func initLineChart(){
        
        //定义轴线数据
        if (unit == UNITC) {
            chartView.leftAxis!.axisMaximum = 70
            chartView.leftAxis!.axisMinimum = -50
        } else {
            chartView.leftAxis!.axisMaximum = 150
            chartView.leftAxis!.axisMinimum = -55
        }
        
        let marker = BalloonMarker(color: UIColor(white: 180/255, alpha: 1),
                                   font: .systemFont(ofSize: 12),
                                   textColor: .white,
                                   insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        marker.chartView = chartView.lineChart
        marker.minimumSize = CGSize(width: 60.0, height: 40.0)
        chartView.lineChart!.marker = marker
        chartView.lineChart!.chartDescription?.enabled = false
        
        chartView.leftAxis!.drawLimitLinesBehindDataEnabled = true
        chartView.lineChart!.chartDescription!.enabled = false
        
        chartView.lineChart!.legend.formSize = 8
        chartView.lineChart!.legend.textColor = UIColor.gray
        chartView.lineChart!.legend.form = .line
        
    }
    
    //当前的数据
    func getCurrentData(mac:String){
        
        if dataList.count > 0{
            dataList.removeAll()
        }
        
        //当前日期
        let date = Date()
        let dateString = selectDate!.string(from: date)
        let begin = "\(dateString) 00:00:00"
        let end = "\(dateString) 23:59:59"
        let aatime = selectDate1!.date(from: begin)
        let bbtime = selectDate1!.date(from: end)
        //开始日期
        let bTime = Int(aatime?.timeIntervalSince1970 ?? 0)
        //结束日期
        let eTime = Int(bbtime?.timeIntervalSince1970 ?? 0)
        
        //获取数据库前50条数据信息
        let adataList = TempDB.shared.getFirst50TempList(mac: mac, getBeginTime: bTime, getEndTime: eTime)!
        //筛选重叠的数据
        dataList = cmUtil.handleFilterArray(arr: adataList)
        
        if(dataList.count > 0){
            //如果当前的数据列表大于0的时候，就显示操作这些数据方法
            //加载数据温度以及X/Y轴
            setTempData()
            
            //最大最小值
            tempListMaxValue()
        }
    }
    
    //设置温度数据方法
    func setTempData(){
        
        var xVals: [String] = []
        var yVals: [Any] = []
        
        for i in 0..<dataList.count {
            
            let model = dataList[i]
            
            if !(model.tmp == "999") && !(model.tmp == "-999") && !(model.tmp == "1111") {
                let time = cmUtil.date(fromLongLong: model.time)!
                let stime = cmUtil.string(from: time)
                //添加字符串时间
                xVals.append(stime)
                print("xVals-i==",Double(i))
                print("xVals-time==",time)
                print("xVals-stime==",stime)
                
                //判断当前符号是华氏度or摄氏度
                if unit == "°F" {
                    let fstr = Float(model.tmp!)!
                    let y = cmUtil.convertCelcius(toFahren:fstr)
                    yVals.append(ChartDataEntry(x: Double(i), y: Double(y)))
                }else{
                    let fstr = Float(model.tmp!)!
                    yVals.append(ChartDataEntry(x: Double(i), y: Double(fstr)))
                }
                
                //显示lineChart图表
                self.chartView.lineChart!.isHidden = false;
                //隐藏无数据时图表的text提示
                self.chartView.mLowBatt!.isHidden = true;
            }else{
                self.chartView.lineChart!.isHidden = true;
                self.chartView.mLowBatt!.isHidden = false;
            }
            
            chartView.lineChart!.xAxis.valueFormatter = IndexAxisValueFormatter(values: xVals)
            var set1: LineChartDataSet? = nil
            
            //            if chartView.lineChart?.data?.dataSetCount != nil {
            //                set1 = chartView.lineChart?.data?.dataSets[0] as? LineChartDataSet
            //                set1?.replaceEntries(yVals as! [ChartDataEntry])
            //                chartView.lineChart?.data?.notifyDataChanged()
            //                chartView.lineChart?.notifyDataSetChanged()
            //            }else{
            //显示到图表下面的时间
            let senddate = Date()
            let dateformatters = DateFormatter()
            dateformatters.dateFormat = "MM/dd/YYYY"
            changeDate = dateformatters.string(from: senddate)
            //[self loadChartData];
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
            chartView.lineChart?.data = data
            //}
        }
    }
    
    //温度数据列表中最大的值
    func tempListMaxValue(){
        
        for i in 0..<dataList.count {
            let tp = dataList[i]
            let tmax = tp.tmp
            let a = Float(tmax!)
            if a! < 999 && a! > -999 {
                if (unit == "°C") {
                    let aa = Float(a!)
                    //let aa = cmUtil.convertFahrenheit(toCelcius: Float(a!))
                    if i == 0 {
                        max = aa
                    }
                    
                    if aa > max {
                        max = aa
                    }
                } else {
                    if i == 0 {
                        let aa = cmUtil.convertCelcius(toFahren:Float(a!))
                        max = aa
                    }
                    
                    if Float(a!) > max {
                        max = Float(a!)
                    }
                }
                //最大值
                let maxTitle = "MAX : "
                
                chartView.mMaxLb!.text = maxTitle + String(format: "%.1f", max) + unit!
            }
        }
    }
    
    //点击
    func tapAction() {
        isRun = false
        moreView = MoreChartView()
        moreView!.delegate = self
    }
    
    func hideAction() {
        isRun = true
    }
    
}
