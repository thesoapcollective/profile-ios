//
//  ItemViewController.swift
//  Profile
//
//  Created by Ian Hirschfeld on 12/21/15.
//  Copyright © 2015 The Soap Collective. All rights reserved.
//

import UIKit

class ItemViewController: PROViewController {

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

  var data: [String: String]! {
    didSet {
      setupData()
    }
  }
  var index = 0
  var photoImage: UIImage?

  // ==================================================
  // METHODS
  // ==================================================

  override func viewDidLoad() {
    super.viewDidLoad()
    descriptionContainerView.layer.borderWidth = 1
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    if UIDevice.currentDevice().orientation == .Portrait || UIDevice.currentDevice().orientation == .PortraitUpsideDown {
      let gradientOffset: CGFloat = -view.frame.width * 0.9
      gradientTopConstraint.constant = gradientOffset
      gradientTrailingConstraint.constant = gradientOffset
      view.layoutIfNeeded()
    }
  }

  func setupData() {
    let shortTitleText = NSMutableAttributedString(string: data["short_title"]!.uppercaseString)
    shortTitleText.addAttribute(NSKernAttributeName, value: 5, range: NSMakeRange(0, shortTitleText.length))
    shortTitleLabel.attributedText = shortTitleText

    let titleText = NSMutableAttributedString(string: data["title"]!.uppercaseString)
    titleText.addAttribute(NSKernAttributeName, value: 5, range: NSMakeRange(0, titleText.length))
    titleLabel.attributedText = titleText

    descriptionLabel.text = data["description"]
    if let image = data["photo"] {
      photoImage = UIImage(named: image)
      photoImageView.image = photoImage
      photoGrayscaleImageView.image = photoImage?.tintedImage(UIColor.appPrimaryTextColor(), tintAlpha: 1, tintBlendMode: .Color)
    }
  }

  override func updateColors() {
    view.backgroundColor = UIColor.appPrimaryBackgroundColor()
    descriptionContainerView.layer.borderColor = UIColor.appPrimaryTextColor().colorWithAlphaComponent(0.75).CGColor
    descriptionLabel.textColor = UIColor.appPrimaryTextColor()
    gradientView.fromColor = UIColor.appInvertedPrimaryBackgroundColor()
    gradientView.toColor = UIColor.appInvertedPrimaryBackgroundColor().colorWithAlphaComponent(0)
    shortTitleLabel.textColor = UIColor.appPrimaryTextColor()
    titleLabel.textColor = UIColor.appPrimaryTextColor()
  }

  // ==================================================
  // NOTIFICATIONS
  // ==================================================

  override func setupNotifcations() {
    super.setupNotifcations()
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "scrollChanged:", name: Global.ScrollChangedNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "scrollEnded:", name: Global.ScrollEndedNotification, object: nil)
  }

  func scrollChanged(notification: NSNotification) {
    // Override this to do stuff...
  }

  func scrollEnded(notification: NSNotification) {
    // Override this to do stuff...
  }

}
