//
//  RadialGradientView.swift
//  Profile
//
//  Created by Ian Hirschfeld on 12/27/15.
//  Copyright © 2015 The Soap Collective. All rights reserved.
//

import UIKit

class RadialGradientView: ParallaxView {

  // ==================================================
  // PROPERTIES
  // ==================================================

  var fromColor: UIColor = UIColor.blackColor() {
    didSet { setNeedsDisplay() }
  }

  var toColor: UIColor = UIColor.clearColor() {
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
    let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
    let radius = min(rect.width, rect.height) / 2
    CGContextDrawRadialGradient(ctx, gradient, center, 0, center, radius, CGGradientDrawingOptions(rawValue: 0))
  }

}
