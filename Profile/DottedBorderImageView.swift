//
//  DottedBorderImageView.swift
//  Profile
//
//  Created by Ian Hirschfeld on 12/24/15.
//  Copyright © 2015 The Soap Collective. All rights reserved.
//

import UIKit

@IBDesignable
class DottedBorderImageView: UIImageView {

  // ==================================================
  // PROPERTIES
  // ==================================================

  @IBInspectable var dotSize: CGFloat = 5 {
    didSet { updateImage() }
  }

  @IBInspectable var dotColor: UIColor = UIColor.blackColor() {
    didSet { updateImage() }
  }

  @IBInspectable var dotCount: CGFloat = 5 {
    didSet { updateImage() }
  }

  @IBInspectable var isVertical: Bool = false {
    didSet { updateImage() }
  }

  // ==================================================
  // METHODS
  // ==================================================

  func updateImage() {
    let dottedImage = createDottedImage(dotSize, num: dotCount, color: dotColor)
    image = dottedImage
  }

  func createDottedImage(size: CGFloat, num: CGFloat, color: UIColor) -> UIImage {
    let dotHalfSize: CGFloat = size / 2
    let dotDoubleSize: CGFloat = size * 2
    let dashes: [CGFloat] = [0, dotDoubleSize]

    let path = UIBezierPath()
    if isVertical {
      path.moveToPoint(CGPointMake(dotHalfSize, size))
      path.addLineToPoint(CGPointMake(dotHalfSize, dotDoubleSize * num))
    } else {
      path.moveToPoint(CGPointMake(size, dotHalfSize))
      path.addLineToPoint(CGPointMake(dotDoubleSize * num, dotHalfSize))
    }
    path.lineWidth = size
    path.setLineDash(dashes, count: dashes.count, phase: 0)
    path.lineCapStyle = CGLineCap.Round

    if isVertical {
      UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, dotDoubleSize * num), false, 0)
    } else {
      UIGraphicsBeginImageContextWithOptions(CGSizeMake(dotDoubleSize * num, size), false, 0)
    }
    color.setStroke()
    path.stroke()
    let dottedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return dottedImage
  }

}
