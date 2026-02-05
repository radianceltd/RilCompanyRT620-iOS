//
//  MoreView.swift
//  RilCompanyRT617-iOS
//
//  Created by RND on 2023/8/25.
//

import UIKit
import SwiftEventBus
import WHToast
import Charts

protocol MoreViewDelegate:NSObjectProtocol {

    func leftAction()
    
    func rightAction()
    
    func closeAction()
    
}

class MoreView: BaseView{
    

    
    weak var delegate: MoreViewDelegate?

    var lineChart: LineChartView?
    var leftAxis: YAxis?
    var l:Legend?
    
    var yAxis: YAxis?
    var rightAxis: YAxis?
    var xAxis :XAxis?
    var mMaxLb: UILabel?
    var mMinLb: UILabel?
    var leftBtn: UIButton?
    var rightBtn: UIButton?
    var mUnitLb: UILabel?
    var closeBtn: UIButton?

    override func initView() {
        
        //Max标示
        
//        let maxLb = UILabel()
//        maxLb.textColor = UIColor.black
//        maxLb.font = UIFont(name: "Helvetica-bold", size: 14)
//        maxLb.textAlignment = .left
//        maxLb.text = "Max:"
//        addSubview(maxLb)
//
//        maxLb.snp.makeConstraints{(make)->Void in
//            make.top.equalTo(self).offset(10);
//            make.left.equalTo(self).offset(10);
//            make.width.equalTo(40);
//            make.height.equalTo(20);
//        }
        
        //最大值的值
        mMaxLb = UILabel()
        mMaxLb!.textColor = UIColor.black
        mMaxLb!.font = UIFont(name: "Helvetica-bold", size: 14)
        mMaxLb!.textAlignment = .left
        addSubview(mMaxLb!)

        mMaxLb!.snp.makeConstraints{(make)->Void in
           make.top.equalTo(self).offset(10)
           make.left.equalTo(self).offset(15)
           make.width.equalTo(100)
           make.height.equalTo(20)
        }
        
        mMinLb = UILabel()
        mMinLb!.textColor = UIColor.black
        mMinLb!.font = UIFont(name: "Helvetica-bold", size: 14)
        mMinLb!.textAlignment = .left
        addSubview(mMinLb!)

        mMinLb!.snp.makeConstraints{(make)->Void in
           make.top.equalTo(mMaxLb!).offset(30)
           make.left.equalTo(self).offset(15)
           make.width.equalTo(100)
           make.height.equalTo(20)
        }
        
        //符号
        mUnitLb = UILabel()
        mUnitLb!.textColor = UIColor.black
        mUnitLb!.text = "unit"
        mUnitLb!.font = UIFont(name: "Helvetica", size: 12)
        mUnitLb!.textAlignment = .left
        addSubview(mUnitLb!)
        
        mUnitLb!.snp.makeConstraints{(make)->Void in
                  make.top.equalTo(self).offset(65);
                  make.left.equalTo(self).offset(3);
                  make.width.equalTo(30);
                  make.height.equalTo(20);
               }
        
       //图表的UI
       lineChart = LineChartView()
       
       
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
        
        addSubview(lineChart!)
        
        self.lineChart!.snp.makeConstraints { (make) ->Void in
           make.top.equalTo(self.mUnitLb!).offset(15)
           make.left.equalTo(self).offset(5);
           make.right.equalTo(self).offset(-5);
           make.bottom.equalTo(self).offset(-10);
        }
        
        //左边的按钮
        leftBtn = UIButton()
        leftBtn?.setImage(UIImage(named:"bleft"),for:.normal)
        self.addSubview(leftBtn!)
        
        leftBtn!.snp.makeConstraints{(make)->Void in
            make.centerY.equalTo(self)
            make.left.equalTo(self).offset(0);
            make.width.equalTo(30);
            make.height.equalTo(30);
        }
        
        //右边的按钮
        rightBtn = UIButton()
        rightBtn?.setImage(UIImage(named:"bright"),for:.normal)
        self.addSubview(rightBtn!)
        
        rightBtn!.snp.makeConstraints{(make)->Void in
            make.centerY.equalTo(self)
            make.right.equalTo(self).offset(0);
            make.width.equalTo(30);
            make.height.equalTo(30);
        }
        
        
        closeBtn = UIButton()
        let cancelImageView = UIImageView()
        cancelImageView.image = UIImage(named: "clear")
        closeBtn!.addSubview(cancelImageView)
        addSubview(closeBtn!)
        
        cancelImageView.snp.makeConstraints{(make)->Void in
            make.top.equalTo(closeBtn!).offset(0);
            make.left.equalTo(closeBtn!).offset(0);
            make.right.equalTo(closeBtn!).offset(0);
            make.bottom.equalTo(closeBtn!).offset(0);
        }
        
        closeBtn!.snp.makeConstraints{(make)->Void in
            make.top.equalTo(self).offset(10);
            make.right.equalTo(self).offset(-10);
            make.width.equalTo(30);
            make.height.equalTo(30);
        }

        
        //按钮点击事件
        closeBtn!.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        
        rightBtn!.addTarget(self, action: #selector(rightAction), for: .touchUpInside)

        leftBtn!.addTarget(self, action: #selector(leftAction), for: .touchUpInside)
    }
    
    override init(frame: CGRect) {
          super.init(frame: frame)
          //默认灰色
      }
      
      required init?(coder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
      }
    

    //点击按钮事件触发
    @objc func closeAction(){
        //停止扫描
        if (delegate != nil) {
            delegate!.closeAction()
        }
    }
    
    @objc func leftAction(){
        //停止扫描
        if (delegate != nil) {
            delegate!.leftAction()
    }
    }

       @objc func rightAction(){
        //停止扫描
        if (delegate != nil) {
            delegate!.rightAction()
        }
    }

}



