//
//  UIImage.swift
//  InsCard
//
//  Created by Lê Hoàng Anh on 4/4/20.
//  Copyright © 2020 Lê Hoàng Anh. All rights reserved.
//

import UIKit.UIImage

extension UIImage {
    func scaled(toSize size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    func scaleToFit(size: CGSize) -> UIImage {
        let aspect = self.size.width / self.size.height
        if size.width / aspect <= size.height {
            return scaled(toSize: CGSize(width: size.width, height: size.width / aspect))
        } else {
            return scaled(toSize: CGSize(width: size.height * aspect, height: size.height))
        }
    }
}
