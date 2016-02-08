//
//  ContinueArrowView.swift
//  Profile
//
//  Created by Ian Hirschfeld on 1/17/16.
//  Copyright © 2016 The Soap Collective. All rights reserved.
//

import UIKit

class ContinueArrowView: ParallaxView {

  // ==================================================
  // PROPERTIES
  // ==================================================

  @IBOutlet weak var arrowHeadImageView: UIImageView!
  @IBOutlet weak var arrowStemImageView: DottedBorderImageView!
  @IBOutlet weak var arrowTailImageView: UIImageView!
  @IBOutlet weak var bottomHitboxView: UIView!
  @IBOutlet weak var topHitboxView: UIView!

  var index: Int!
  var stage: Int!

  // ==================================================
  // METHODS
  // ==================================================

  override func awakeFromNib() {
    super.awakeFromNib()

    arrowHeadImageView.image = arrowHeadImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
    arrowTailImageView.image = arrowTailImageView.image?.imageWithRenderingMode(.AlwaysTemplate)

    let bottomHitboxTapGesture = UITapGestureRecognizer(target: self, action: "bottomHitboxTapped:")
    bottomHitboxView.addGestureRecognizer(bottomHitboxTapGesture)

    let topHitboxTapGesture = UITapGestureRecognizer(target: self, action: "topHitboxTapped:")
    topHitboxView.addGestureRecognizer(topHitboxTapGesture)
  }

  func bottomHitboxTapped(gesture: UITapGestureRecognizer) {
    NSNotificationCenter.defaultCenter().postNotificationName(Global.ArrowBottomTappedNotification, object: nil, userInfo: ["index": index, "stage": stage])
  }

  func topHitboxTapped(gesture: UITapGestureRecognizer) {
    NSNotificationCenter.defaultCenter().postNotificationName(Global.ArrowTopTappedNotification, object: nil, userInfo: ["index": index, "stage": stage])
  }

}
