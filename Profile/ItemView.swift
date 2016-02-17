//
//  ItemView.swift
//  Profile
//
//  Created by Ian Hirschfeld on 1/17/16.
//  Copyright © 2016 The Soap Collective. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class ItemView: UIView {

  // ==================================================
  // PROPERTIES
  // ==================================================

  @IBOutlet weak var appStoreButton: UIButton!
  @IBOutlet weak var bottomGradientView: LinearGradientView!
  @IBOutlet weak var descriptionContainerView: ParallaxView!
  @IBOutlet weak var descriptionGradientView: LinearGradientView!
  @IBOutlet weak var descriptionLabel: TTTAttributedLabel!
  @IBOutlet weak var descriptionListLabel: UILabel!
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

  @IBOutlet weak var photoImageViewTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var photoImageViewBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var photoImageViewLeadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var photoImageViewTrailingConstraint: NSLayoutConstraint!
  @IBOutlet weak var photoGrayscaleImageViewTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var photoGrayscaleImageViewBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var photoGrayscaleImageViewLeadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var photoGrayscaleImageViewTrailingConstraint: NSLayoutConstraint!

  var photoImage: UIImage?

  // ==================================================
  // METHODS
  // ==================================================

  override func awakeFromNib() {
    super.awakeFromNib()

    appStoreButton.imageView?.contentMode = .ScaleAspectFit
    descriptionContainerView.layer.borderWidth = 1
    websiteButton.titleLabel?.adjustsFontSizeToFitWidth = true
    websiteButton.titleLabel?.minimumScaleFactor = 10.0 / 14.0

    if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
      photoImageViewTopConstraint.constant = -25
      photoImageViewBottomConstraint.constant = -25
      photoImageViewLeadingConstraint.constant = -25
      photoImageViewTrailingConstraint.constant = -25
      photoGrayscaleImageViewTopConstraint.constant = -25
      photoGrayscaleImageViewBottomConstraint.constant = -25
      photoGrayscaleImageViewLeadingConstraint.constant = -25
      photoGrayscaleImageViewTrailingConstraint.constant = -25
    } else {
      photoImageViewTopConstraint.constant = -50
      photoImageViewBottomConstraint.constant = -50
      photoImageViewLeadingConstraint.constant = -50
      photoImageViewTrailingConstraint.constant = -50
      photoGrayscaleImageViewTopConstraint.constant = -50
      photoGrayscaleImageViewBottomConstraint.constant = -50
      photoGrayscaleImageViewLeadingConstraint.constant = -50
      photoGrayscaleImageViewTrailingConstraint.constant = -50
    }
  }

}
