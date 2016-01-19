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

  var data: [String: String]! {
    didSet {
      setupData()
    }
  }
  weak var delegate: ContainerViewController!
  var gradientView: LinearGradientView?
  var index = 0
  var itemView: ItemView!
  var photoImage: UIImage?

  // ==================================================
  // METHODS
  // ==================================================

  override func viewDidLoad() {
    super.viewDidLoad()

    itemView = NSBundle.mainBundle().loadNibNamed("ItemView", owner: self, options: nil).last as? ItemView
    itemView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(itemView)
    view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[subview]|", options: [], metrics: nil, views: ["subview": itemView]))
    view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[subview]|", options: [], metrics: nil, views: ["subview": itemView]))
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    if UIDevice.currentDevice().orientation == .Portrait || UIDevice.currentDevice().orientation == .PortraitUpsideDown {
      let gradientOffset: CGFloat = -view.frame.width * 0.9
      itemView.gradientTopConstraint.constant = gradientOffset
      itemView.gradientTrailingConstraint.constant = gradientOffset
      view.layoutIfNeeded()
    }
  }

  func setupData() {
    let shortTitleText = NSMutableAttributedString(string: data["short_title"]!.uppercaseString)
    shortTitleText.addAttribute(NSKernAttributeName, value: 5, range: NSMakeRange(0, shortTitleText.length))
    itemView.shortTitleLabel.attributedText = shortTitleText

    let titleText = NSMutableAttributedString(string: data["title"]!.uppercaseString)
    titleText.addAttribute(NSKernAttributeName, value: 5, range: NSMakeRange(0, titleText.length))
    itemView.titleLabel.attributedText = titleText

    itemView.descriptionLabel.text = data["description"]
    if let image = data["photo"] {
      photoImage = UIImage(named: image)
      itemView.photoImageView.image = photoImage
      itemView.photoGrayscaleImageView.image = photoImage?.tintedImage(UIColor.appPrimaryTextColor(), tintAlpha: 1, tintBlendMode: .Color)
    }
  }

  override func updateColors() {
    view.backgroundColor = UIColor.appPrimaryBackgroundColor()
    itemView.descriptionContainerView.layer.borderColor = UIColor.appPrimaryTextColor().colorWithAlphaComponent(0.75).CGColor
    itemView.descriptionLabel.textColor = UIColor.appPrimaryTextColor()
    itemView.gradientView.fromColor = UIColor.appInvertedPrimaryBackgroundColor()
    itemView.gradientView.toColor = UIColor.appInvertedPrimaryBackgroundColor().colorWithAlphaComponent(0)
    itemView.shortTitleLabel.textColor = UIColor.appPrimaryTextColor()
    itemView.titleLabel.textColor = UIColor.appPrimaryTextColor()
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
