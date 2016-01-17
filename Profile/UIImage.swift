//
//  UIImage.swift
//  Profile
//
//  Created by Ian Hirschfeld on 1/3/16.
//  Copyright © 2016 The Soap Collective. All rights reserved.
//

import UIKit

extension UIImage {

  func tintedImage(tintColor: UIColor, tintAlpha: CGFloat, tintBlendMode: CGBlendMode) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    tintColor.colorWithAlphaComponent(tintAlpha).setFill()
    let bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    drawInRect(bounds)
    UIRectFillUsingBlendMode(bounds, tintBlendMode)
    let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return tintedImage
  }

}
