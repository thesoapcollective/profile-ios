//
//  IndexTableViewCell.swift
//  Profile
//
//  Created by Ian Hirschfeld on 1/22/16.
//  Copyright © 2016 The Soap Collective. All rights reserved.
//

import UIKit

class IndexTableViewCell: UITableViewCell {

  // ==================================================
  // PROPERTIES
  // ==================================================

  @IBOutlet weak var iconDottedBorderView: DottedCircleBorderImageView!
  @IBOutlet weak var iconImageView: UIImageView!
  @IBOutlet weak var bottomDottedBorderView: DottedBorderImageView!
  @IBOutlet weak var titleLabel: UILabel!

  // ==================================================
  // METHODS
  // ==================================================

  override func awakeFromNib() {
    super.awakeFromNib()
    iconImageView.layer.cornerRadius = iconImageView.frame.width / 2
  }

  func startAnimation() {
    let animation = CABasicAnimation(keyPath: "transform.rotation")
    animation.fromValue = 0
    animation.toValue = M_PI * -2
    animation.duration = 20
    animation.repeatCount = 999
    iconDottedBorderView.layer.addAnimation(animation, forKey: "rotationAnimation")
  }

  func stopAnimation() {
    iconDottedBorderView.layer.removeAllAnimations()
  }

}
