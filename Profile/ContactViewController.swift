//
//  ContactViewController.swift
//  Profile
//
//  Created by Ian Hirschfeld on 12/22/15.
//  Copyright © 2015 The Soap Collective. All rights reserved.
//

import UIKit

class ContactViewController: PROViewController {

  // ==================================================
  // PROPERTIES
  // ==================================================

  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var companyLabel: UILabel!
  @IBOutlet weak var contactUsLabel: UILabel!
  @IBOutlet weak var emailButton: UIButton!
  @IBOutlet weak var phoneButton: UIButton!
  @IBOutlet weak var photoCreditsButton: UIButton!
  @IBOutlet weak var twitterButton: UIButton!

  // ==================================================
  // METHODS
  // ==================================================

  override func viewDidLoad() {
    super.viewDidLoad()

    emailButton.setImage(emailButton.imageView?.image?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
    phoneButton.setImage(phoneButton.imageView?.image?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
    twitterButton.setImage(twitterButton.imageView?.image?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
  }

  override func updateColors() {
    view.backgroundColor = UIColor.appInvertedPrimaryBackgroundColor()
    addressLabel.textColor = UIColor.appInvertedSecondaryTextColor()
    companyLabel.textColor = UIColor.appInvertedPrimaryTextColor()
    contactUsLabel.textColor = UIColor.appInvertedSecondaryTextColor()
    emailButton.tintColor = UIColor.appInvertedPrimaryTextColor()
    emailButton.setTitleColor(UIColor.appInvertedPrimaryTextColor(), forState: .Normal)
    phoneButton.tintColor = UIColor.appInvertedPrimaryTextColor()
    phoneButton.setTitleColor(UIColor.appInvertedPrimaryTextColor(), forState: .Normal)
    photoCreditsButton.setTitleColor(UIColor.appInvertedSecondaryTextColor(), forState: .Normal)
    twitterButton.tintColor = UIColor.appInvertedPrimaryTextColor()
    twitterButton.setTitleColor(UIColor.appInvertedPrimaryTextColor(), forState: .Normal)
  }



  @IBAction func emailTapped(sender: UIButton) {
    tryToEmail("info@thesoapcollective.com", subject: "Hey Soap!")
  }

  @IBAction func photoCreditsTapped(sender: UIButton) {
    guard let url = NSURL(string: "http://www.daviddatnguyen.com") else { return }
    UIApplication.sharedApplication().openURL(url)
  }

  @IBAction func phoneTapped(sender: UIButton) {
    askToCall("1-857-203-1004", name: "us")
  }

  @IBAction func twitterTapped(sender: UIButton) {
    guard let url = NSURL(string: "https://twitter.com/soapcollective") else { return }
    UIApplication.sharedApplication().openURL(url)
  }

  func transitionToDarkMode() {
    UIView.animateWithDuration(0.3, animations: { () -> Void in
      self.view.alpha = 0
    }) { (completed) -> Void in
      UIView.animateWithDuration(0.5, delay: 1, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
        self.view.alpha = 1
      }, completion: nil)
    }
  }

  func transitionToLightMode() {
    UIView.animateWithDuration(0.3, animations: { () -> Void in
      self.view.alpha = 0
    }) { (completed) -> Void in
      UIView.animateWithDuration(0.5, delay: 1, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
        self.view.alpha = 1
      }, completion: nil)
    }
  }

  // ==================================================
  // NOTIFICATIONS
  // ==================================================

  override func setupNotifcations() {
    super.setupNotifcations()
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChanged:", name: UIDeviceOrientationDidChangeNotification, object: nil)
  }

  func orientationChanged(notification: NSNotification) {
    switch UIDevice.currentDevice().orientation {
    case .Portrait:
      if Global.mode != .Light {
        transitionToLightMode()
      }
      break

    case .PortraitUpsideDown:
      if Global.mode != .Dark {
        transitionToDarkMode()
      }
      break

    default:
      break
    }
  }

}
