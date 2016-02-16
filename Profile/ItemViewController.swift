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

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    if let _ = data["website_url"].string {
      itemView.descriptionLabelBottomConstraint.constant = itemView.websiteButton.frame.height + 10
    } else if let _ = data["app_store_url"].string {
      itemView.descriptionLabelBottomConstraint.constant = itemView.appStoreButton.frame.height + 10
    } else {
      itemView.descriptionLabelBottomConstraint.constant = 0
    }
    view.layoutIfNeeded()
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
      itemView.websiteButton.addTarget(self, action: "websiteTapped:", forControlEvents: .TouchUpInside)
    } else if let _ = data["app_store_url"].string {
      itemView.websiteButton.hidden = true
      itemView.appStoreButton.hidden = false
      itemView.appStoreButton.addTarget(self, action: "appStoreTapped:", forControlEvents: .TouchUpInside)
    } else {
      itemView.websiteButton.hidden = true
      itemView.appStoreButton.hidden = true
    }

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

    // TODO: Come up with a better schema so links can be dynamic.
    } else if description.rangeOfString("Instagram:") != nil ||
      description.rangeOfString("Medium:") != nil ||
      description.rangeOfString("Tumblr:") != nil ||
      description.rangeOfString("Twitter:") != nil { // A social links description
      let linkItems = description.componentsSeparatedByString("\n")

      for linkItem in linkItems {
        if linkItem.rangeOfString("Instagram:") != nil {
          let username = linkItem.substringFromIndex(linkItem.startIndex.advancedBy(11))
          if let appUrl = NSURL(string: "instagram://user?username=\(username)") {
            var url: NSURL?
            if UIApplication.sharedApplication().canOpenURL(appUrl) {
              url = appUrl
            } else {
              url = NSURL(string: "https://www.instagram.com/\(username)")
            }
            if url != nil {
              let startRange = description.rangeOfString(linkItem)
              let startLocation = description.startIndex.distanceTo(startRange!.startIndex.advancedBy(11))
              itemView.descriptionLabel.addLinkToURL(url!, withRange: NSRange(location: startLocation, length: username.characters.count))
            }
          }
        } else if linkItem.rangeOfString("Medium:") != nil {
          let username = linkItem.substringFromIndex(linkItem.startIndex.advancedBy(8))
          if let url = NSURL(string: "https://medium.com/\(username)") {
            let startRange = description.rangeOfString(linkItem)
            let startLocation = description.startIndex.distanceTo(startRange!.startIndex.advancedBy(8))
            itemView.descriptionLabel.addLinkToURL(url, withRange: NSRange(location: startLocation, length: username.characters.count))
          }
        } else if linkItem.rangeOfString("Twitter:") != nil {
          let username = linkItem.substringFromIndex(linkItem.startIndex.advancedBy(10)) // Advance by 10 to remove the @.
          if let url = NSURL(string: "https://twitter.com/\(username)") {
            let startRange = description.rangeOfString(linkItem)
            let startLocation = description.startIndex.distanceTo(startRange!.startIndex.advancedBy(10))
            itemView.descriptionLabel.addLinkToURL(url, withRange: NSRange(location: startLocation, length: username.characters.count-1))
          }
        } else if linkItem.rangeOfString("Tumblr:") != nil {
          let username = linkItem.substringFromIndex(linkItem.startIndex.advancedBy(8)).lowercaseString
          if let appUrl = NSURL(string: "tumblr://x-callback-url/blog?blogName=\(username)") {
            var url: NSURL?
            if UIApplication.sharedApplication().canOpenURL(appUrl) {
              url = appUrl
            } else {
              url = NSURL(string: "https://\(username).tumblr.com")
            }
            if url != nil {
              let startRange = description.rangeOfString(linkItem)
              let startLocation = description.startIndex.distanceTo(startRange!.startIndex.advancedBy(8))
              itemView.descriptionLabel.addLinkToURL(url, withRange: NSRange(location: startLocation, length: username.characters.count))
            }
          }
        }
      }
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
          itemView.photoImageView.alpha = 0
          itemView.photoGrayscaleImageView.alpha = 0
          let photoUrl = Global.mode == .Light ? data["day_photo_url"].stringValue : data["night_photo_url"].stringValue
          if let imageUrl = NSURL(string: photoUrl) {
            itemView.photoImageView.af_setImageWithURL(imageUrl, placeholderImage: nil, filter: nil, imageTransition: .CrossDissolve(0.3), runImageTransitionIfCached: false, completion: { [unowned self] (response) -> Void in
              self.itemView.photoGrayscaleImageView.image = response.result.value?.tintedImage(UIColor.appPrimaryTextColor(), tintAlpha: 1, tintBlendMode: .Color)
              self.itemView.photoImageView.alpha = self.delegate.currentStage == 0 ? 1 : 0
              self.itemView.photoGrayscaleImageView.alpha = self.delegate.currentStage == 1 ? 1 : 0
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
    let urlString = url.absoluteString
    if urlString.rangeOfString("mailto:") != nil {
      let email = urlString[urlString.startIndex.advancedBy(7)..<urlString.endIndex]
      tryToEmail(email, subject: "Hey \(data["short_title"].stringValue)!")
    } else {
      UIApplication.sharedApplication().openURL(url)
    }
  }

  func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithPhoneNumber phoneNumber: String!) {
    askToCall(phoneNumber, name: data["short_title"].stringValue)
  }

}
