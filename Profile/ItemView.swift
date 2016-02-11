//
//  ItemView.swift
//  Profile
//
//  Created by Ian Hirschfeld on 1/17/16.
//  Copyright © 2016 The Soap Collective. All rights reserved.
//

import UIKit

class ItemView: UIView {

  // ==================================================
  // PROPERTIES
  // ==================================================

  @IBOutlet weak var appStoreButton: UIButton!
  @IBOutlet weak var bottomGradientView: LinearGradientView!
  @IBOutlet weak var descriptionContainerView: ParallaxView!
  @IBOutlet weak var descriptionGradientView: LinearGradientView!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var descriptionPositionView: UIView!
  @IBOutlet weak var photoGrayscaleImageView: ParallaxImageView!
  @IBOutlet weak var photoImageView: ParallaxImageView!
  @IBOutlet weak var shortTitleLabel: ParallaxLabel!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var topGradientView: LinearGradientView!
  @IBOutlet weak var websiteButton: UIButton!

  @IBOutlet weak var bottomGradientBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var descriptionGradientBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var descriptionLabelBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var descriptionTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var shortTitleLabelTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var shortTitleLabelLeadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var topGradientTopConstraint: NSLayoutConstraint!

  var photoImage: UIImage?

  // ==================================================
  // METHODS
  // ==================================================

  override func awakeFromNib() {
    super.awakeFromNib()

    descriptionContainerView.layer.borderWidth = 1
    websiteButton.titleLabel?.adjustsFontSizeToFitWidth = true
    websiteButton.titleLabel?.minimumScaleFactor = 10.0 / 14.0
  }

}
