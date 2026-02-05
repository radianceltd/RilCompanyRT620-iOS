//
//  BaseView.swift
//  TMW041RT
//
//  Created by RND on 2023/3/22.
//

import UIKit

class BaseView: UIView {

    override init(frame: CGRect) {
        super.init(frame:frame)
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initView() {
        
    }
    
}
