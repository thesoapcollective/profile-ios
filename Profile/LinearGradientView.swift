//
//  LinearGradientView.swift
//  Profile
//
//  Created by Ian Hirschfeld on 1/3/16.
//  Copyright © 2016 The Soap Collective. All rights reserved.
//

import UIKit

class LinearGradientView: UIView {

  // ==================================================
  // PROPERTIES
  // ==================================================

  var fromColor: UIColor = UIColor.blackColor() {
    didSet { setGradientLayerColors() }
  }

  var toColor: UIColor = UIColor.clearColor() {
    didSet { setGradientLayerColors() }
  }

  let gradientLayer = CAGradientLayer()

  // ==================================================
  // METHODS
  // ==================================================

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupView()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    gradientLayer.frame = bounds
  }

  func setupView() {
    layer.addSublayer(gradientLayer)
    setGradientLayerColors()
  }

  func setGradientLayerColors() {
    gradientLayer.colors = [fromColor.CGColor, toColor.CGColor]
  }

}
