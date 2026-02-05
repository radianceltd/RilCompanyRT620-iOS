//
//  PDFCell.swift
//  RilCompanyRT617-iOS
//
//  Created by RND on 2023/8/4.
//

import UIKit

class PDFCell: BaseCell {
    
    var mMainVw: UIView?
    var mFileNameLb: UILabel?
    var mFileSizeLb: UILabel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // 设置单元格背景色
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        // 主容器视图
        mMainVw = UIView()
        mMainVw!.backgroundColor = UIColor(hexString: "#EAEAEA", transparency: 1.0)
        mMainVw!.layer.cornerRadius = 5.0
        mMainVw!.clipsToBounds = true
        mMainVw!.layer.shadowColor = UIColor.black.cgColor
        mMainVw!.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        mMainVw!.layer.shadowOpacity = 0.5
        mMainVw!.layer.shadowRadius = 5
        self.contentView.addSubview(mMainVw!)
        
        mMainVw!.snp.makeConstraints { make in
            make.top.equalTo(self.contentView).offset(5)
            make.left.equalTo(self.contentView).offset(5)
            make.right.equalTo(self.contentView).offset(-5)
            make.bottom.equalTo(self.contentView).offset(0)
        }
        
        // 文件名标签
        mFileNameLb = UILabel()
        mFileNameLb?.textColor = UIColor.gray
        mFileNameLb?.font = UIFont(name: "Helvetica", size: 14)
        mFileNameLb?.numberOfLines = 2
        mMainVw?.addSubview(mFileNameLb!)
        
        mFileNameLb!.snp.makeConstraints { make in
            make.centerY.equalTo(mMainVw!)
            make.left.equalTo(mMainVw!).offset(15)
            make.right.equalTo(mMainVw!).offset(-100) // 为文件大小标签留出空间
            make.height.equalTo(40)
        }
        
        // 文件大小标签
        mFileSizeLb = UILabel()
        mFileSizeLb?.textColor = UIColor.gray
        mFileSizeLb?.font = UIFont(name: "Helvetica", size: 14)
        mFileSizeLb?.textAlignment = .right
        mMainVw?.addSubview(mFileSizeLb!)
        
        mFileSizeLb!.snp.makeConstraints { make in
            make.centerY.equalTo(mMainVw!)
            make.width.equalTo(80)
            make.right.equalTo(mMainVw!).offset(-15)
            make.height.equalTo(30)
        }
        
        // 添加分隔线
        let separator = UIView()
        separator.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        mMainVw?.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(mMainVw!)
            make.height.equalTo(1)
        }
    }
    
    // 配置单元格数据
    func configure(with fileName: String?, fileSize: Int) {
        mFileNameLb?.text = fileName
        
        if fileSize != 0 {
            let fileSizeInKB = Double(fileSize) / 1000
            let formattedFileSizeInKB = String(format: "%.0fKB", fileSizeInKB)
            mFileSizeLb?.text = formattedFileSizeInKB
        } else {
            mFileSizeLb?.text = "0KB"
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // 选中时的样式
        if selected {
            mMainVw?.backgroundColor = UIColor(hexString: "#D0D0D0", transparency: 1.0)
        } else {
            mMainVw?.backgroundColor = UIColor(hexString: "#EAEAEA", transparency: 1.0)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // 重置单元格状态
        mFileNameLb?.text = nil
        mFileSizeLb?.text = nil
    }
}
