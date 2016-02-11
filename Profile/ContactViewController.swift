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

  @IBOutlet weak var companyLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var twitterButton: UIButton!
  @IBOutlet weak var emailButton: UIButton!
  @IBOutlet weak var phoneButton: UIButton!
  @IBOutlet weak var contactUsLabel: UILabel!

  // ==================================================
  // METHODS
  // ==================================================

  override func viewDidLoad() {
    super.viewDidLoad()

    twitterButton.setImage(twitterButton.imageView?.image?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
    emailButton.setImage(emailButton.imageView?.image?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
    phoneButton.setImage(phoneButton.imageView?.image?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
  }

  override func updateColors() {
    view.backgroundColor = UIColor.appInvertedPrimaryBackgroundColor()
    companyLabel.textColor = UIColor.appInvertedPrimaryTextColor()
    addressLabel.textColor = UIColor.appInvertedSecondaryTextColor()
    twitterButton.tintColor = UIColor.appInvertedPrimaryTextColor()
    twitterButton.setTitleColor(UIColor.appInvertedPrimaryTextColor(), forState: .Normal)
    emailButton.tintColor = UIColor.appInvertedPrimaryTextColor()
    emailButton.setTitleColor(UIColor.appInvertedPrimaryTextColor(), forState: .Normal)
    phoneButton.tintColor = UIColor.appInvertedPrimaryTextColor()
    phoneButton.setTitleColor(UIColor.appInvertedPrimaryTextColor(), forState: .Normal)
    contactUsLabel.textColor = UIColor.appInvertedSecondaryTextColor()
  }

  @IBAction func twitterTapped(sender: UIButton) {
    guard let url = NSURL(string: "https://twitter.com/soapcollective") else { return }
    UIApplication.sharedApplication().openURL(url)
  }

  @IBAction func emailTapped(sender: UIButton) {
    tryToEmail("info@thesoapcollective.com", subject: "Hey Soap!")
  }

  @IBAction func phoneTapped(sender: UIButton) {
    askToCall("1-857-203-1004", name: "us")
  }

}
