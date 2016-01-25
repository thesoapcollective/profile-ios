//
//  DottedCircleBorderImageView.swift
//  Profile
//
//  Created by Ian Hirschfeld on 1/24/16.
//  Copyright © 2016 The Soap Collective. All rights reserved.
//

import UIKit

@IBDesignable
class DottedCircleBorderImageView: UIImageView {

  // ==================================================
  // PROPERTIES
  // ==================================================

  @IBInspectable var dotSize: CGFloat = 5 {
    didSet { updateImage() }
  }

  @IBInspectable var dotColor: UIColor = UIColor.blackColor() {
    didSet { updateImage() }
  }

  // ==================================================
  // METHODS
  // ==================================================

  func updateImage() {
    let dottedImage = createDottedImage(dotSize, color: dotColor)
    image = dottedImage
  }

  func createDottedImage(size: CGFloat, color: UIColor) -> UIImage {
    let dotHalfSize: CGFloat = size / 2
    let dotDoubleSize: CGFloat = size * 2
    let dashes: [CGFloat] = [0, dotDoubleSize]

    let path = UIBezierPath()
    let center = CGPoint(x: frame.width / 2 + dotHalfSize, y: frame.height / 2 + dotHalfSize)
    let radius = min(frame.width, frame.height) / 2
    path.addArcWithCenter(center, radius: radius, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true)
    path.lineWidth = size
    path.setLineDash(dashes, count: dashes.count, phase: 0)
    path.lineCapStyle = CGLineCap.Round

    let size = CGSize(width: frame.width + dotSize, height: frame.height + dotSize)
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    color.setStroke()
    path.stroke()
    let dottedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return dottedImage
  }

}
