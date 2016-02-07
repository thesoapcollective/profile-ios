//
//  ItemViewController.swift
//  Profile
//
//  Created by Ian Hirschfeld on 12/21/15.
//  Copyright © 2015 The Soap Collective. All rights reserved.
//

import AlamofireImage
import SwiftyJSON
import UIKit

class ItemViewController: PROViewController {

  // ==================================================
  // PROPERTIES
  // ==================================================

  var data: JSON! {
    didSet {
      setupData()
    }
  }
  weak var delegate: ContainerViewController!
  var index = 0
  var itemView: ItemView!

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
      itemView.radialGradientTopConstraint.constant = gradientOffset
      itemView.radialGradientTrailingConstraint.constant = gradientOffset
      view.layoutIfNeeded()
    }
  }

  override func updateColors() {
    view.backgroundColor = UIColor.appPrimaryBackgroundColor()
    itemView.descriptionContainerView.layer.borderColor = UIColor.appPrimaryTextColor().colorWithAlphaComponent(0.75).CGColor
    itemView.descriptionPositionView.backgroundColor = UIColor.appPrimaryBackgroundColor().colorWithAlphaComponent(0.9)
    itemView.descriptionLabel.textColor = UIColor.appPrimaryTextColor()
    itemView.radialGradientView.fromColor = UIColor.appInvertedPrimaryBackgroundColor()
    itemView.radialGradientView.toColor = UIColor.appInvertedPrimaryBackgroundColor().colorWithAlphaComponent(0)
    itemView.shortTitleLabel.textColor = UIColor.appPrimaryTextColor()
    itemView.titleLabel.textColor = UIColor.appPrimaryTextColor()
    itemView.websiteButton.setTitleColor(UIColor.appPrimaryTextColor(), forState: .Normal)
  }

  override func profileModeChanged(notification: NSNotification) {
    super.profileModeChanged(notification)
    setModeDependentAttributes()
  }

  func setupData() {
    let shortTitleText = NSMutableAttributedString(string: data["short_title"].stringValue.uppercaseString)
    shortTitleText.addAttribute(NSKernAttributeName, value: 5, range: NSMakeRange(0, shortTitleText.length))
    itemView.shortTitleLabel.attributedText = shortTitleText

    let titleText = NSMutableAttributedString(string: data["title"].stringValue.uppercaseString)
    titleText.addAttribute(NSKernAttributeName, value: 5, range: NSMakeRange(0, titleText.length))
    itemView.titleLabel.attributedText = titleText

    if let websiteUrl = data["website_url"].string {
      itemView.websiteButton.setTitle(websiteUrl, forState: .Normal)
      itemView.websiteButton.hidden = false
      itemView.appStoreButton.hidden = true
      itemView.descriptionLabelBottomConstraint.constant = 40
      itemView.websiteButton.addTarget(self, action: "websiteTapped:", forControlEvents: .TouchUpInside)
    } else if let _ = data["app_store_url"].string {
      itemView.websiteButton.hidden = true
      itemView.appStoreButton.hidden = false
      itemView.descriptionLabelBottomConstraint.constant = 50
      itemView.appStoreButton.addTarget(self, action: "appStoreTapped:", forControlEvents: .TouchUpInside)
    } else {
      itemView.websiteButton.hidden = true
      itemView.appStoreButton.hidden = true
      itemView.descriptionLabelBottomConstraint.constant = 0
    }
    view.layoutIfNeeded()

    setModeDependentAttributes()
  }

  func setModeDependentAttributes() {
    itemView.descriptionLabel.text = Global.mode == .Light ? data["day_description"].stringValue : data["night_description"].stringValue

    updateImage(true)

    let itemPosition = Global.mode == .Light ? data["day_title_position"].dictionaryValue : data["night_title_position"].dictionaryValue
    var titlePosition = itemPosition["iphone"]?.dictionaryValue
    if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
      if let ipadPosition = itemPosition["ipad"]?.dictionary {
        titlePosition = ipadPosition
      }
    }
    if let position = titlePosition {
      itemView.shortTitleLabelLeadingConstraint.constant = CGFloat(position["x"]!.doubleValue) * view.frame.width
      itemView.shortTitleLabelTopConstraint.constant = CGFloat(position["y"]!.doubleValue) * view.frame.height
    } else {
      itemView.shortTitleLabelLeadingConstraint.constant = 100
      itemView.shortTitleLabelTopConstraint.constant = 50
    }
    view.layoutIfNeeded()
  }

  func updateImage(modeChanged: Bool = false) {
    if delegate.currentIndex + 1 == index ||
      delegate.currentIndex - 1 == index ||
      delegate.currentIndex == index {
        if itemView.photoImageView.image == nil || modeChanged {
          let photoUrl = Global.mode == .Light ? data["day_photo_url"].stringValue : data["night_photo_url"].stringValue
          if let imageUrl = NSURL(string: photoUrl) {
            itemView.photoImageView.af_setImageWithURL(imageUrl, placeholderImage: nil, filter: nil, imageTransition: .CrossDissolve(0.3), runImageTransitionIfCached: false, completion: { [unowned self] (response) -> Void in
              self.itemView.photoGrayscaleImageView.image = response.result.value?.tintedImage(UIColor.appPrimaryTextColor(), tintAlpha: 1, tintBlendMode: .Color)
              })
          }
        }
    } else {
      itemView.photoImageView.image = nil
      itemView.photoGrayscaleImageView.image = nil
    }
  }

  func websiteTapped(sender: UIButton) {
    guard let websiteUrl = data["website_url"].string else { return }
    guard let url = NSURL(string: websiteUrl) else { return }
    UIApplication.sharedApplication().openURL(url)
  }

  func appStoreTapped(sender: UIButton) {
    guard let websiteUrl = data["app_store_url"].string else { return }
    guard let url = NSURL(string: websiteUrl) else { return }
    UIApplication.sharedApplication().openURL(url)
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
