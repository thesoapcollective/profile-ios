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
  @IBOutlet weak var descriptionContainerView: UIView!
  @IBOutlet weak var descriptionGradientView: LinearGradientView!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var descriptionPositionView: UIView!
  @IBOutlet weak var radialGradientContainerView: UIView!
  @IBOutlet weak var radialGradientView: RadialGradientView!
  @IBOutlet weak var photoGrayscaleImageView: UIImageView!
  @IBOutlet weak var photoImageView: UIImageView!
  @IBOutlet weak var shortTitleLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var topGradientView: LinearGradientView!
  @IBOutlet weak var websiteButton: UIButton!

  @IBOutlet weak var bottomGradientBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var descriptionGradientBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var descriptionLabelBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var descriptionTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var radialGradientTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var radialGradientTrailingConstraint: NSLayoutConstraint!
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
  }

}
