//
//  RadialGradientView.swift
//  Profile
//
//  Created by Ian Hirschfeld on 12/27/15.
//  Copyright © 2015 The Soap Collective. All rights reserved.
//

import UIKit

@IBDesignable
class RadialGradientView: UIView {

  // ==================================================
  // PROPERTIES
  // ==================================================

  @IBInspectable var fromColor: UIColor = UIColor.blackColor() {
    didSet { setNeedsDisplay() }
  }

  @IBInspectable var toColor: UIColor = UIColor.clearColor() {
    didSet { setNeedsDisplay() }
  }

  // ==================================================
  // METHODS
  // ==================================================

  override func drawRect(rect: CGRect) {
    let ctx = UIGraphicsGetCurrentContext()
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let colors = [fromColor.CGColor, toColor.CGColor]
    let locations: [CGFloat] = [0, 1]
    let gradient = CGGradientCreateWithColors(colorSpace, colors, locations)
    let centerX = rect.width / 2
    let centerY = rect.height / 2
    let center = CGPoint(x: centerX, y: centerY)
    let radius = min(rect.width, rect.height) / 2
    CGContextDrawRadialGradient(ctx, gradient, center, 0, center, radius, CGGradientDrawingOptions(rawValue: 0))
  }

}
