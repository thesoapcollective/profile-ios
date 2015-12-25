//
//  DottedBorderImageView.swift
//  Profile
//
//  Created by Ian Hirschfeld on 12/24/15.
//  Copyright © 2015 The Soap Collective. All rights reserved.
//

import UIKit

class DottedBorderImageView: UIImageView {

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init(size: CGFloat, num: CGFloat, color: UIColor) {
    let dashes: [CGFloat] = [0, size * 2]

    let path = UIBezierPath()
    path.moveToPoint(CGPointMake(size, size / 2))
    path.addLineToPoint(CGPointMake(size * num * 2, size / 2))
    path.lineWidth = size
    path.setLineDash(dashes, count: dashes.count, phase: 0)
    path.lineCapStyle = CGLineCap.Round

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size * num * 2, size), false, 0)
    color.setStroke()
    path.stroke()
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    super.init(image: image)
  }

}
