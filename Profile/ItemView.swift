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

  @IBOutlet weak var descriptionContainerView: UIView!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var gradientContainerView: UIView!
  @IBOutlet weak var gradientView: RadialGradientView!
  @IBOutlet weak var photoGrayscaleImageView: UIImageView!
  @IBOutlet weak var photoImageView: UIImageView!
  @IBOutlet weak var shortTitleLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!

  @IBOutlet weak var descriptionTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var gradientTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var gradientTrailingConstraint: NSLayoutConstraint!

  var photoImage: UIImage?

  // ==================================================
  // METHODS
  // ==================================================

  override func awakeFromNib() {
    super.awakeFromNib()
    descriptionContainerView.layer.borderWidth = 1
  }

}
