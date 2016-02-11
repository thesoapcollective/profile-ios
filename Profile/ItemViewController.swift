//
//  ItemViewController.swift
//  Profile
//
//  Created by Ian Hirschfeld on 12/21/15.
//  Copyright © 2015 The Soap Collective. All rights reserved.
//

import AlamofireImage
import SwiftyJSON
import TTTAttributedLabel
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

  override func updateColors() {
    view.backgroundColor = UIColor.appPrimaryBackgroundColor()
    itemView.descriptionContainerView.layer.borderColor = UIColor.appPrimaryTextColor().colorWithAlphaComponent(0.75).CGColor
    let descriptionPositionBackgroundColor: CGFloat = Global.mode == .Light ? 0.9 : 0.7
    itemView.descriptionPositionView.backgroundColor = UIColor.appPrimaryBackgroundColor().colorWithAlphaComponent(descriptionPositionBackgroundColor)
    itemView.descriptionLabel.textColor = UIColor.appPrimaryTextColor()
    itemView.descriptionListLabel.textColor = UIColor.appPrimaryTextColor()
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
    shortTitleText.addAttribute(NSKernAttributeName, value: 5, range: NSRange(location: 0, length: shortTitleText.length))
    itemView.shortTitleLabel.attributedText = shortTitleText

    let titleText = NSMutableAttributedString(string: data["title"].stringValue.uppercaseString)
    titleText.addAttribute(NSKernAttributeName, value: 5, range: NSRange(location: 0, length: titleText.length))
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
    let description = Global.mode == .Light ? data["day_description"].stringValue : data["night_description"].stringValue
    itemView.descriptionLabel.text = description
    itemView.descriptionLabel.linkAttributes = [
      kCTForegroundColorAttributeName: UIColor.appPrimaryTextColor(),
      kCTUnderlineStyleAttributeName: NSNumber(int: CTUnderlineStyle.None.rawValue)
    ]
    itemView.descriptionLabel.activeLinkAttributes = [
      kCTForegroundColorAttributeName: UIColor.appPrimaryTextColor(),
      kCTUnderlineStyleAttributeName: NSNumber(int: CTUnderlineStyle.None.rawValue)
    ]
    itemView.descriptionLabel.delegate = self
    itemView.descriptionListLabel.text = ""
    itemView.descriptionLabel.hidden = false
    itemView.descriptionListLabel.hidden = true

    // NOTE: Currently, TTTAttributedLabel does NOT properly support paragraph styles. Once it does the extra descriptionListLabel can be removed.
    // https://github.com/TTTAttributedLabel/TTTAttributedLabel
    // https://github.com/TTTAttributedLabel/TTTAttributedLabel/issues/561
    //
    // @ianhirschfeld 2016-02-11
    if description.rangeOfString("\u{2022}") != nil { // A description with a bulleted list.
      itemView.descriptionListLabel.text = description
      itemView.descriptionLabel.hidden = true
      itemView.descriptionListLabel.hidden = false

      let descriptionText = NSMutableAttributedString(string: description)
      let paragraphStyle = NSMutableParagraphStyle()
      paragraphStyle.firstLineHeadIndent = 10
      paragraphStyle.headIndent = 28
      paragraphStyle.paragraphSpacingBefore = 10
      let startRange = description.rangeOfString("\n")
      let startLocation = description.startIndex.distanceTo(startRange!.startIndex)
      descriptionText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSRange(location: startLocation, length: descriptionText.length - startLocation))
      itemView.descriptionListLabel.attributedText = descriptionText
    } else if description.rangeOfString("\u{2022}") == nil && description.rangeOfString("\n") != nil { // A description with line breaks and no bullets.
      let descriptionText = NSMutableAttributedString(string: description)
      let paragraphStyle = NSMutableParagraphStyle()
      paragraphStyle.paragraphSpacingBefore = 10
      descriptionText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSRange(location: 0, length: descriptionText.length))
      if let font = UIFont(name: "FuturaPt-Book", size: itemView.descriptionLabel.font.pointSize) {
        descriptionText.addAttribute(NSFontAttributeName, value: font, range: NSRange(location: 0, length: descriptionText.length))
        descriptionText.addAttribute(NSForegroundColorAttributeName, value: UIColor.appPrimaryTextColor().CGColor, range: NSRange(location: 0, length: descriptionText.length))
      }
      itemView.descriptionLabel.setText(descriptionText)
    }

    if description.rangeOfString("@thesoapcollective.com") != nil { // A phone and email description
      // Assumes two items: Phone, Email
      let linkItems = description.componentsSeparatedByString("\n")

      let rawPhoneNumber = linkItems[0]
      let phoneNumber = "1-\(rawPhoneNumber.stringByReplacingOccurrencesOfString(".", withString: "-"))"
      itemView.descriptionLabel.addLinkToPhoneNumber(phoneNumber, withRange: NSRange(location: 0, length: rawPhoneNumber.characters.count))

      let email = linkItems[1]
      if let url = NSURL(string: "mailto:\(email)") {
        let startRange = description.rangeOfString(email)
        let startLocation = description.startIndex.distanceTo(startRange!.startIndex)
        itemView.descriptionLabel.addLinkToURL(url, withRange: NSRange(location: startLocation, length: email.characters.count))
      }
    } else if description.rangeOfString("Twitter:") != nil || description.rangeOfString("Instagram:") != nil { // A social links description
    }

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

  func addParallaxToViews() {
    itemView.photoImageView.addParallax(Global.ParallaxOffset3)
    itemView.photoGrayscaleImageView.addParallax(Global.ParallaxOffset3)
    itemView.descriptionContainerView.addParallax(Global.ParallaxOffset1)
    itemView.shortTitleLabel.addParallax(Global.ParallaxOffset1)
  }

  func removeParallaxFromViews() {
    itemView.photoImageView.removeParallax()
    itemView.photoGrayscaleImageView.removeParallax()
    itemView.descriptionContainerView.removeParallax()
    itemView.shortTitleLabel.removeParallax()
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

extension ItemViewController: TTTAttributedLabelDelegate {

  func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
    print("url tapped: \(url), \(url.host)")
    let urlString = url.absoluteString

    if urlString.rangeOfString("mailto:") != nil {
      let email = urlString[urlString.startIndex.advancedBy(7)..<urlString.endIndex]
      tryToEmail(email, subject: "Hey \(data["short_title"].stringValue)!")
    }
  }

  func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithPhoneNumber phoneNumber: String!) {
    print("phone number tapped: \(phoneNumber)")
    askToCall(phoneNumber, name: data["short_title"].stringValue)
  }

}
