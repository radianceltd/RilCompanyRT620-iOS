//
//  CleanAlertController.swift
//  RilCompanyRT617-iOS
//
//  Created by RND on 2023/6/27.
//

import UIKit

class CleanAlertController: UIAlertController {

    var closeGesture: UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        closeGesture = UITapGestureRecognizer(target: self, action: #selector(closeAlert(_:)))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let superView = view.superview
        if !(superView?.gestureRecognizers?.contains(closeGesture!) ?? false) {
            superView?.addGestureRecognizer(closeGesture!)
            superView?.isUserInteractionEnabled = true
        }
    }

    @objc func closeAlert(_ gesture: UITapGestureRecognizer?) {
        dismiss(animated: true)
    }
    
}
