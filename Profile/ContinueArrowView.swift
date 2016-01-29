//
//  ContinueArrowView.swift
//  Profile
//
//  Created by Ian Hirschfeld on 1/17/16.
//  Copyright © 2016 The Soap Collective. All rights reserved.
//

import UIKit

class ContinueArrowView: UIView {

  // ==================================================
  // PROPERTIES
  // ==================================================

  @IBOutlet weak var arrowHeadImageView: UIImageView!
  @IBOutlet weak var arrowStemImageView: DottedBorderImageView!
  @IBOutlet weak var arrowTailImageView: UIImageView!

  // ==================================================
  // METHODS
  // ==================================================

  override func awakeFromNib() {
    super.awakeFromNib()

    arrowHeadImageView.image = arrowHeadImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
    arrowTailImageView.image = arrowTailImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
  }

}
