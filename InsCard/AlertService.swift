//
//  AlertService.swift
//  InsCard
//
//  Created by Lê Hoàng Anh on 4/4/20.
//  Copyright © 2020 Lê Hoàng Anh. All rights reserved.
//

import UIKit

struct AlertService {
    
    static func show(in vc: UIViewController?, title: String? = nil, msg: String, action: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: action)
        alert.addAction(okAction)
        
        if action != nil {
            alert.addCancelAction()
        }
        
        UIImpactFeedbackGenerator().impactOccurred()
        vc?.present(alert, animated: true, completion: nil)
    }
    
    static func show(in vc: UIViewController?, msg: String) {
        show(in: vc, title: nil, msg: msg)
    }
}

extension UIAlertController {
    func addCancelAction() {
        addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    }
    
    func addOkAction(handler: (() -> Void)?) {
        addAction(title: "Ok", handler: handler)
    }
    
    func addAction(title: String, handler: (() -> Void)?) {
        addAction(UIAlertAction(title: title, style: .default, handler: { _ in
            handler?()
        }))
    }
}
