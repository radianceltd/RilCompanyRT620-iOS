//
//  ChartView.swift
//  RilCompanyRT617-iOS
//
//  Created by RND on 2023/6/30.
//

import UIKit
import Charts


protocol ChartViewProtocol:NSObjectProtocol {
    
    func tapAction()
    
}

class ChartView: BaseView {
    
    //判断导航栏的离底部距离
    let TOP_HEIGHT = UIDevice.current.iPhoneXMore ? 60 : 20
    
    weak var delegate:ChartViewProtocol?
    
    var mMacLb: UILabel?
    
    var mMaxLb: UILabel?
    
    var mUnitLb:UILabel?
    
    var mLowBatt:UILabel?
    
    var mMoreChart:UIView?
    
    var mLowBatVw:UIImageView?
    
    var lineChart: LineChartView?
    
    var mMaxLine: ChartLimitLine?
    
    var l:Legend?
    
    var leftAxis:YAxis?
    
    var yAxis: YAxis?
    
    var xAxis :XAxis?
    
    var rightAxis: YAxis?
    
    override func initView() {
        
        let topView = UIView()
        addSubview(topView)
        
        topView.snp.makeConstraints { (make) ->Void in
           make.top.equalTo(self).offset(TOP_HEIGHT)
           make.left.equalTo(self).offset(5)
           make.right.equalTo(self).offset(-5)
           make.height.equalTo(45)
        }
        
        mMacLb = UILabel()
        mMacLb!.textColor = UIColor.black
        mMacLb!.font = UIFont(name: "Helvetica-Bold", size: 18)
        mMacLb!.textAlignment = .left
        topView.addSubview(mMacLb!)
        
        mMacLb!.snp.makeConstraints { (make) ->Void in
           make.top.equalTo(topView).offset(10)
           make.left.equalTo(topView).offset(10)
           make.width.equalTo(200);
           make.height.equalTo(20);
        }
        
        mMaxLb = UILabel()
        mMaxLb!.textColor = UIColor.gray
        //self.mMacLb.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
        mMaxLb!.font = UIFont(name: "Helvetica-Bold", size: 20)
        mMaxLb!.textAlignment = .left
        mMaxLb!.textColor = UIColor.black
        addSubview(mMaxLb!)
        
        mMaxLb!.snp.makeConstraints { (make) ->Void in
           make.top.equalTo(topView).offset(50)
           make.left.equalTo(self).offset(20)
           make.width.equalTo(130);
           make.height.equalTo(20);
        }
        
        mLowBatVw = UIImageView()
        mLowBatVw!.image = UIImage(named: "lowbat")
        mLowBatVw!.isHidden = true
        topView.addSubview(mLowBatVw!)
        
        mLowBatVw!.snp.makeConstraints { (make) ->Void in
           make.top.equalTo(topView).offset(10)
           make.right.equalTo(topView).offset(-20)
           make.width.equalTo(25);
           make.height.equalTo(25);
        }
       
        mUnitLb = UILabel()
        mUnitLb!.textColor = UIColor.black
        mUnitLb!.font = UIFont(name: "Helvetica", size: 12)
        mUnitLb!.textAlignment = .left
        addSubview(mUnitLb!)
        
        mUnitLb!.snp.makeConstraints { (make) ->Void in
           make.top.equalTo(mMaxLb!).offset(35)
           make.left.equalTo(self).offset(5)
           make.width.equalTo(30);
           make.height.equalTo(20);
        }
        
        mMoreChart = UIView()
        mMoreChart!.layer.cornerRadius = 8
        mMoreChart!.layer.borderWidth = 1
        mMoreChart!.layer.borderColor = UIColor.gray.cgColor
        addSubview(mMoreChart!)
        
        mMoreChart!.snp.makeConstraints { (make) ->Void in
           make.top.equalTo(topView).offset(50)
           make.right.equalTo(self).offset(-15)
           make.width.equalTo(85);
           make.height.equalTo(45);
        }
        
        mLowBatt = UILabel()
        mLowBatt!.textColor = UIColor.black
        mLowBatt!.font = UIFont(name: "Helvetica", size: 12)
        mLowBatt!.text = "The device is offline."
        mLowBatt!.textAlignment = .center
        addSubview(mLowBatt!)
        
        mLowBatt!.snp.makeConstraints { (make) ->Void in
           make.center.equalTo(self)
           make.width.equalTo(self).offset(screenWidth/2)
           make.height.equalTo(30);
        }
        
        let moreImg = UIImageView()
        //UIImage *img = [UIImage imageNamed:@"line_graph"];
        moreImg.image = UIImage(named: "chart")
        mMoreChart!.addSubview(moreImg)
        
        moreImg.snp.makeConstraints { (make) ->Void in
           make.top.equalTo(mMoreChart!).offset(2)
           make.centerX.equalTo(mMoreChart!.center)
           make.left.equalTo(mMoreChart!).offset(25)
           make.width.equalTo(30);
           make.height.equalTo(20);
        }
        
        let moreLb = UILabel()
        moreLb.textColor = UIColor.gray
        moreLb.font = UIFont(name: "Helvetica", size: 12)
        moreLb.textAlignment = .center
        moreLb.textColor = UIColor.black
        moreLb.text = "More data"
        mMoreChart!.addSubview(moreLb)

        moreLb.snp.makeConstraints { (make) ->Void in
           make.top.equalTo(moreImg).offset(20)
           make.centerX.equalTo(mMoreChart!.center)
           make.left.equalTo(mMoreChart!).offset(15)
           make.width.equalTo(70);
           make.height.equalTo(20);
        }
        
        lineChart = LineChartView()
        addSubview(lineChart!)
        
        self.lineChart!.snp.makeConstraints { (make) ->Void in
           make.top.equalTo(self.mUnitLb!).offset(15)
           make.left.equalTo(self).offset(5);
           make.right.equalTo(self).offset(-5);
           make.bottom.equalTo(self).offset(-55);
        }
        
        lineChart!.chartDescription!.enabled = false
        lineChart!.dragEnabled = true
        lineChart!.setScaleEnabled(true)
        lineChart!.drawGridBackgroundEnabled = false
        lineChart!.pinchZoomEnabled = true
        lineChart!.highlightPerDragEnabled = true;
        lineChart!.legend.enabled = true
        lineChart!.noDataText = "no data"
        //不绘制右边的轴线
        lineChart!.rightAxis.enabled = false
        lineChart!.backgroundColor = UIColor.white
        l = lineChart!.legend
        l!.font = UIFont(name: "HelveticaNeue-Light", size: 11.0)!
        l!.textColor = UIColor.white
        l!.horizontalAlignment = Legend.HorizontalAlignment.left
        l!.verticalAlignment = Legend.VerticalAlignment.bottom
        l!.orientation = Legend.Orientation.horizontal
        l!.drawInside = false
        xAxis = lineChart!.xAxis
        xAxis!.labelFont = UIFont.systemFont(ofSize: 11.0)
        xAxis!.labelTextColor = UIColor.black
        //文字颜色为黑色
        xAxis!.drawGridLinesEnabled = true
        //绘制x轴线
        xAxis!.drawAxisLineEnabled = false
        xAxis!.axisLineWidth = 2.0 / UIScreen.main.scale
        //设置X轴线宽
        xAxis!.labelPosition = .bottom
        //设置x轴数据在底部
        xAxis!.granularityEnabled = true
        //设置重复的值不显示
        xAxis!.labelCount = 4
        //只能显示4个数
        leftAxis = self.lineChart?.leftAxis;
        leftAxis!.labelTextColor = UIColor.black;
        leftAxis!.inverted = false;
        //是否将Y轴进行上下翻转
        leftAxis!.drawGridLinesEnabled = true;
        leftAxis!.drawZeroLineEnabled = false;
        leftAxis!.granularityEnabled = true;
        
        rightAxis = lineChart!.rightAxis
        rightAxis!.labelTextColor = UIColor.red
        rightAxis!.axisMaximum = 900.0
        rightAxis!.axisMinimum = -200.0
        rightAxis!.drawGridLinesEnabled = false
        rightAxis!.granularityEnabled = false
        lineChart!.animate(xAxisDuration: 2.5)
        
        let tapGesturRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        mMoreChart!.addGestureRecognizer(tapGesturRecognizer)
        
    }
    
    @objc func tapAction() {
        if (delegate != nil) {
            delegate!.tapAction()
        }
    }
}

